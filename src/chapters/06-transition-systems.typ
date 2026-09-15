#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Transition Systems and Compositionality",
  abstract: [
    Transition systems describe how discrete states evolve and support
    exhaustive analysis of all possible behaviors. This chapter introduces
    traces, reachability, variable-based states, guarded update rules, labeled
    synchronization, parallel composition, and the coffee-machine examples
    including deadlocks.
  ],
  toc: true,
)

== Motivation: Beyond Counting Components

Part I modeled systems by counting components in aggregate variables and
evolving them by ODEs or Gillespie SSA. That abstraction is powerful for
homogeneous populations but cannot express that two predators are in different
hunting phases, or that one machine is idle while another is jammed. Transition
systems reintroduce _individualized state_ at the price of a larger, discrete
configuration space.

Population models treat components as interchangeable tallies: adding a prey
increments one variable, adding a predator increments another. This abstraction
ignores _internal state_. Two servers may both be busy, yet one serves a long
job and the other a short one---a distinction invisible to a simple busy
counter. Simulation, whether deterministic or stochastic, explores only finitely
many trajectories. A failure that occurs once in ten million runs may never
appear in a thousand simulations, yet it may be unacceptable in a
safety-critical system such as a nuclear plant controller.

_Transition systems_ address both limitations. Each component has an explicit
state that changes in discrete steps. The full behavior can be explored by graph
search rather than sampled by simulation. Reachability analysis asks whether a
dangerous or desired state can occur on any path from the initial configuration.
These ideas underpin temporal logic and model checking developed in later
chapters. Petri nets and agent-based models, treated in later chapters, build on
the same foundation with richer syntax.

== Transition Systems, Traces, and Reachability

A _transition system_ is a pair $(S, ->)$ where $S$ is a set of states and
$-> subset.eq S times S$ is a transition relation. Write $s -> s'$ when a single
step leads from $s$ to $s'.$ An _initial state_ $s_0 in S$ is designated as the
starting configuration. Transition systems appear throughout computer science as
operational semantics of programming languages and as automata models.

A _trace_ is a sequence $s_0, s_1, dots, s_n$ such that $s_i -> s_(i+1)$ for
each $i.$ The trace $(s_0)$ is minimal. A trace is _maximal_ if it is infinite
or ends in a state with no outgoing transitions. _Reachability_: state $s$ is
reachable if some trace from $s_0$ ends at $s.$ Breadth-first or depth-first
search over the transition graph answers reachability for finite state spaces.
Causality properties---whether winning a match required scoring a goal---can
often be expressed as reachability conditions on augmented state spaces.

When several successors exist from the same state, the model is
_non-deterministic_: all branches are possible, but no probability or scheduling
policy is specified. Non-determinism is not randomness; it means the analyst
considers every admissible choice. A scheduler or environment may resolve the
choice, but the model itself remains agnostic. This differs from probabilistic
models where each branch carries an explicit weight.

== Describing States: Variables and Kripke Structures

States can be described by _atomic propositions_---boolean features that hold or
fail in each configuration. A microwave tracks whether it is started, whether
the door is closed, whether it is heating, and whether an error flag is set.
Each state corresponds to a subset of propositions that are true; the full state
space is the power set of atomic propositions. A _Kripke structure_ formalizes
this: states are labeled with the propositions they satisfy, and transitions
move between labelings.

More generally, a state is an assignment to variables $(x_1, dots, x_n)$ with
domains $D_1, dots, D_n.$ The state space is the Cartesian product
$D_1 times dots times D_n.$ Domains may be booleans, bounded integers, or finite
enumerations. The product structure causes _state-space explosion_: two
variables with a thousand values each already yield one million states, and
adding a third multiplies again.

A soccer match is modeled with natural-number scores `t1` and `t2` and a boolean
`final`. From `<0, 0, false>` three moves are possible: team 1 scores, team 2
scores, or the match ends. The state space is infinite because scores are
unbounded, though only finitely many states are reachable before termination.
Trace `<0,0,false>, <1,0,false>, <1,1,false>, <1,1,true>` is valid but not
maximal; an infinite trace where one team scores forever is maximal but
unrealistic under the termination rule.

