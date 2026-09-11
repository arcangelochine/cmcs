#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Introduction to Complex Systems and Computational Modeling",
  abstract: [
    This chapter defines complex systems, computational models of dynamical
    systems, and the knowledge-driven modeling approach used throughout the
    book. It contrasts top-down mathematical models with bottom-up
    individual-based models and explains why formal, executable models are
    needed for analysis and prediction.
  ],
  toc: true,
)

== Complex Systems and Emergent Behavior

A _complex system_ is a dynamical system composed of many simple components
whose _interactions_ produce _emergent behavior_ at the global level. The
components themselves may be trivial; the complexity arises from how they
interact, not from the internal sophistication of each part. The scientific
study of such systems asks how local rules among simple agents give rise to
global patterns that no single component explicitly encodes.

Bird flocking illustrates the pattern clearly. Each bird flies toward its
destination individually, yet when birds fly together they follow a common path
and adopt a V-shaped formation. The flock is the global system; birds are
components. Individual behavior is local navigation toward a goal. Interactive
behavior includes staying close to neighbors and following a leader that may
change over time. Emergent behavior is the stable formation itself: if each bird
flew alone from point A to point B, the paths would scatter; together they
converge on a shared trajectory and geometry. There is no central coordinator
issuing commands; the formation arises from pairwise interactions.

Cell mitosis shows the same structure at a molecular scale. Proteins synthesize
and degrade in isolation, but chemical interactions synchronize replication and
division into two identical daughter cells. The complex system is the cell;
components are molecules such as proteins and DNA. Individual behavior is
synthesis followed by degradation. Interactive behavior is chemical reaction and
state change among molecules. Emergent behavior is the coordinated four-phase
division that ensures each daughter cell receives exactly one copy of every
chromosome. Understanding these interactions is essential for drug design: a
therapy that disrupts a single protein interaction can prevent uncontrolled
division.

Ant colonies forage through _stigmergy_. An ant leaves the nest and wanders
randomly until it finds food. Returning to the nest, it deposits pheromone on
the ground. Other ants, detecting the trail, follow it to the food source,
deposit more pheromone on the return path, and strengthen the signal. No ant
instructs another directly; the environment stores the communication. When the
food is exhausted, pheromone stops accumulating and the trail fades, prompting
renewed random search. The complex system is the colony; components are ants;
emergent behavior is the formation of stable foraging trails.

Urban traffic produces queues when cars brake to avoid collisions on
capacity-limited roads mediated by semaphores. The complex system is the road
network; components are vehicles. Individual behavior is driving toward a
destination while obeying traffic rules. Interactive behavior is braking when a
vehicle ahead slows. Emergent behavior is queue formation at bottlenecks. The
environment provides roads with finite capacity and semaphores that regulate
flow, mediating interactions among drivers who never communicate directly.

Social networks produce trends, opinion clusters, and rapid information spread
when members post and share content. The complex system is the platform;
components are user profiles. Individual behavior is passive presence on the
network. Interactive behavior is posting, sharing, and reacting to content.
Emergent behavior includes trending topics and community formation. Unlike ants
on a physical surface, the environment here is a logical graph: edges represent
follower relationships, and hub nodes with many connections disproportionately
amplify reach. Such networks often exhibit power-law degree distributions with
few highly connected nodes and many sparsely connected ones.

Some interactions are direct; others are _mediated by the environment_. Ant
pheromone trails, road networks, and social-graph edges all store information
that couples components asynchronously. The environment is part of the model,
not mere background. To study such systems scientifically we need
_reproducible_, _executable_ descriptions. _Computational models_ are
mathematical representations that a computer can simulate, check, or explore.
Without such models, reasoning about flock formation, epidemic spread, or
intracellular signaling would remain anecdotal rather than predictive. This book
develops a toolkit of formalisms, each suited to different abstraction levels
and analysis techniques, so that readers can choose an appropriate
representation for the system and question at hand.

Applications span biology, where understanding cell processes supports drug
development; engineering, where distributed systems and urban infrastructure
require prediction of collective behavior; and social science, where opinion
dynamics and information spread on networks shape public discourse. In each
domain, the common thread is interaction among simple components producing
emergent global behavior that we wish to understand, predict, or control.

Emergency evacuation of crowded buildings is a canonical engineering
application. Each person follows simple rules: move toward the nearest exit,
slow down when blocked, avoid collisions. No individual plans the global flow,
yet bottlenecks and jams emerge at doorways. A computational model encodes these
rules for each agent, simulates the evacuation, and reveals whether the building
design allows safe egress within the required time. Changing door width or
adding an exit becomes a perturbation experiment on the model rather than a
costly real-world trial.

