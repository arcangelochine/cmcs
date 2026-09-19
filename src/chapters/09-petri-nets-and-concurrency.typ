#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Petri Nets and Concurrency",
  abstract: [
    Multiset rewriting and Petri nets describe concurrent resource flow with
    equivalent expressive power. This chapter develops rewriting semantics,
    Petri net fundamentals, place invariants, the Karp-Miller tree, and
    coverability as polynomial-time alternatives to exact reachability.
  ],
  toc: true,
)

== From Chemical Reactions to Multiset Rewriting

Chemical reaction networks already describe how populations of entities
transform. _Multiset rewriting_ makes that intuition precise and connects it to
the transition systems of Chapter 6.

A _multiset_ over an alphabet $Sigma$ counts how many copies of each symbol are
present, ignoring order. It can be written as a mapping $Sigma -> bb(N)$ or
compactly as a string such as $a^3 b^2 c^3,$ where any permutation of the
letters denotes the same multiset. Multiset union corresponds to string
concatenation: $a^2 b$ combined with $a b^3$ gives $a^3 b^4.$ The set of all
finite multisets over $Sigma$ is written $Sigma^*,$ by analogy with formal
languages.

A _rewriting rule_ $(U, V)$ replaces a sub-multiset $U$ with $V.$ The rule is
_enabled_ in the current multiset $M$ when every symbol of $U$ appears in $M$
with at least the required multiplicity; applying it yields $M - U + V.$ A
_rewriting system_ consists of an alphabet $Sigma,$ a rule set $R,$ and an
initial multiset $M_0.$

Its semantics is a transition system whose states are multisets and whose steps
apply exactly one enabled rule at a time. This is _interleaving semantics_: when
several rules are simultaneously enabled, the choice among them is
non-deterministic and each alternative opens a separate branch. The full
behavior is therefore a reachability graph rather than a single trajectory.

#example-box(title: "Rewriting trace")[
  Let $Sigma = {a, b, c}$ with rules $a b -> c$ and $c -> a b,$ starting from
  $3a, 2b, 3c.$ Applying $a b -> c$ gives $2a, 1b, 4c;$ applying it again gives
  $1a, 5c,$ after which only $c -> a b$ is enabled. At the first step both rules
  were enabled: choosing $c -> a b$ instead would open another branch of the
  reachability tree.
]

#figure(
  image(
    "../images/chapter9/rewriting-reachability-tree.drawio.pdf",
    width: 70%,
  ),
  caption: [
    Reachability tree from initial multiset $3a, 2b, 3c$ showing branching under
    interleaving semantics.
  ],
) <fig:rewriting-reachability-tree>

This construction follows the same pattern as programming-language semantics: a
_syntax_ (alphabet and rules) and a _semantics_ (the generated transition
system). It also makes explicit what was implicit in PRISM modules: integer
variables counting species are multiset multiplicities, and guarded commands are
rewriting rules. Adding rates to rules yields propensities and a CTMC over
multiset states, exactly as in Gillespie simulation; the combinatorial skeleton
of reachable states is unchanged.

Because both PRISM and Gillespie treat competing enabled rules as alternative
branches rather than as a single synchronous update, this chapter adopts
interleaving semantics throughout.

== Petri Nets as a Graphical Formalism

A _Petri net_ is a bipartite graph with two kinds of nodes. _Places_ (circles)
hold _tokens_ representing resource instances. _Transitions_ (bars or
rectangles) represent events that redistribute tokens. Arcs run only between
places and transitions. An arc from place $p$ to transition $t$ carries a
natural number giving how many tokens $t$ consumes from $p;$ an arc from $t$ to
$p$ gives how many tokens $t$ produces in $p.$ Unlabeled arcs carry weight one.

Formally, a net is a pair $(P, T)$ of place and transition sets, where each
transition $t$ has input and output functions $I_t, O_t : P -> bb(N).$ A
_marking_ $M$ assigns a token count to each place, written as a vector
$(M(p_1), dots, M(p_n))$ or sparsely as $p_1, p_2, 2 p_4.$ Transition $t$ is
_enabled_ in $M$ when $M(p) >= I_t(p)$ for every place $p.$ _Firing_ $t$ removes
$I_t(p)$ tokens from each $p$ and adds $O_t(p),$ yielding the successor marking
$M'.$ We write $M -> M'$ for a one-step firing.

A Petri net is thus multiset rewriting drawn with circles and bars: places are
the symbols of the alphabet, markings are multisets, and each transition is a
rule whose input arcs form $U$ and whose output arcs form $V.$ Reading a net as
a transition system, states are markings and steps are firings. A transition
with no input places is always enabled and models spontaneous arrivals.

=== Producer-consumer

A producer cycles between _idle_ and _producing_ states; a consumer cycles
between _waiting_ and _consuming._ A buffer is modeled by a _free slot_ place
holding five tokens initially. The producer enters _producing_ autonomously,
then deposits one `product` by consuming a `slot` token. The consumer fires only
when a `product` is present: the same transition moves it from _waiting_ to
_consuming_ and removes the `product` token. Releasing the `slot` returns the
consumer to _waiting._

