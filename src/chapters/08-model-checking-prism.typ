#import "@preview/bookly:5.1.0": *

#show: chapter.with(
  title: "Temporal Logic and Model Checking with PRISM",
  abstract: [
    Model checking verifies temporal-logic properties on finite-state
    probabilistic models automatically. This chapter covers CTL and PCTL, PRISM
    syntax for DTMCs and CTMCs, modular synchronization, rewards,
    Lotka---Volterra and SIR analysis, statistical model checking, and the
    Tuscany COVID-19 case study combining ODE fitting with probabilistic
    verification.
  ],
  toc: true,
)

== What Is Model Checking?

_Model checking_ takes a finite-state model of system behavior and a formal
specification, then decides whether the specification holds. When it fails, the
tool often returns a _counterexample_---a trace demonstrating the violation.
Unlike testing, which samples finitely many executions, model checking aims to
account for all admissible behaviors, or all paths weighted by probability.

PRISM is a widely used model checker for probabilistic and stochastic systems
developed at the University of Oxford since the 1990s. It accepts models written
as guarded probabilistic or rate-based update rules and verifies properties
expressed in temporal logics. The simulator generates individual random traces
for debugging; the verifier computes exact or statistical probabilities over the
full state space. Different tools target different domains---hardware circuits,
software semantics, infinite-state systems---but PRISM specializes in finite
DTMCs and CTMCs and remains the reference implementation for probabilistic model
checking research.

== Temporal Logic: CTL and PCTL

Temporal logics differ from propositional logic by quantifying over _paths_
through the state graph rather than over single states. A property such as "the
alarm eventually rings" is inherently about a sequence of observations over
time; CTL and PCTL provide operators to state such requirements formally and
algorithms to decide them against a finite model.

_Computation Tree Logic_ (CTL) combines path quantifiers with temporal
operators. The existential quantifier $E$ asserts that some path satisfies a
condition; the universal quantifier $A$ requires all paths to do so. Temporal
operators include $X$ (next), $F$ (eventually), $G$ (globally), and $U$ (until).
The formula `E F red` asks whether some path eventually reaches a red state;
`A G safe` requires safety on every path; `yellow U red` demands yellow states
until red is reached.

On a small graph with red and yellow nodes, `E F red` holds when at least one
path reaches red. `A F red` requires every path to reach red eventually.
`E G red` holds if some path stays red forever. `A G red` requires all states on
all paths to be red. `E (yellow U red)` holds when some path is yellow until red
appears. Nesting produces richer queries: `E F (red and A G yellow)` asks
whether a red state can be reached from which all continuations remain yellow.

#figure(
  image("../images/chapter8/ctl-example-graph.pdf", width: 68%),
  caption: [
    Small state graph with red and yellow nodes illustrating CTL formulas such
    as `E F red`, `A G safe`, and `E (yellow U red).`
  ],
) <fig:ctl-example-graph>

Although syntax appears complex, many properties reduce ultimately to
reachability on the underlying graph. Model checkers visit the state space,
testing atomic propositions at each node and propagating truth values according
to the logical structure.

_Probabilistic CTL_ (PCTL) replaces quantifiers with probability bounds:
`P>=0.9 [ F target ]` requires at least ninety percent probability of reaching
$t a r g e t;$ `P=? [ F target ]` asks the tool to compute the exact value.
Bounded until `U[<=k]` limits the number of steps. For continuous-time models,
_Continuous Stochastic Logic_ (CSL) adds time-bounded operators such as `F<=t`;
steady-state operators exist but are less central to the examples developed
here.

== PRISM Models: Discrete Time

A DTMC model begins with the keyword `dtmc`. Each _module_ describes one
component with local variables and transitions. Variables are bounded integers
or booleans defining a finite state space. The `init` keyword sets initial
values.

Transitions follow the guarded-update pattern with probabilities:

```prism
dtmc

module main
  s : [0..2] init 0;
  [] s=0 -> 1 : (s'=1);
  [] s=1 -> 0.99 : (s'=0) + 0.01 : (s'=2);
  [] s=2 -> 1 : (s'=s);
endmodule
```

Square brackets before the guard are synchronization labels, empty when no
interaction is needed. Multiple outcomes after `->` list probabilities and
updates separated by `+`. The property `P=? [ F s=2 ]` returns the probability
of eventually reaching the broken state---exactly one for the light-bulb model,
even though the non-probabilistic CTL formula `A F s=2` is false because the
infinite loop between $0$ and $1$ is a valid path with zero probability.

The dice-and-coin model uses two variables: $s$ for the tree position and $d$
for the die face. Fair coin flips assign probability $0.5$ to each branch.
Self-loops on absorbing states ensure well-formed distributions. Verifying
`P=? [ F s=7 & d=6 ]` returns $1/6.$ A parametric query `P=? [ F s=7 & d=x ]`
with $x$ ranging from $1$ to $6$ produces a flat response curve at $1/6$ for
every face.

