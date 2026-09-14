#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Chemical Reactions and Stochastic Simulation",
  abstract: [
    Chemical reaction notation is a compact modeling language tightly linked to
    differential equations and to stochastic simulation. This chapter develops
    reaction syntax, the law of mass action, equilibrium and conservation,
    bidirectional translation to polynomial ODEs, and the Gillespie stochastic
    simulation algorithm with worked examples.
  ],
  toc: true,
)

== A Modeling Language for Interactions

A _chemical reaction_ describes how a multiset of reactants is transformed into
a multiset of products. Species are written as symbols---$A,$ $B,$
$H_2 O$---without commitment to real chemistry. The general form is

$ l_1 S_1 + dots + l_r S_r ->^[k] l'_1 P_1 + dots + l'_gamma P_gamma $

where $l_i$ and $l'_j$ are stoichiometric coefficients and $k > 0$ is a kinetic
constant measuring how often the transformation occurs. Reversible reactions add
a backward rate $k_(-1)$ written as an index, not a negative exponent.

Chemists measure quantities as _concentrations_ $[S]$---moles per liter---so
state variables are real numbers. The appeal of reactions as a general modeling
language is that the same notation supports both continuous ODE analysis and
discrete stochastic simulation.

Five basic patterns recur across applications:

+ _Synthesis_: $-> S$ produces a species from nothing.
+ _Degradation_: $S ->$ removes it.
+ _Transformation_: $S -> P$ changes state.
+ _Binding_: $S_1 + S_2 -> P$ merges two entities.
+ _Catalysis_: $E + S -> E + P$ transforms $S$ into $P$ while recovering the
  enzyme $E.$

Enzyme kinetics illustrates decomposition into elementary steps. The single
catalytic reaction $E + S -> E + P$ can be refined into binding $E + S <=> E S$
followed by conversion $E S -> E + P.$ Reactions are _reversible_ in principle;
one direction may be energetically negligible and omitted in practice.

== The Law of Mass Action

The _law of mass action_ is an empirical rule: in a well-stirred solution, the
rate at which a reaction fires is proportional to the product of reactant
concentrations raised to their stoichiometric powers:

$ "rate" = k product_i [S_i]^(l_i) $

The constant $k$ modulates how likely a meeting of reactants results in
transformation. Because concentrations change over time, rates change as well.

#example-box(title: "Forward and backward rates")[
  For $2 H_2 + O_2 <=> 2 H_2 O$ with $k_f = 5$ and $k_r = 0.5,$ at $[H_2] = 10,$
  $[O_2] = 16,$ $[H_2 O] = 30:$

  + Forward rate: $5 times 10^2 times 16 = 8000.$
  + Backward rate: $0.5 times 30^2 = 450.$

  Forward transformation dominates initially even though $k_r < k_f,$ because
  kinetic constants are not directly comparable until multiplied by the
  appropriate concentration products.
]

When several reactions act on the same species, each contributes a signed term
to that species' equation: negative if consumed, positive if produced, with
magnitude equal to the rate times the stoichiometric coefficient of that species
in the reaction.

== Dynamic Equilibrium and Conservation

In a reversible reaction, reactants are continuously converted to products and
back. The system reaches _dynamic equilibrium_ when forward and backward rates
are equal, so concentrations stabilize even though reactions never stop. For
$A + B <=> C$ with $k_f = 1$ and $k_r = 0.2,$ equilibrium satisfies
$k_f [A][B] = k_r [C].$

Starting from $[A]_0 = 10,$ $[B]_0 = 15,$ $[C]_0 = 2,$ the forward rate
$1 times 10 times 15 = 30$ exceeds the backward rate $0.2 times 2 = 0.4,$ so $A$
and $B$ fall while $C$ rises. Stoichiometry imposes conservation laws: every
reaction that consumes one $A$ and one $B$ to produce one $C$ preserves
$[A] + [C]$ and $[B] + [C].$ With $[A]_0 + [C]_0 = 12$ and $[B]_0 + [C]_0 = 17,$
substitute $[A] = 12 - [C]$ and $[B] = 17 - [C]$ into the equilibrium condition
to obtain a quadratic in $[C]$ alone. One root gives negative concentrations and
is discarded; the admissible root $[C] approx 6.7$ yields $[A] approx 5.3$ and
$[B] approx 10.3,$ where both rates equal approximately
$1.1.$