Manufacturing systems exhibit similar structure. Machines process jobs, buffers
hold work in progress, and conveyors transport materials. A breakdown at one
machine propagates through the network, causing queues and delays elsewhere.
Petri nets and Markov chains model such systems naturally because they represent
resources, concurrent operations, and stochastic failures. Analysis can identify
bottlenecks, estimate throughput, and evaluate the impact of adding capacity at
critical points.

== What Is a Model?

A _model_ is a simplified, approximate representation of a system of interest.
In machine learning, a model might be a neural network approximating a function
from data. In biology, a mouse is a _model organism_ standing in for a human. In
architecture, a geometric drawing or virtual-reality walkthrough represents a
building. A Petri net or differential equation is also a model: a formal
description whose behavior we can analyze.

Scientists construct a model, analyze it through simulation or reasoning, and
interpret results to refine understanding of the real system. Each stage can
fail: the model may omit mechanisms, analysis may be approximate, interpretation
may be contested. The same experimental result presented to different experts
may yield different conclusions, so rigorous reasoning at every step is
essential.

Biology distinguishes _in vivo_ (living organisms), _in vitro_ (cell cultures in
a dish), and _in silico_ (computational) models. In silico work is cheap and
fast but requires validation against experimental data; it complements rather
than replaces laboratory science. A computational model of protein interactions
inside a cell can test drug effects in hours rather than months, but its
predictions must be confirmed experimentally before clinical use.

We focus on _computational models_ of _dynamical systems_: systems with a
_state_ that evolves over time. A static architectural drawing is not dynamical;
a queue whose length changes, or a population that grows and shrinks, is. Making
the mathematics executable enables simulation, state-space exploration, and
formal verification. A computational model takes the form of a mathematical
representation together with algorithms for simulation or analysis.

The modeling workflow has four stages, each fallible. First, construct the model
from knowledge, data, or both. Second, analyze it through simulation,
mathematical reasoning, or exhaustive exploration. Third, interpret the results
in the context of the real system. Fourth, refine the model or the
interpretation based on discrepancies with observation. Errors at any stage
propagate: an inaccurate model yields unreliable analysis; correct analysis of a
wrong model still misleads; even correct results can be misinterpreted when
experts disagree on their meaning.

== State, Time, Determinism, and Stochasticity

The _state_ is described by variables: queue length, temperature, species
counts. Two distinctions organize our formalisms. State variables may be
_discrete_ (integer counts) or _continuous_ (real-valued densities). Time may
advance in _discrete steps_ or _continuously_. Four combinations arise, each
with different notations and algorithms.

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  table.header([Dimension], [Discrete], [Continuous]),
  [State variables],
  [Counts (natural numbers)],
  [Densities or concentrations (real numbers)],

  [Time evolution],
  [Step updates such as $n_(t+1) = f(n_t)$],
  [Derivatives such as $dot(n) = f(n)$],
)

A third distinction cuts across all four: behavior may be _deterministic_ (one
successor state from each state) or _stochastic_ (transitions weighted by
probabilities). Deterministic models yield a single forecast; stochastic models
require distributions over trajectories and tools such as Markov chains and
probabilistic model checking. We begin with determinism because the mathematics
is simpler, then add randomness where small populations or rare events make it
essential.

Consider a queue at a service desk. The state variable is queue length, a
natural number. Time may be discrete (one customer served per step) or
continuous (arrival and service as Poisson processes). Weather combines
continuous state (temperature, humidity) with continuous time. A cellular
automaton uses discrete state on a grid with discrete time steps. Choosing the
right combination is a modeling decision that affects both notation and
available analysis tools.

In a deterministic model, given the current state, the next state is uniquely
determined. In a stochastic model, several successors are possible, each with an
associated probability. Stochastic simulation samples individual trajectories;
probabilistic model checking explores the full distribution of behaviors. Both
approaches are needed when rare events, such as predator extinction during a
population trough, carry consequences that average behavior obscures.

Markov chains represent stochastic dynamics as graphs whose nodes are states and
whose edges are probabilistic transitions. From a given state, the model
specifies a distribution over possible next states rather than a single
successor. Model checking on Markov chains can compute the probability of
reaching a target state, the expected time to reach it, or whether a property
holds with probability above a threshold. These questions extend naturally to
complex systems where uncertainty is intrinsic.

== Questions We Ask of Models

Once a model exists, we study how state evolves. _Reachability_ asks whether a
target state can occur: Will vaccination eradicate a disease? Can a drug cause
toxicity? Will misinformation spread to a given fraction of the population?
_Behavioral patterns_ ask whether concentrations stabilize, oscillate, or
diverge. _Invariants_ are properties true on every trajectory, such as conserved
total mass or normalized population fractions summing to one. _Perturbation
analysis_ changes parameters or rules and compares outcomes: a new drug dose, a
road closure, a fishing moratorium.