== Composition, Rewards, and Coordination

Multiple modules compose by shared action labels. PRISM uses _global
synchronization_: all modules offering a transition with label `coin` must fire
together. The coffee machine and user each advance on `coin` and `button`
labels, mirroring the LTS composition from the transition-systems chapter but
with a broadcast semantics rather than binary complements.

When two users compete under global synchronization, both would insert coins
simultaneously---incorrect behavior. A _coordinator module_ with variable `turn`
alternates permission: on `coin` from the machine, the coordinator randomly
enables `coin1` or `coin2`, synchronizing with exactly one user. Competing rules
with the same guard receive equal probability $0.5$ each. Properties such as
`E F (u1=3 & u2=3)` confirm that both users can eventually drink on some path.
`A F (u1=3 & u2=3)` is false because deadlock paths exist.
`P=? [ G (u1!=3 & u2!=3) ]` reports probability $0.5$ of permanent deadlock when
competition resolves unfavorably.

#figure(
  image("../images/chapter8/prism-coffee-machine.drawio.pdf", width: 70%),
  caption: [
    PRISM coffee-machine composition with coordinator and two users; deadlock
    and successful drink states connect LTS composition to probabilistic
    queries.
  ],
) <fig:prism-coffee-machine>

Nested formulas combine reachability with invariants: `E F (u1=3 & A G (u2!=3))`
asks whether the first user can drink while the second never does---a property
expressible only by nesting path quantifiers or their probabilistic analogues.

Competing transitions within a single PRISM rule split probability evenly when
guards overlap and no explicit weights are given: two enabled rules from the
same state each with probability one in isolation become $0.5$ each in the
combined distribution. To specify unequal probabilities, either separate into
distinct guarded outcomes within one rule---as in the light-bulb module---or
introduce auxiliary variables that first sample a discrete choice and then
synchronize on different labels, as in the coordinator extension for biased user
selection.

_Rewards_ attach numeric values to states. Cumulative reward along a path is the
sum of visited state rewards. The query `R=? [ F s=7 ]` returns the expected
number of coin tosses before finishing the dice algorithm---approximately
$3.67,$ reflecting that at least three tosses are needed but looping adds extra
flips on average. Rewards can count events, measure resource consumption, or
encode costs for optimization problems.

== Continuous-Time Models and CSL

CTMC models use the keyword `ctmc` and specify _rates_ instead of probabilities.
The Lotka---Volterra CTMC discretizes prey count $v$ and predator count $p$ into
bounded integers up to $M = 1000,$ yielding roughly one million states.
Reactions become rate-guarded rules:

```prism
ctmc

module main
  v : [0..1000] init 100;
  p : [0..1000] init 100;
  [preyBirth]   v>0 & v<M -> (v'=v+1)   : v*k1;
  [predation]   v>0 & p>0 & p<M -> (v'=v-1; p'=p+1) : v*p*k2;
  [predDeath]   p>0 -> (p'=p-1) : p*k3;
endmodule
```

Reachability without probabilities---`E F p=0`---confirms that extinction is
possible by graph exploration alone. The property `P=? [ F p=0 ]` returns
probability one over unbounded time: unlike the deterministic ODE with sustained
oscillations, stochastic finite populations eventually hit zero predators.
Time-bounded queries such as `P=? [ F<=2.0 p=0 ]` require uniformization of the
CTMC; for one million states this can consume substantial memory and time.

_Statistical model checking_ samples finitely many trajectories instead of full
uniformization. With initial populations $v = p = 100$ and the rates above,
predator extinction is almost certain in the long run, but it typically takes
many time units: bounded probabilities stay near zero for small deadlines and
rise only once the horizon reaches several tens of time units (for example,
roughly $0.25$ by $t = 50$ and $0.70$ by $t = 100$ in a two-thousand-run
simulation). Varying the time bound $t$ produces the response curve below
without exhaustive uniformization. The approach trades exactness for scalability
and is appropriate when qualitative trends matter more than precise
probabilities.

#figure(
  image("../images/chapter8/lotka-smc-extinction.pdf", width: 72%),
  caption: [
    Statistical model-checking estimate of predator-extinction probability
    versus time bound for the Lotka-Volterra CTMC.
  ],
) <fig:lotka-smc-extinction>

== SIR with Vaccination

The epidemic CTMC discretizes susceptible, infected, and recovered counts to
$\{0, dots, 100\},$ scaling kinetic parameters accordingly. Birth adds
susceptibles at rate $mu times M;$ deaths remove each class at rate $mu$ times
the class count; infection fires at rate $beta S I;$ recovery at rate $gamma I.$
Initial conditions set ninety-nine percent susceptible and one percent infected.