#figure(
  image("../images/chapter5/reversible-equilibrium.pdf", width: 70%),
  caption: [
    Concentration trajectories for $A + B <=> C$ with $k_f = 1,$ $k_r = 0.2,$
    starting from $([A]_0, [B]_0, [C]_0) = (10, 15, 2).$
  ],
) <fig:reversible-equilibrium>

For larger networks, equilibrium is rarely computed by hand. Numerical
integration of the ODE system finds equilibria automatically. Tools such as
Dizzy provide a simple graphical interface for writing reactions and running ODE
or stochastic solvers on the same model file.

== From Reactions to ODEs

One differential equation is written per species. Each reaction in which a
species appears contributes a signed term: the mass-action rate, multiplied by
the stoichiometric coefficient of that species in the reaction.

For water formation $2 H_2 + O_2 <=> 2 H_2 O:$

$ dot([H_2]) = - 2 k_f [H_2]^2 [O_2] + 2 k_r [H_2 O]^2 $
$ dot([O_2]) = - k_f [H_2]^2 [O_2] + k_r [H_2 O]^2 $
$ dot([H_2 O]) = + 2 k_f [H_2]^2 [O_2] - 2 k_r [H_2 O]^2 $

/*

For the enzymatic cycle $E + S <=> E S,$ $E S -> E + P,$ four equations track
$E,$ $S,$ $E S,$ and $P.$ The equation for $E$ alone contains four signed terms
because $E$ participates in every step.

#figure(
  image("../images/chapter5/enzyme-network.pdf", width: 70%),
  caption: [
    Enzymatic reaction network $E + S <=> E S,$ $E S -> E + P,$ with rate
    constants $k_f,$ $k_r,$ and $k_c.$
  ],
) <fig:enzyme-network>

*/

#example-box(title: "Guided example")[
  Suppose to have the following reaction network:

  $
    2 A <==>^(k_1)_(k_2) C,
  $

  $
    C -->^(k_3) A + B
  $

  We want to translate this reaction network into a set of ODEs. We start by
  looking at the equation for $dot([A])$:

  $
    dot([A]) = -2 k_1 [A]^2 + 2 k_2 [C] + k_3 [C]
  $

  the first term $-2 k_1 [A]^2$ comes from the reaction $2 A -->^(k_1) C$, where
  two $A$ are consumed to produce one $C,$ hence $A$ is depleted with a rate of
  $2 * "mass action rate".$ The second term $2 k_2 [C]$ comes from the reaction
  $C -->^(k_2) 2 A$, where one $C$ is consumed to produce two $A,$ hence $A$
  increases at twice the mass-action rate $k_2 [C].$ The third term $k_3 [C]$
  comes from the reaction $C -->^(k_3) A + B$, where one $C$ is consumed to
  produce one $A,$ hence $A$ increases at the mass-action rate
  $k_3 [C].$

  The equations for $dot([B])$ and $dot([C])$ follow the same bookkeeping:

  $
    dot([B]) = + k_3 [C]
  $

  $
    dot([C]) = - k_3 [C] - k_2 [C] + k_1 [A]^2
  $
]

== From ODEs to Reactions

The inverse translation starts from a polynomial ODE and reconstructs elementary
reactions whose mass-action kinetics reproduce it. The procedure is:

+ Expand each $dot(x_i)$ as a sum of signed monomials.
+ Match each positive term in $dot(x_i)$ to a reaction that _produces_ $X_i$ at
  the corresponding mass-action rate (for example, $+r V$ suggests $V -> 2V$
  with $k = r$).
+ Match each negative term to a reaction in which $X_i$ is a _reactant_ and is
  consumed (for example, $-k V P$ suggests $V + P -> 2P$ with $k$).
+ Check that the same reaction accounts consistently for every species it
  touches: one firing may decrease $V$ and increase $P$ simultaneously.