A server with queue capacity `N` uses a bounded integer $q in {0, dots, N}$ and
a boolean `busy`. Initially `<0, false>`. An arriving customer when the server
is free sets `busy = true` without changing `q`. A second arrival while busy
increments `q` if `q < N` when `q == N`, further arrivals are rejected. Service
completion decrements `q` or clears `busy` when the queue is empty.

Infinite state spaces require _recursive enumerability_ if exhaustive
verification is to remain algorithmic: there must be a procedure to list states
in a systematic order. Even then, reachability may be undecidable for very
expressive models. The finite-domain guarded systems used in PRISM stay inside
the decidable fragment by bounding every variable.

== Guarded Update Rules

Listing every transition explicitly is impractical for large or infinite
systems. _Guarded update rules_ compactly define infinite families of
transitions:

```
if guard then x' = expression
```

The guard is a boolean condition on current variables; if it holds, the
assignment updates one or more variables to new values. Prime notation `x'`
denotes the value of `x` after the step. This notation resembles chemical
reactions: the guard states when an event is possible, and the update describes
its effect on counts or flags.

The soccer match is specified with three rules sharing the guard
`final == false`: increment `t1`, increment `t2`, or set `final = true`. No rule
has `final == true` as guard, so final states are absorbing. Overlapping guards
on the same state create non-deterministic choice among enabled rules.

The server rules cover four events. When `busy == false`, a new arrival sets
`busy = true`. When `busy == true && q < N`, a new arrival increments `q`. When
`q > 0`, service completion decrements `q`. When `busy == true && q > 0`,
service completion sets `busy = false`. A diagram drawn only for states
reachable from `<0, false>` may omit legal but unreachable configurations such
as `<1, false>` with a waiting customer and an idle server---the full rule set
still permits a transition from that state via the dequeue rule.

== Labeled Transition Systems

A _labeled transition system_ (LTS) annotates each move with an action label:
$s ->^a s'.$ Labels describe interactions between components. The silent action
$tau$ denotes an internal step with no external partner. Labels on diagrams in
earlier examples were informal comments; in an LTS they are part of the formal
model and govern composition.

In _binary synchronization_, each action $a$ has a complement $bar(a).$ A
transition labeled $a$ in one component synchronizes with a transition labeled
$bar(a)$ in another; at most two components interact per step. This resembles
complementary send and receive operations in process calculi. In _global
synchronization_, a single label set is shared and every component offering a
transition with label $a$ must participate simultaneously---a broadcast
semantics common in protocol verification and in the PRISM tool.

PRISM adopts global synchronization natively; binary complements as in the
coffee-machine example must be encoded via coordinator modules when two among
many participants should pair up. The coordinator pattern---introducing a turn
variable and probabilistic or deterministic arbitration---is a standard
engineering workaround when the modeling language's synchronization primitive is
broadcast rather than pairwise.

== Parallel Composition

To compose components $A$ and $B,$ form the product state space combining all
variable assignments. The composition algorithm proceeds in three stages.

First, copy every local transition of each component into the product,
preserving its label. From `<ready, ready>`, the coffee machine alone might move
to `<credit, ready>` on label `insertCoin`, representing interaction with a user
not yet composed.

Second, add synchronized transitions. Whenever $A$ offers $s_A ->^a s'_A$ and
$B$ offers $s_B ->^(bar(a)) s'_B,$ add $(s_A, s_B) ->^tau (s'_A, s'_B).$ The
composed step is internal once both partners are present.

Third, when the system is closed and no further components will be added, remove
all transitions whose labels are not $tau.$ Only internal behavior of the
assembled system remains.

The overall state is described by the tuple of component variables. From the
initial product state, only $tau$-labeled paths are physically realizable in the
closed system.

== The Coffee Machine: Correct and Incorrect Users

A coffee machine requires two coins then a button press. Its states are `ready`,
`credit1`, `credit2`, and `coffee`. The user states are `ready`, `is1`, `is2`,
and `drink`. Synchronization pairs `insertCoin` with `|insertCoin|` and
`pressButton` with `|pressButton|`.

From `<ready, ready>`, inserting a coin moves to `<credit1, is1>` in one
synchronized step. A second coin reaches `<credit2, is2>`. Pressing the button
yields `<coffee, drink>`; the machine then returns to `ready` via a $tau$ step
while the user remains in `drink`. The reachable fragment is a simple chain of
five product states.