Adding vaccination parameter $p$ routes a fraction $p$ of newborns directly to
$R.$ The property `P=? [ F<=50 I=0 ]` asks the eradication probability within
fifty years. Experiments varying $p$ from $0.1$ to $0.9$ show that above roughly
sixty percent vaccination, eradication probability approaches ninety
percent---recovering the threshold analysis from the ODE chapter in a fully
probabilistic setting. Varying the time horizon alongside $p$ produces families
of curves useful for policy comparison.

Nested temporal properties test richer behaviors. A query asking whether
infection can rise to ten percent and subsequently fall to zero requires the
model checker to first identify states satisfying the intermediate condition,
then analyze reachability to extinction from those states. Verification time
grows with property complexity because the model-checking algorithm is
exponential in the size of the formula.

== COVID-19 Case Study: Data and Model

A Tuscany COVID study combined data fitting with probabilistic verification in
October 2020. Daily provincial counts from ARS Toscana recorded identified cases
from February 2020 onward. Reported "infected" individuals were isolated and no
longer contagious; they align more closely with the recovered class $R$ than
with the infectious class $I$ of the SIR model, because real-world testing
identifies and removes transmitters from the susceptible pool.

The modified SIR ODE removes natural birth and death over the short analysis
window and uses infection term $beta p(t) S I$ where $p = 1$ before lockdown and
$p = p_(l o c) in (0, 1)$ during lockdown. Parameters were estimated in two
phases with `scipy.optimize.curve_fit` from the SciPy library. Phase one fits
$beta$ and $gamma$ on pre-lockdown data with $p = 1,$ numerically integrating
the ODE at each optimization step and comparing the sum of identified and
recovered cases to the model's $I + R$ curve. Phase two holds $beta$ and $gamma$
fixed and fits $p_(l o c)$ on post-lockdown data.

Fitted parameters for Pisa province produced close agreement with the first
seventy days of observations. Estimated $beta$ values clustered around
$0.1$---$0.12$ across provinces; $gamma$ implied recovery periods of roughly two
weeks. $p_(l o c)$ varied widely---near one in some provinces, near zero in
others---reflecting model simplicity and the poor quality of early pandemic data
rather than genuine absence of lockdown effect.

#figure(
  image("../images/chapter8/tuscany-covid.pdf", width: 100%),
  caption: [
    Tuscany COVID case study: stylized ODE fit to cumulative cases and PRISM
    infection probabilities under lockdown versus no-lockdown over ten to thirty
    days.
  ],
) <fig:tuscany-covid>

The fitted ODE also yields an estimated curve for true infectious individuals
$I(t),$ invisible in the reported data because unidentified transmitters remain
in the population. This latent trajectory is not a validated forecast but
illustrates how mechanistic models infer hidden state from observable
aggregates.

The two-phase fitting strategy separates identification of transmission and
recovery rates from estimation of lockdown effectiveness. Fitting all parameters
simultaneously on the full dataset would confound the drop in cases caused by
lockdown with the drop caused by depletion of susceptibles. Splitting at the
lockdown date is a modeling choice that assumes an abrupt policy change on a
known day; smoother transitions would require a time-varying $p(t)$ function and
more parameters.

Translation to PRISM discretized the population into $N = 100000$ units,
initially yielding $10^15$ states. Two reductions applied. First, eliminate $S$
via the conservation law $S = N - I - R,$ removing the largest variable from
explicit storage. Second, cap $I$ and $R$ at `bound = 500` because only a small
fraction of the population becomes infected over the analysis horizon. The
reduced model has roughly $250000$ states.

The probability of reaching the cap is negligible, validating the approximation.
Without it, exact verification would be infeasible. This pattern---conservation
elimination plus domain-specific bounding---recurs whenever continuous
populations are discretized for model checking.

Comparative properties compute infection probabilities over ten, twenty, and
thirty days under no-lockdown $(p = 1)$ versus lockdown $(p = p_(l o c))$
scenarios. Lockdown sharply reduces short-horizon infection risk: reaching
seventy infections in ten days has near-zero probability under lockdown but
substantial probability without it. The pipeline---ODE fitting on real data,
translation to CTMC, parameter sweeps in PRISM---demonstrates how deterministic
and probabilistic methods complement each other.

ODEs estimate parameters from observations and predict aggregate trends. Model
checking quantifies scenario probabilities---conditional outcomes under policy
choices---that ODEs alone cannot express as rigorous bounds. The COVID study
aimed at qualitative comparison of interventions rather than precise
epidemiological forecasting, but the methodology generalizes to any setting
where a mechanistic ODE model can be fitted and subsequently discretized.