#example-box(title: "Lotka-Volterra")[
  Chapter 4 gives the prey--predator ODEs $dot(V) = r V - a b V P$ and
  $dot(P) = -s P + a b V P.$ Read each signed term and propose one elementary
  reaction:

  + $+r V$: prey reproduction $V -> 2V$ with $k = r$ (net gain of one prey per
    event).
  + $-a b V P$ in $dot(V)$ and $+a b V P$ in $dot(P)$: a single encounter step
    $V + P -> 2P$ with $k = a b$ (one prey consumed, predator count rises by
    one).
  + $-s P$: predator mortality $P ->$ with $k = s.$

  Reconstructing the ODE confirms the match: $V -> 2V$ contributes $+r V$;
  $V + P -> 2P$ contributes $-a b V P$ to $dot(V)$ and $+a b V P$ to $dot(P)$;
  $P ->$ contributes $-s P.$ The network is therefore an event-based restatement
  of the ODE model, ready for stochastic simulation.
]

#example-box(title: "SIR epidemic model")[
  The basic SIR ODEs from Chapter 4 are $dot(S) = -beta S I,$
  $dot(I) = beta S I - gamma I,$ and $dot(R) = gamma I.$ Two elementary
  reactions suffice:

  + $-beta S I$ in $dot(S)$ and $+beta S I$ in $dot(I)$: infection $S + I -> 2I$
    with $k = beta$ (one susceptible becomes infected).
  + $-gamma I$ in $dot(I)$ and $+gamma I$ in $dot(R)$: recovery $I -> R$ with
    $k = gamma.$

  The infection step is the same pattern as predation in Lotka-Volterra: one
  species is consumed and the other gains one individual. Recovery is a simple
  transformation $I -> R.$

  Extensions follow the same recipe term by term. Demography adds birth $-> S$
  with $k = mu$ and death $S ->,$ $I ->,$ $R ->$ each with $k = mu.$ Lockdown
  introduces a new compartment by adding $S ->[rho] L$ without rewriting the
  infection or recovery steps.
]

#example-box(title: "Logistic growth")[
  The logistic ODE $dot(n) = r n (1 - n/K)$ expands to
  $dot(n) = r n - (r/K) n^2.$ Two elementary reactions encode the two terms:

  + Growth: $N -> 2N$ with rate constant $r$
  + Crowding: $N + N -> N$ with rate constant $r/K$

  One growth event adds one individual ($+r n$ in $dot(n)$). One crowding event
  consumes two $N$ and produces one (net loss of one), giving $-(r/K) n^2.$ The
  reaction $N + N -> 2N$ would be a _null step_ for the population count and
  cannot produce the quadratic term.

  At a positive steady state, $dot(n) = 0$ gives $r n = (r/K) n^2,$ hence
  $n = K,$ the carrying capacity.
]

Mass action imposes a syntactic constraint: a species whose concentration
decreases must appear as a reactant in some reaction. A term such as $-y$ in
$dot(x)$ without $x$ among the reactants cannot arise from mass-action kinetics.
Polynomial ODEs and reaction networks are therefore equivalent in _behavior_
when a translation exists, but not in _expressive power_. In practice, the
population models from Part I always admit a reaction representation.

== Why Stochastic Simulation?

ODEs describe average concentrations and produce a single deterministic
trajectory. When molecule counts are small, this average behavior misrepresents
the system. With five molecules, a concentration of $4.5$ introduces a ten
percent relative error, and extinction events---predators or infected
individuals reaching zero---cannot occur in a continuous model. A single
molecule degrading from $1$ to $0$ is a discrete jump, not a slow decline along
a real-valued curve.

Repeating an experiment with very few molecules yields different completion
times: sometimes reactants meet quickly, sometimes they wander before reacting.
When counts are large, the law of large numbers justifies ODEs: fluctuations
average out and the global trend aligns with the differential equation. When
counts are small, one must track _integer_ populations and _probabilities_.

#figure(
  image("../images/chapter5/ode-vs-ssa.pdf", width: 70%),
  caption: [
    ODE mean trajectory and several SSA sample paths for a birth-death network
    at low counts, illustrating discrete jumps and convergence at larger
    population sizes.
  ],
) <fig:ode-vs-ssa>

== The Gillespie Algorithm