Firing is atomic, so consuming a `product` and changing the consumer's state
happen in one indivisible step. Products may accumulate while the consumer is
slow, but `slot` tokens cap the buffer at five. Two producers are modeled simply
by placing two tokens in the _idle_ producer place.

#figure(
  image("../images/chapter9/producer-consumer.drawio.pdf", width: 70%),
  caption: [
    Producer-consumer net with buffer capacity five, showing initial token
    markings.
  ],
) <fig:producer-consumer>

=== Mutual exclusion

Two database clients each cycle through places $I_k$ (idle), $R_k$ (reading),
and $W_k$ (writing), for $k = 1, 2.$ A shared place $M$ holding one token acts
as a lock: entering $W_k$ consumes the token and leaving $W_k$ returns it. Since
the token is unique, no reachable marking has tokens in both $W_1$ and $W_2.$

In multiset terms, adding the lock is equivalent to adding the reactant `mutex`
to every write rule and the product `mutex` to every exit-write rule.

#figure(
  image("../images/chapter9/mutex.drawio.pdf", width: 70%),
  caption: [
    Database mutex net with shared place `mutex` showing initial token markings.
  ],
) <fig:mutex>

=== Spawner

A third recurring example combines a _spawner_ transition with no input places,
which repeatedly adds tokens to a waiting queue $P_1,$ with a mutex place $P_2$
and a critical-section place $P_3$ that together hold exactly one token. This
net has an unbounded place ($P_1$) next to two bounded ones, and will illustrate
the analysis techniques for infinite state spaces below.

When processes are indistinguishable tokens in a single place, fairness cannot
be enforced: nothing prevents the same process from acquiring the lock
repeatedly. Round-robin scheduling requires separate places per process.

#figure(
  image("../images/chapter9/spawner.drawio.pdf", width: 40%),
  caption: [
    Spawner net with unbounded place $P_1$ and two bounded ones, showing initial
    token markings.
  ],
) <fig:spawner>

== Reachability and Boundedness

From the initial marking $M_0,$ the _reachability set_ $"Reach"(N, M_0)$
contains all markings obtainable by finite firing sequences. The _reachability
graph_ has these markings as nodes and firings as edges. When it is finite, it
answers every behavioral question by exhaustive exploration: whether a
_deadlock_ marking (no enabled transition) is reachable, whether a place stays
below a bound, whether two writers can be active simultaneously.

The mutex reachability graph, shown below, is finite. States where one client
writes while the other reads appear; states with both in $W$ do not. No deadlock
occurs because every client can always return to idle.

#figure(
  image("../images/chapter9/mutex-reachability-graph.drawio.pdf", width: 60%),
  caption: [
    Mutex reachability graph from the initial marking; no state has simultaneous
    writes in $W_1$ and $W_2.$
  ],
) <fig:mutex-reachability-graph>

Three properties recur in the analysis:

+ A net is _bounded_ if every place has a uniform upper bound over all reachable
  markings, and _safe_ if that bound is one.
+ Transition $t$ is _semi-live_ if some reachable marking enables it.
+ A marking is _reachable_ if it belongs to $"Reach"(N, M_0).$

The spawner net has an infinite reachability graph: its markings have the form
$(i, 1, 0)$ or $(i, 0, 1)$ for every $i in bb(N),$ since $P_1$ grows without
bound while $P_2$ and $P_3$ alternate. Exhaustive exploration is impossible, yet
all three questions above still have definite answers. The rest of the chapter
develops tools that work on infinite state spaces.

=== Monotonicity

Markings compare componentwise: $M_1 prec.eq M_2$ when $M_1(p) <= M_2(p)$ for
every place. Petri nets are _monotone_: if $M_1 -> M_2$ by firing $t,$ and
$M_3 succ.eq M_1,$ then $t$ is also enabled in $M_3$ and firing it reaches some
$M_4 succ.eq M_2.$ Extra tokens never disable a transition. This simple property
underlies every technique that follows.

Monotonicity also explains why exact reachability is _decidable_ despite
infinite state spaces. Each firing translates the marking along a fixed integer
vector in $bb(N)^k,$ so reachable sets have a regular geometric structure that
symbolic algorithms can exploit. The known procedures, however, require
exponential time in the size of the net. For large models we therefore turn to
three cheaper approximations: place invariants, the Karp-Miller tree, and
coverability.

== Place Invariants

A _place invariant_ generalizes mass conservation. A weight vector
$i : P -> bb(N),$ not identically zero, is a place invariant if the weighted
token count

$ sum_p i(p) dot M(p) $

is the same for every reachable marking $M.$ Since firing must preserve the
weighted sum, transition $t$ is compatible with $i$ exactly when
$sum_p i(p) (O_t (p) - I_t (p)) = 0.$

Collecting these equations for all transitions gives the linear system
$i^T W = 0,$ where $W$ is the _incidence matrix_ with entries
$W(p, t) = O_t (p) - I_t (p),$ the net change in place $p$ when $t$ fires once.
Equivalently $W = W^+ - W^-$ with $W^+$ the output matrix and $W^-$ the input
matrix. Solving $i^T W = 0$ over the rationals and scaling to integers finds
invariants in polynomial time; tools such as Charlie compute the minimal ones
automatically, and positive combinations of minimal invariants are again
invariants.

