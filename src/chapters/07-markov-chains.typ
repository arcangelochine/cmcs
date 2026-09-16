#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Markov Chains and Probabilistic Reachability",
  abstract: [
    Markov chains replace non-deterministic branching with probability
    distributions over transitions. This chapter defines discrete-time and
    continuous-time Markov chains, path probabilities, reachability via linear
    systems, embedded and uniformized chains, and the link to chemical-reaction
    propensities.
  ],
  toc: true,
)

== From Non-Determinism to Probability

In a non-deterministic transition system, several successors may be enabled from
one state with no quantitative guidance. _Probabilistic_ choice assigns a
distribution over those successors: each outgoing branch carries a probability
and the probabilities sum to one. _Stochastic_ choice, used in continuous time,
assigns a _rate_ to each competing transition; the fastest event wins a race
whose timing follows an exponential distribution.

These two notions correspond to _discrete-time Markov chains_ (DTMCs) and
_continuous-time Markov chains_ (CTMCs). Both extend transition systems with
quantitative information and support _probabilistic reachability_: computing the
probability of eventually reaching a target state, possibly within a time bound.
The dice-and-coin algorithm, the light-bulb failure model, and chemical reaction
networks all admit Markov chain representations.

== Discrete-Time Markov Chains

Markov chains are _memoryless_ at the level of states: the probability of the
next step depends only on the current state, not on the full history of prior
states. This Markov property matches the memoryless exponential waiting times in
CTMCs and justifies multiplying step probabilities along a path.
History-dependent models require enlarging the state space to include sufficient
statistics of the past---a standard modeling technique when the Markov
assumption fails.

A DTMC consists of a finite or countable state set $S$ and a _transition
probability matrix_ $P$ where $P(s, s') in [0, 1]$ is the probability of moving
from $s$ to $s'$ in one step, and $sum_(s') P(s, s') = 1$ for every $s.$ Every
state must have at least one outgoing transition; states that would otherwise be
deadlocked receive a self-loop with probability one. This constraint eliminates
deadlock in the probabilistic setting: a broken light bulb stays broken with
probability one rather than having no exit.

The initial configuration may be a single state or a distribution over states. A
_path_ $s_0, s_1, dots, s_n$ is valid when $P(s_i, s_(i+1)) > 0$ for each $i.$
The _path probability_ is the product of step probabilities, because successive
choices are independent:

$ "Prob"(s_0, dots, s_n) = product_(i=0)^(n-1) P(s_i, s_(i+1)) $

The probability of reaching target state $t$ from $s_0$ is the sum of path
probabilities over all paths from $s_0$ to $t.$ This sum may be infinite when
loops allow arbitrarily long detours, requiring careful summation or the
equation-based method below.

Consider a light bulb with states `off`, `on` and `broken`. From `off` the bulb
turns on with probability one. From `on` it returns to `off` with probability
$0.99$ or breaks with probability `0.01`. From `broken` it stays broken with
probability one.

Paths to `broken` include the direct step `on -> broken` with probability
$0.01,$ and paths that cycle `off <-> on` finitely many times before breaking.

#figure(
  image("../images/chapter7/light-bulb-dtmc.drawio.pdf", width: 70%),
  caption: [
    Light-bulb DTMC with transition probabilities and absorbing `broken` state
    highlighted.
  ],
) <fig:light-bulb-dtmc>

Summing over cycle counts yields an infinite series
$0.01 + 0.99 times 0.01 + 0.99^2 times 0.01 + dots,$ which converges to one.

An alternative uses the _complement event_. The only way never to reach `broken`
is to cycle forever between `off` and `on`. That infinite path has probability
$1 times 0.99 times 1 times 0.99 times dots.$ Each factor $0.99$ arises from
choosing `on -> off` rather than `on -> broken`. The infinite product tends to
zero, so the probability of eventual breakdown is one minus zero equals one.
This trick simplifies analysis when a single avoidance path dominates the
complement.

A fair six-sided die can be simulated by tossing a fair coin. Build a binary
tree of coin flips; leaves labeled $1$ through $6$ are absorbing, while internal
nodes loop back when extra flips would create more than six outcomes. Each leaf
is reached with probability $1/6$ because every complete path through three fair
branches contributes $1/2^3$ and the loop structure redistributes mass evenly
across the six outcomes.