Executable models make scenario analysis cheap and safe. Fisheries models
identify sustainable catch limits by simulating reproduction under different
harvesting policies. Protein-network models predict drug response in specific
patient profiles. Epidemic models estimate vaccination coverage needed for
eradication. Conclusions are conditional on assumptions and must be validated,
but the alternative of experimenting blindly on the real system is often
impossible or unethical.

Suppose we model a protein signaling pathway and ask whether a drug can drive
the system into a toxic state. Reachability analysis on the model answers this
without administering the drug to patients. Suppose we model urban traffic and
ask whether closing a street during maintenance will create unacceptable
congestion elsewhere. We simulate both open and closed configurations under
identical demand. Suppose we model a fish population and ask what happens if
fishing stops for one month. The model identifies recovery trajectories and
sustainable harvest levels. These questions share a structure: given a formal
dynamical model, what can happen over time, and how do interventions change the
answer?

Perturbation analysis is particularly powerful because the model is _playable_
inside a computer. We can change a parameter, rerun the simulation, and compare
outcomes in minutes. Testing the same perturbation on a real population or
patient population would be slow, expensive, or unethical. The model does not
replace experiment, but it narrows the space of hypotheses worth testing.

Consider a fisheries management scenario. A model encodes fish reproduction
rates, natural mortality, and harvesting intensity. The manager asks what
happens if fishing stops for one month during the spawning season. Perturbation
analysis sets harvest rate to zero for one time unit and compares the resulting
population trajectory with the baseline. If the population recovers
significantly, the model supports a seasonal closure policy. If recovery is
negligible, the intervention is not worth the economic cost. The answer depends
entirely on the model's assumptions about reproduction timing and density
dependence, which must be validated against field data.

Behavioral patterns extend reachability to trajectories rather than single
states. Will the concentration of a substance oscillate indefinitely, as in
predator-prey cycles? Will queue lengths stabilize after a policy change? Will
cars remain outside the city center under a congestion charge? Invariants
provide guarantees: total population in a closed epidemic model remains
normalized; mass is conserved in a closed chemical system. Identifying
invariants simplifies analysis because they reduce the effective dimension of
the state space.

== Data-Driven and Knowledge-Driven Modeling

_Data-driven_ modeling, exemplified by machine learning, infers structure from
observations. A neural network trained on fruit images can classify bananas and
pears accurately, but its internal weights do not mirror ripening biology. The
model approximates the function that maps features to labels; it does not
reproduce the mechanism by which fruits develop.

_Explainable AI_ identifies which features drove a prediction, which is useful
for justifying a medical recommendation to a patient. If a classifier advises
against a drug, explainability might report that age over sixty-five and smoking
status drove the decision. This justifies the prediction but does not explain
_why_ the drug fails biologically. It tells us what the model used from the
dataset, not what happens inside the human body.

_Knowledge-driven_ modeling starts from hypothesized mechanisms. A biologist who
knows protein interactions writes equations or rules capturing them, then checks
whether simulated behavior matches observations. Less training data is needed
because data validates rather than constructs the model. Agreement supports the
hypothesis; disagreement forces revision. This loop is the primary methodology
emphasized here.

Consider a patient over sixty-five who smokes. A black-box classifier might flag
risk without mechanistic insight. A knowledge-driven model encoding differential
protein expression in that demographic could explain _why_ a drug fails and
suggest which protein pathway is disrupted, pointing toward alternative
therapies. The knowledge-driven loop proceeds as follows: formulate a hypothesis
about system mechanics; encode it in a formal model; run analysis or simulation;
compare output with observations; revise the hypothesis if they disagree. This
is not proof, but it is a rigorous way to generate and test scientific ideas.

A concrete comparison clarifies the distinction. Suppose we want to predict
whether a fruit is a banana or a pear from its color and shape. A data-driven
approach trains a classifier on labeled images; accuracy may be high, but the
model encodes no botanical knowledge. A knowledge-driven approach might model
ripening chemistry, sugar content, and peel structure, then check whether
simulated ripening trajectories match observed color changes. The first approach
predicts labels; the second tests mechanisms. For scientific understanding and
therapy design, mechanisms matter.

Machine learning excels when the goal is prediction on well-characterized inputs
and large training sets are available. Knowledge-driven modeling excels when
mechanisms are partially understood, data are scarce, and the goal is
explanation or intervention design. The present text emphasizes the latter
because complex systems research typically involves hypothesizing interactions
and testing whether they suffice to explain observed emergent behavior.

== Formalisms and the Programming Analogy