A careless user who inserts one coin and immediately presses the button reaches
`<credit1, is1>` with no enabled transitions---a _deadlock_. The machine waits
for a second coin while the user waits to drink. Reachability analysis on the
composed system detects this bad state without running simulations.

#figure(
  image("../images/chapter6/coffee-machine-lts.drawio.pdf", width: 70%),
  caption: [
    Coffee-machine LTS composition: successful purchase path and deadlock when a
    button press follows a single coin insertion.
  ],
) <fig:coffee-machine-lts>

Adding a second correct user creates competition. If user 1 inserts a coin and
user 2 inserts the next, the machine reaches `credit2` while both users are in
`is1`. Each wants to insert another coin, but the machine waits for a button
press. Again the system deadlocks. Two successful interleavings exist---user 1
completes first or user 2 completes first---but two of four coin-insertion
orders lead to deadlock. Model checking on the full product graph proves that
deadlock is reachable, whereas no finite simulation budget guarantees discovery
of a rare failure path.

== Verification and the Path Forward

Simulation explores one behavior at a time; reachability analysis asks whether a
configuration can appear on _any_ path from the initial state. That distinction
matters when failures are rare: a deadlock interleaving in the coffee machine
may never appear in a long simulation run, yet graph search over the reachable
fragment finds it deterministically.

Two property classes recur in verification. _Safety_ requires that something bad
never happens---for example, that the microwave's $e r r o r$ state is
unreachable from the initial configuration. _Liveness_ requires that something
good eventually happens---for example, that every non-deadlock trace in the
coffee protocol eventually reaches a state where the user is in $d r i n k.$
Both reduce to reachability or non-reachability on the same transition graph;
with probabilities added later, they become statements about probability zero or
probability one.

#figure(
  image("../images/chapter6/microwave-lts.drawio.pdf", width: 70%),
  caption: [
    Microwave LTS: the safe path closes the door before starting; pressing
    `start` while the door is open can reach $e r r o r$ non-deterministically.
  ],
) <fig:microwave-lts>

The microwave controller tracks boolean flags such as `doorClosed` and `error`.
From the initial state, closing the door and then starting leads to cooking;
starting with the door open competes with that safe branch and may enter
`error`. Whether `error` is reachable from the start is a safety question
answered by breadth-first search, without enumerating every trace by hand.

The server queue illustrates the same workflow on a smaller graph. From
`<0, false>`, arrivals and service steps generate only four reachable
configurations; states such as `<1, false>` may be legal for the rule set but
unreachable from the intended initial configuration.

#example-box(title: "Server queue with capacity two")[
  With capacity $N = 2,$ variables $q in {0, 1, 2}$ and $b u s y in {t r u e,
    f a l s e},$ and initial state `<0, false>`, list which of the eight pairs
  `<q, busy>` are reachable. Confirm that `<2, false>` is reached when two
  customers arrive while the server is busy and service completes twice. Compare
  the reachable subgraph below with the full rule specification: unreachable
  configurations should not appear in the diagram even if a guard permits them
  in isolation.
]

#figure(
  image("../images/chapter6/server-queue.drawio.pdf", width: 70%),
  caption: [
    Reachable subgraph for the server queue with $N = 2,$ labeled by `<q, busy>`
    and transitions for arrival, enqueue, and service.
  ],
) <fig:server-queue-graph>

Compositional models multiply state spaces: a machine and one user with four
states each yield sixteen product pairs before pruning; a second user yields
sixty-four triples. Breadth-first search need not visit the full product---only
the reachable fragment, often much smaller. The coffee-machine deadlock shows
why that matters: neither component is faulty alone, yet their interaction can
halt the system. Serializing access with a coordinator removes some deadlocks at
the cost of concurrency, a pattern familiar from mutexes and transaction
protocols.

The modeling stack developed so far moves from aggregate counts in Part I to
explicit configuration and labeled interaction here. The next chapter replaces
bare non-determinism with transition probabilities, producing Markov chains.
PRISM and temporal logic then support quantitative questions---such as the
probability of deadlock under a random scheduler---on finite models built from
the same guarded-update syntax. Petri nets, treated later, offer an alternative
graphical notation for concurrent events with comparable reachability goals.