The Gillespie _direct method_ is the reference stochastic simulation algorithm
(SSA). For each reaction $R_mu$ associate a constant $c_mu$ analogous to the
kinetic constant $k.$ The _propensity_ $a_mu$ multiplies $c_mu$ by the number of
distinct reactant combinations in the current state. For $S_1 + S_2 -> P$ with
counts $x_1$ and $x_2,$ the combination count is $x_1 x_2$ and $a = c x_1 x_2.$
For $2 S_1 -> S_1 + S_2$ with count $x_1,$ the factor is the binomial
coefficient $binom(x_1, 2) = x_1(x_1 - 1)/2;$ choosing $c = 2k$ recovers the ODE
rate in the large-count limit.

Each reaction fires as a Poisson process with rate equal to its propensity. The
waiting time until the next event is exponentially distributed with parameter
$a_0 = sum_mu a_mu;$ the mean waiting time is $1/a_0.$ The _memoryless property_
of the exponential distribution allows regeneration without history. To select
which reaction fires, choose $R_mu$ with probability $a_mu / a_0.$

_Algorithm (Direct Method)._ Initialize count vector $bold(x)$ and clock
$t = 0.$ Repeat: compute all propensities and $a_0;$ draw $tau = -(1/a_0) ln(r)$
with $r$ uniform in $(0,1];$ advance $t <- t + tau;$ select reaction $R_mu$ with
probability $a_mu / a_0;$ update $bold(x);$ stop when $t$ exceeds the horizon or
all propensities are zero.

#example-box(title: "One SSA iteration")[
  Reactions $A -> B + C$ with $c_1 = 2$ and $B + C -> A$ with $c_2 = 0.1,$
  starting from $(A, B, C) = (10, 5, 20).$ Propensities: $a_1 = 20,$ $a_2 = 10,$
  $a_0 = 30.$ Draw $r = 0.37;$ then $tau = -(1/30) ln(0.37) approx 0.033.$ Draw
  $u = 18$ uniform in $[0, 30);$ cumulative sums $20 < 18$ fails,
  $20 + 10 = 30 >= 18,$ so reaction 2 fires. Update: $A$ becomes $11,$ $B$
  becomes $4,$ $C$ becomes $19;$ set $t = 0.033.$ Recompute: $a_1 = 22,$
  $a_2 = 0.1 times 4 times 19 = 7.6,$ $a_0 = 29.6.$ Repeating for ten time units
  yields a piecewise-constant staircase trajectory.
]

#figure(
  image("../images/chapter5/gillespie-staircase.pdf", width: 70%),
  caption: [
    Staircase SSA trajectory with exponentially distributed waiting times
    between reaction firings.
  ],
) <fig:gillespie-staircase>

Exponential draws use the _inversion method_: if $r$ is uniform in $(0,1],$ then
$tau = -(1/lambda) ln(r)$ is exponential with rate $lambda.$ Reaction selection
draws $u$ uniform in $[0, a_0)$ and scans propensities cumulatively until the
partial sum exceeds $u.$

== ODE versus SSA in Practice

For an enzymatic network with moderate counts, SSA trajectories match ODE
solutions up to visible noise; averaging many runs recovers the deterministic
curve. For Lotka-Volterra at the deterministic equilibrium, a single SSA step
immediately perturbs the state and triggers irregular oscillations absent from
the ODE---behavior arguably more realistic for finite populations.

When gene activity is modeled discretely---a gene is either active or
blocked---SSA captures on-off switching that ODEs smooth into continuous drift
between zero and one. The qualitative dynamics can differ fundamentally, not
merely by noise amplitude.

SSA simulates one reaction per step and must be repeated for statistics, making
it costly when propensities are large and $tau$ is tiny. Variants such as
Gibson-Bruck, $tau$-leaping, and hybrid ODE/SSA schemes improve efficiency at
the cost of approximation; the direct method remains the conceptual reference.

Use ODEs when populations are large, extinction is not the focus, and a single
representative trajectory suffices. Use SSA when counts are small, discrete
on-off behavior matters, or the distribution of outcomes across runs is
informative. When the state space is finite and moderate, the CTMC built from
reactions can be analyzed by model checking rather than simulation---the topic
of Chapters 7 and 8.

Two skills worth mastering: constructing mass-action ODEs from a reaction
network, and computing the total propensity $a_0$ plus the selected reaction at
each Gillespie step. Together, reactions, ODEs, and SSA form the modeling stack
of Part I, to be extended by transition systems, Markov chains, and
probabilistic model checking in the chapters that follow.