The formalisms developed in this book differ in how much detail they retain
about individuals and interactions. At the most aggregate level, differential
equations track population counts or concentrations without naming separate
entities. Chemical reaction networks describe how species transform into one
another---a language that applies from biochemistry to protocol analysis. Petri
nets, born in concurrency theory, represent competition for shared resources
through places, transitions, and tokens; reachability and deadlock analysis
developed for software transfers directly to manufacturing and biological
workflows. When spatial structure matters, cellular automata update each cell
from local neighborhood rules: Conway's Game of Life shows that four simple
rules can generate moving, reproducing patterns, and in principle even arbitrary
computation. At the finest grain, multi-agent models program explicit behavior
for each entity within a grid, graph, or other environment. Markov chains add
transition probabilities across these representations and enable exhaustive
exploration of possible behaviors when the state space remains manageable.

These formalisms are not interchangeable labels for the same mathematics. Each
makes some features easy to express and others awkward. Choosing one is
therefore a modeling decision about which mechanisms must be visible in the
description and which analysis questions we intend to ask.

Modeling parallels programming in a precise sense. Both specify mechanisms in a
formal language whose _semantics_ defines how state updates over time. A
program's state is its variables; a model's state may be population counts,
concentrations, or agent attributes. Running a program on sample inputs
corresponds to simulating a model from initial conditions. When sampling
individual trajectories is insufficient, _model checking_ explores all reachable
behaviors of a transition system---an idea imported from software verification
and applied here through tools such as PRISM for probabilistic chains.

Across the book we use spreadsheets for simple recurrences, Python with SciPy
and Mesa for numerical and agent-based simulation, PRISM for probabilistic model
checking, and NetLogo for pedagogical demonstrations. The concluding chapters
connect multi-agent models with reinforcement learning, where agents learn from
environmental feedback; multi-agent reinforcement learning extends this setting
to several interacting learners. The progression is deliberate: we build
aggregate deterministic models first, add stochastic and concurrent formalisms
in the middle, and end with individual-based simulation where exhaustive
analysis rarely remains feasible.

== Urban Toll Policy

The preceding sections outlined what models are, which questions we ask of them,
and why knowledge-driven construction matters. A compact traffic example shows
how these ideas fit together before we turn to the mathematical machinery of
later chapters.

#example-box(title: "Urban toll policy")[
  Suppose a city proposes a toll to keep cars out of the center at rush hour. We
  model cars with route-choice rules, a road network with capacities, and
  braking when ahead vehicles slow down. Variables include queue lengths at
  monitored junctions and the fraction of trips entering the center. We simulate
  current and proposed policies from identical demand.

  Step one lists variables and their domains: queue length at junction $j$ as a
  non-negative integer; fraction of center-bound trips as a real number in
  $[0,1].$ Step two encodes rules: shortest-path routing unless congestion at a
  junction exceeds a threshold, in which case the driver chooses an alternate
  route; fixed semaphore cycles at each intersection; under the proposed policy,
  a toll applies to every center entry. Step three runs both scenarios from the
  same initial conditions and demand profile. Step four compares outputs across
  scenarios.

  A thirty-percent queue reduction at center junctions supports a pilot program.
  Increased residential congestion on peripheral routes reveals an unintended
  rerouting effect that planners must address before deployment. The model will
  not predict Tuesday's exact traffic, but it tests whether the policy plausibly
  achieves its goal under stated assumptions.
]

Several features of this scenario recur throughout the book. Components
(vehicles) follow local rules (routing, braking); the road network mediates
interactions and enforces capacity limits; global outcomes (queue lengths,
center entry rates) emerge from many pairwise decisions rather than central
control. The workflow is explicitly knowledge-driven: planners hypothesize
routing and toll mechanisms, encode them in an executable model, compare
scenarios under identical demand, and interpret divergences as design
feedback---not as exact forecasts of a particular day's commute.

The example also illustrates the perturbation analysis introduced earlier.
Running the baseline and toll scenarios from the same initial conditions
isolates the effect of the policy change. A thirty-percent reduction in center
queues argues for piloting the toll; increased congestion on peripheral routes
flags an unintended consequence to address before deployment. Such conclusions
remain conditional on the rules we encoded. That limitation is general: every
formalism trades fidelity against tractability, and validation against
observation remains essential at each stage of the modeling loop.

The chapters ahead develop the toolkit this example presupposes. Discrete
recurrences and ordinary differential equations describe population change in
stepwise and continuous time. Lotka---Volterra and SIR models show how
interaction terms produce oscillations and epidemic peaks. Chemical reactions,
Petri nets, and Markov chains add concurrency, resource sharing, and
probability. Gillespie's algorithm and probabilistic model checking address
settings where randomness is intrinsic and average behavior hides rare but
consequential events, such as population extinction during a predator trough.
Agent-based models and discrete-event simulation return to individual decision
rules when aggregate equations omit structure that matters. Recognizing
equilibria, thresholds, and oscillations in the simpler settings of Part I
prepares readers to spot the same patterns when they reappear in more elaborate
languages later in the book.