Representing this procedure as a DTMC requires self-loops on absorbing states
and intermediate nodes for partial outcomes. Verifying that each face has
probability exactly $1/6$ is a reachability computation over infinitely many
paths---exactly the problem probabilistic reachability solves systematically.

#figure(
  image("../images/chapter7/dice-coin-tree.drawio.pdf", width: 70%),
  caption: [
    Dice-and-coin algorithm as a DTMC: internal nodes loop back while absorbing
    leaves $1$ through $6$ each receive probability $1/6.$
  ],
) <fig:dice-coin-tree>

== Reachability as a Linear System

Define $x_s$ as the probability of eventually reaching target $t$ starting from
$s.$ The base case is $x_t = 1.$ For $s != t,$

$ x_s = sum_(s') P(s, s') x_(s') $

This is a linear system with one equation per state, constructed syntactically
from the transition graph without enumerating paths.

For the light bulb with target `broken`, renaming $x_"broken" = 1,$
$x_"on" = x_1,$ $x_"off" = x_0:$

$ x_1 = 0.01 + 0.99 x_0 $
$ x_0 = x_1 $

Substituting gives $x_1 = 0.01 + 0.99 x_1,$ hence $x_1 = 1$ and $x_0 = 1.$

The same system in matrix form is $(I - P') bold(x) = bold(b)$ where $P'$
excludes the absorbing row and column for the target, and $bold(b)$ collects
direct transition probabilities into the target. Gaussian elimination or
iterative methods solve sparse systems arising from large Markov chains. PRISM
constructs and solves these systems automatically when evaluating
`P=? [ F target ]` on a DTMC.

For the dice example targeting face $6,$ write equations only for states that
can reach the target. States with no path to face $6$ receive $x_s = 0.$
Back-substitution from the absorbing state confirms $x_0 = 1/6$ without summing
infinite path families.

== Continuous-Time Markov Chains

A DTMC advances in _discrete steps_: at each step the system is in exactly one
state, then instantly jumps to a successor chosen according to probabilities in
$P.$ A _continuous-time Markov chain_ (CTMC) separates two questions that a DTMC
bundles together:

+ _How long_ does the system stay in the current state before anything changes?
+ _Where_ does it go when a change finally happens?

In a CTMC, time flows continuously. The system sits in state $s$ for a random
_duration_, then makes one jump to a successor. There is no fixed clock tick.

=== Rates, not probabilities

Each possible jump $s -> s'$ carries a non-negative _rate_ $R(s, s') >= 0.$ Such
rate can be interpreted as an _intensity_: the higher the rate, the sooner that
jump tends to occur, and the more often it is chosen when several jumps compete.

Rates are _not_ probabilities. They do not need to sum to one. From a state with
rates $2$ and $3,$ the numbers $2$ and $3$ mean only that the second jump is one
and a half times as "fast" as the first.

Summing all outgoing rates defines the _exit rate_

$ q(s) = sum_(s') R(s, s'). $

This single number controls how quickly the system _leaves_ $s,$ regardless of
which successor is taken.

=== What happens in state $s$: a race

Picture every enabled jump out of $s$ as an independent alarm clock. The jump
with rate $R(s, s')$ rings after a random delay drawn from an exponential
distribution with parameter $R(s, s').$ All clocks start when the system enters
$s.$ The _first_ clock to ring wins: the system jumps along that edge, all other
clocks are discarded, and new clocks start in the new state.

Two facts make this race tractable:

+ The waiting time until _some_ jump fires is exponential with parameter
  $q(s) = sum_(s') R(s, s').$ Its mean is $1 / q(s).$
+ Given that a jump occurs, the next state is $s'$ with probability
  $R(s, s') / q(s).$

So each CTMC state is governed by one waiting-time distribution and one discrete
choice distribution. The continuous-time story is the product of these two
rules.

#example-box(title: "Three-state CTMC step by step")[
  Suppose the system is in $s_0$ with two competing jumps:

  + $s_0 -> s_1$ with rate $R(s_0, s_1) = 2$
  + $s_0 -> s_2$ with rate $R(s_0, s_2) = 3$

  _Step 1---exit rate._ $q(s_0) = 2 + 3 = 5.$ On average the system leaves $s_0$
  after $1/5 = 0.2$ time units.

  _Step 2---sample the waiting time._ Draw $tau$ from an exponential
  distribution with rate $5.$ In Gillespie notation, draw $r in (0, 1]$ and set
  $tau = -(1/5) ln(r).$ The system remains in $s_0$ during the entire interval
  $[0, tau).$

  _Step 3---choose the winner._ When the clock rings at time $tau,$ go to $s_1$
  with probability $2/5$ and to $s_2$ with probability $3/5.$ The higher rate
  does not guarantee victory on any single race, but it wins more often on
  average.

  _Step 4---repeat._ After the jump, recompute rates in the new state, start
  fresh exponential clocks, and continue.

  If the system lands in $s_2$ and that state has no outgoing jumps (or only a
  rate-zero self-loop), it stays there forever: $s_2$ is _absorbing._
]

#figure(
  image("../images/chapter7/ctmc-race.drawio.pdf", width: 50%),
  caption: [
    CTMC race semantics in $s_0$: exit rate $q(s_0) = 5,$ mean holding time
    $1/5,$ and successor probabilities $2/5$ and $3/5$ proportional to rates.
  ],
) <fig:ctmc-race>

=== Link to Gillespie simulation

Chapter 5 described the same mechanism for chemical reactions. Each reaction has
a propensity $a_mu;$ the total propensity is $a_0 = sum_mu a_mu.$ Gillespie
samples $tau = -(1/a_0) ln(r)$ and selects reaction $mu$ with probability
$a_mu / a_0.$ A reaction network therefore defines a CTMC whose states are
molecule-count vectors, whose jumps are reactions, and whose rates are
propensities. Gillespie _simulates_ one path through that CTMC; model checking
_can integrate_ over all paths when the state space is small enough.

The correspondence is direct:

#table(
  columns: (1fr, 1fr),
  inset: 8pt,
  stroke: 0.5pt,
  [*CTMC notion*], [*Gillespie*],
  [rate $R(s, s')$], [propensity $a_mu$],
  [exit rate $q(s)$], [total propensity $a_0$],
  [holding time $tilde.op "Exp"(q(s))$], [waiting time $tau = -(1/a_0) ln r$],
  [jump probability $R(s,s')/q(s)$], [selection probability $a_mu / a_0$],
)

=== Why exponentials?

The exponential distribution is _memoryless_: if the system has already waited
$s$ time units in state $s$ without leaving, the remaining waiting time has the
same distribution as if the wait had just started. That matches the Markov
property at the level of states---the future depends only on the current state,
not on how long the system has been there.

If independent exponentials have rates $lambda_1, dots, lambda_n,$ then the
minimum is exponential with rate $lambda_1 + dots + lambda_n.$ This is why all
competing jumps in $s$ can be replaced by one clock with rate $q(s)$ for
sampling the departure time, followed by a discrete choice among successors.

== Embedded and Uniformized Chains

A CTMC carries two kinds of information: _which_ jumps are possible and _how
fast_ time passes. Sometimes only one of these matters.

_Time-independent reachability_ asks whether a target is reached _eventually,_
with no deadline. Waiting times are irrelevant: only the order of visited states
counts. The _embedded DTMC_ keeps the discrete choices and discards the clocks,
setting

$ P_(e m b)(s, s') = R(s, s') / q(s) quad "(for" q(s) > 0")." $

These are exactly the winner probabilities from the race in each state. From
$s_0$ in the three-state example, $P_(e m b)(s_0, s_1) = 2/5$ and
$P_(e m b)(s_0, s_2) = 3/5.$ Reachability on this embedded chain answers
questions such as "does the system ever reach $s_2$?" using the same linear
system as in the DTMC section.

_Time-bounded reachability_ asks whether a target is reached _before time $T$._
Here waiting times matter. The _uniformized_ chain approximates the CTMC by a
DTMC with a fixed time step $Delta = 1/Q,$ where $Q >= max_s q(s).$ In each
step, jump $s -> s'$ occurs with probability $R(s, s') / Q,$ and the system
stays put with probability $1 - q(s) / Q.$ Multiplying the number of steps by
$Delta$ estimates elapsed continuous time. Larger $Q$ gives finer time
discretization and better accuracy.

For the light bulb modeled in continuous time, "break eventually" is an embedded
question; "break within one month" is a bounded-time question and needs
uniformization or a dedicated CTMC solver.