#example-box(title: "Mutex place invariant")[
  Weights $(1, 1, 1)$ on $(I_1, R_1, W_1)$ give a constant sum of one: client 1
  is always in exactly one of its three states. The symmetric invariant holds
  for client 2, and the weights $(1, 1, 1)$ on $(W_1, W_2, M)$ give another
  constant sum of one: the lock token is either in $M$ or held by one writer. A
  marking with tokens in both $W_1$ and $W_2$ would make this last sum two, so
  it is unreachable.
]

Invariants give two kinds of information. First, if place $p$ appears with
positive weight in some invariant, $p$ is bounded, because the weighted sum caps
its token count. The converse fails: a bounded place may lie outside every
invariant. In the spawner net, solving $i^T W = 0$ yields $i_2 = i_3$ with
$i_1 = 0,$ proving that $P_2$ and $P_3$ always sum to one token while saying
nothing about the unbounded $P_1.$ When every place appears in some invariant,
the whole net is bounded.

Second, invariants prove _non-reachability_: a marking that violates an
invariant is certainly unreachable. The reverse implication does not hold. A
marking satisfying every invariant may still be unreachable, so invariants
over-approximate the reachable set. They suffice for safety proofs, where the
goal is to show a dangerous marking cannot occur, but not for reachability
claims.

#example-box(title: "Weighted cycle")[
  In a net where $p_1 -> p_2,$ $p_3 -> p_4 -> p_1$ with tokens flowing in counts
  $1, 3, 3, 1$ across the stages, weights $3, 1, 1, 2$ keep the total weight at
  $3$ through every firing. A marking with $M(p_3) = 5$ would give weight at
  least $5 > 3,$ so it is impossible.
]

== The Karp-Miller Tree

When the reachability graph is infinite, the _Karp-Miller tree_ produces a
finite summary of it. The construction expands markings breadth-first from
$M_0,$ keeping track of the ancestors along each branch. Whenever a newly
reached marking $M$ dominates an ancestor $M'$ on the same branch
($M succ.eq M'$ with strict inequality in at least one place), monotonicity
implies that the firing sequence from $M'$ to $M$ can be repeated indefinitely,
growing the strictly increased places without bound. Those places are marked
with the symbol $omega$ ("unbounded"), and the branch is not expanded along
firings that would only increase $omega$ components further. Nodes dominated by
nodes already present elsewhere in the tree are also pruned, since their futures
are subsumed.

#figure(
  image("../images/chapter9/karp-miller-omega.drawio.pdf", width: 60%),
  caption: [
    Karp-Miller tree fragment showing the first $omega$ symbol on an unbounded
    place and how coverability summarizes infinite growth.
  ],
) <fig:karp-miller-omega>

For the spawner net, the tree marks $P_1$ with $omega$ while $P_2$ and $P_3$
alternate between zero and one. From the tree one reads off boundedness
directly: places marked $omega$ are unbounded, and the finite components bound
the others. Transition $t$ is semi-live if and only if some node of the tree
enables it.

The set of tree nodes is called the _cover set_ $"Cov".$ It over-approximates
the reachable markings: $omega$ records an infinite ascending chain, not the
exact token counts. A net that produces exactly $0, 3, 6, dots$ tokens in a
place still gets $omega$ there, so the tree suggests four tokens are possible
even though they are not. Nevertheless, every reachable marking is dominated by
some node of the tree, so any marking that lies outside the downward closure of
$"Cov"$ is definitely unreachable.

== Coverability

_Reachability_ asks whether a marking $M$ is reached _exactly_. _Coverability_
asks whether some $M' succ.eq M$ is reached: at least as many tokens as $M$ in
every place. Many practical questions are coverability questions in disguise.
Whether a transition needing two tokens in $p_3$ can ever fire depends only on
whether some reachable marking has _at least_ two tokens there.

Coverability admits an exact and efficient test through the Karp-Miller tree.
Let $overline("Cov") = {M | exists M_0 in "Cov": M prec.eq M_0}$ be the downward
closure of the cover set. The central fact is that this closure coincides with
the downward closure of the reachable set: every reachable marking is dominated
by a cover node, and every cover node dominates some reachable marking. Given a
threshold $B,$ coverability holds if and only if some element of
$overline("Cov")$ is at least $B.$

#example-box(title: "Coverability question")[
  Transition $t$ requires two tokens in place $p_3.$ Form the threshold
  $B = (0, 0, 2, 0, dots)$ and check whether any cover-set node has at least two
  tokens (or $omega$) in $p_3.$ If so, some execution eventually enables $t;$ if
  not, $t$ never fires. Exact reachability of $B$ itself would be a harder,
  exponential question, and is not needed here.
]

Unlike invariant tests, which are sound only for proving non-reachability,
coverability is an if-and-only-if criterion. It is the tool of choice for
enablement and threshold questions on infinite nets.
