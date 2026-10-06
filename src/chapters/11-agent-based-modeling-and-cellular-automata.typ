#import "@preview/bookly:5.1.0": *
#import "../lib.typ": drawio-placeholder, enrichment-box, example-box

#show: chapter.with(
  title: "Agent-Based Modeling and Cellular Automata",
  abstract: [
    Agent-based modeling describes a complex system bottom-up, one individual at
    a time, and looks for global behavior that emerges from local rules. This
    chapter defines agents and their environments, separates agent-based
    modeling from multi-agent systems, reinforcement learning and game theory,
    studies the classical emergence models of flocking and segregation, and
    develops cellular automata from elementary one-dimensional rules to the Game
    of Life. It closes with the NetLogo and Mesa platforms.
  ],
  toc: true,
)

Part III reverses the top-down perspective of ODEs, Markov chains and Petri
nets. Those formalisms count how many components are in each state and write
laws for the counts. Here the starting point is the individual component: each
one receives its own state and its own behavioral rules, the components are let
loose in a shared environment, and the global behavior is observed rather than
postulated. Cellular automata, in which only the environment evolves, are the
first step of this program; placing mobile agents on top of them yields full
agent-based models.

== From Top-Down to Bottom-Up Modeling

Every model met so far describes a complex system at the _macro level_. The
Lotka---Volterra equations track the number of prey and predators, the SIR model
tracks the numbers of susceptible, infected and recovered individuals, and a
Petri net marking tracks how many tokens sit in each place. The modeler writes
rules directly for these aggregate quantities; this is a _top-down_ description.
_Agent-based modeling_ (ABM) takes the opposite route. It is a _bottom-up_
description: the modeler specifies the behavior of every individual component at
the _micro level_, lets the components interact, and then looks at the whole
population for patterns that no single rule mentions. Such patterns are called
_emergent_ behaviors.

#figure(
  image("../images/chapter11/ode-vs-abm.pdf", width: 88%),
  caption: [
    Top-down and bottom-up descriptions of the same population. On the left, a
    few aggregate variables obey a system of differential equations; on the
    right, individually represented agents interact locally, and clusters,
    segregation or flocks appear as emergent outcomes.
  ],
) <fig:ode-vs-abm>

=== What an agent is

An _agent_ is an entity that lives in an environment and has three capabilities.
First, it _perceives_ the environment, or at least part of it, through some form
of sensor. Second, it has an internal definition of behavior, which may rely on
a private state, on a goal to achieve, on a memory of past events, or on a
notion of _reward_ that it receives when it does something good and may try to
maximize. Third, it _acts_ on the environment and can therefore change it.
Perception, internal decision and action repeat in a loop, shown in
@fig:abm-agent-loop, and every concrete notion of agent in this chapter is an
instance of it.

#figure(
  image("../images/chapter11/abm-agent-loop.drawio.pdf"),
  caption: [
    The agent loop: each agent perceives the environment through sensors,
    decides according to its state, rules, goals, memory or reward, and acts on
    the environment, which also mediates interactions with other agents.
  ],
) <fig:abm-agent-loop>

The literature classifies agents along several independent dimensions. A
_mobile_ agent can move, which presupposes that the environment has a notion of
location. A _reactive_ agent perceives the environment and responds according to
fixed laws, whereas an _adaptive_ agent changes its behavior dynamically on the
basis of what it learns from the environment. A _goal-based_ agent has a final
objective and tries to reach it, whereas a _utility-based_ agent chooses, step
by step, the action that is most useful according to some measure. These labels
are not exclusive: a foraging ant is mobile and reactive, while a chess program
is goal-based and utility-based.

=== The ingredients of an agent-based model

An agent-based model consists of a collection of agents, each with its own state
and rules, and an environment in which the agents live and interact. Four
features distinguish it from the models of Parts I and II. The focus is on the
_micro level_: the behavior of each individual is written down explicitly. The
model is _heterogeneous_: agents in the same system may be of different kinds,
so prey and predators, or red and blue households, follow different rules. The
model is built on _interactions_: agents perceive and modify the environment,
and since other agents are part of the environment they can also perceive,
communicate with and influence each other. Finally, the model is _dynamic_: once
the agents are placed in the environment, the states of agents and environment
evolve over time, and the model is analyzed by simulating this evolution.

The purpose of the simulation is _emergence_: understanding how simple local
rules give rise to complex global behavior. This purpose dictates a modeling
discipline. The rules of each agent should be _as simple as possible_, because
the simpler the model, the clearer the conclusion. If a minimal set of
ingredients in the individual behavior suffices to make the global pattern
appear, those ingredients are identified as the mechanism that produces it. If
the agents are made complicated, very rich global behaviors may appear, but it
becomes impossible to say which part of the individual behavior caused them.

The same principle is central in ecology and population science, where
_individual-based models_ have long described populations and ecosystems as
collections of interacting organisms. The ecologist Volker Grimm formulated it
as a methodological program: calibrate the simplest micro rules that reproduce
the macro patterns one wants to explain. For such a model to count as
scientific, two checks are required. _Verification_ asks whether the model is
built right: the implementation follows a rigorous development process and
contains no technical errors, so that the simulated behavior really is the
behavior of the specified rules. _Validation_ asks whether it is the right
model: the simulated population must reproduce the observed behavior, and since
simulations are random this must be shown statistically, by comparing measured
quantities such as cluster counts, oscillation periods or queue lengths with
data. Emergent properties are always measured at the population level, never
inside the code of a single agent.

== Emergence in Two Classical Models

Two classical models make the notion of emergence concrete. In both, each agent
follows a short local rule, and a pattern appears that can only be measured on
the whole population.

=== Flocking: the boids model

Birds fly in flocks without a predefined leader: they coordinate in a
distributed way and move together. The _boids_ model, introduced by Craig
Reynolds, reproduces this with agents whose state consists of a position
$bold(x) = (x, y)$ and a velocity vector $bold(v),$ which encodes both the
direction and the speed of flight. Each bird sees only the other birds within a
_perception radius_ $r$ around itself; call this set its _neighbors_ $N.$ At
every step the bird computes three steering vectors from its neighbors.

+ _Cohesion_ pulls the bird toward the center of mass of its neighbors, so that
  birds tend to form a group.
+ _Separation_ pushes the bird away from each neighbor individually, so that
  birds avoid collisions.
+ _Alignment_ turns the bird toward the average direction of its neighbors, so
  that the group moves the same way.

Cohesion and separation are not simply opposite forces. Cohesion responds to a
single point, the center of mass of the group; separation is a sum of
repulsions, one from each neighbor, which grows strongly when a neighbor is very
close. A common way to write the three vectors for bird $i$ is

$
  bold(c)_i = 1 / abs(N) sum_(j in N) bold(x)_j - bold(x)_i, quad
  bold(s)_i = sum_(j in N) (bold(x)_i - bold(x)_j), quad
  bold(a)_i = 1 / abs(N) sum_(j in N) bold(v)_j - bold(v)_i.
$

Here $abs(N)$ is the number of neighbors; $bold(c)_i$ points from the bird to
the center of mass; $bold(s)_i$ adds up the vectors pointing away from each
neighbor; $bold(a)_i$ is the difference between the average velocity of the
neighbors and the bird's own velocity. The model has three parameters
$w_1, w_2, w_3$ that weight the forces, and a single behavioral rule:

$
  bold(v)_i <- bold(v)_i + w_1 bold(c)_i + w_2 bold(s)_i + w_3 bold(a)_i,
  quad bold(x)_i <- bold(x)_i + bold(v)_i.
$

The rule reads: collect the neighbors, compute the three steering vectors,
update the velocity by their weighted sum, and move the bird according to the
new velocity. Implementations usually rescale the separation term so that only
very close neighbors matter and cap the speed; these are refinements of the same
idea.

#example-box(title: "One boids update")[
  A bird at $bold(x)_i = (0, 0)$ flies with $bold(v)_i = (1, 0).$ Within its
  perception radius it sees two neighbors, at $(2, 2)$ with velocity $(0, 1)$
  and at $(4, 0)$ with velocity $(0, 1).$ The weights are $w_1 = 0.1,$
  $w_2 = 0.05$ and $w_3 = 0.5.$

  _Step 1---cohesion._ The center of mass of the neighbors is
  $((2 + 4)\/2, (2 + 0)\/2) = (3, 1),$ so
  $bold(c)_i = (3, 1) - (0, 0) = (3, 1).$

  _Step 2---separation._ The vectors away from the neighbors are
  $(0 - 2, 0 - 2) = (-2, -2)$ and $(0 - 4, 0 - 0) = (-4, 0),$ whose sum is
  $bold(s)_i = (-6, -2).$

  _Step 3---alignment._ The average neighbor velocity is $(0, 1),$ so
  $bold(a)_i = (0, 1) - (1, 0) = (-1, 1).$

  _Step 4---velocity._ The weighted sum is
  $0.1 dot (3, 1) + 0.05 dot (-6, -2) + 0.5 dot (-1, 1)
  = (0.3, 0.1) + (-0.3, -0.1) + (-0.5, 0.5) = (-0.5, 0.5),$ so the new velocity
  is $(1, 0) + (-0.5, 0.5) = (0.5, 0.5).$

  _Step 5---position._ The bird moves to $(0, 0) + (0.5, 0.5) = (0.5, 0.5).$

  With these weights cohesion and separation cancel exactly, and alignment alone
  turns the bird from due east toward the northward heading of its neighbors. No
  bird knows the heading of the flock; each reacts only to what it sees.
]

Simulations of the model show how the weights shape the collective behavior.
With all three weights at zero, birds keep their random initial velocities and
the population is disordered. Raising the alignment weight makes the birds
progressively fly in the same direction. Raising cohesion makes groups contract
into tight clusters, and raising separation spreads them again. With balanced
weights, flocks form dynamically from random initial positions, split, merge and
travel together. @fig:boids-flock compares a disordered population with a
flocking one. The degree of order is measured by the _polarization_, the length
of the average unit heading vector: it is close to zero when headings point in
all directions and equal to one when all birds fly the same way.

#figure(
  image("../images/chapter11/boids-flock.pdf", width: 92%),
  caption: [
    Sixty boids on a $100 times 100$ periodic domain after 300 steps with
    perception radius $12.$ Arrows show headings and grey lines the last 25
    positions of some birds. Without steering forces (left) the headings remain
    random; with cohesion, alignment and separation (right) the birds form
    flocks with high polarization.
  ],
) <fig:boids-flock>

The environment in this model is a finite rectangle, and a choice must be made
about its edges. One option keeps the birds inside a closed box. Another, very
common in agent-based models, makes the domain _periodic_: a bird that leaves
through one edge re-enters through the opposite edge, as if the rectangle were
wrapped into a torus. Periodic domains avoid artificial effects near the walls;
@fig:boids-flock uses one.

=== Segregation: the Schelling model

Thomas Schelling's model asks, in a deliberately abstract way, when a population
made of two groups ends up segregated. Agents of two colors, red and blue,
occupy the cells of a grid, and some cells are left empty. Each agent looks at
the eight cells around it and computes the _similar share_: the fraction of its
occupied neighboring cells that hold an agent of its own color. Given a
_threshold_ $theta$ between $0$ and $1,$ the rule is

$ "agent is unhappy" <==> "similar share" < theta. $

An unhappy agent moves to a free cell, which may be anywhere on the grid; there
is no need to walk there cell by cell. A happy agent stays. The threshold
expresses a mild preference: with $theta = 0.3$ an agent is satisfied as long as
at least thirty percent of its neighbors are like it, so it tolerates up to
seventy percent of neighbors of the other color.

#example-box(title: "Is this agent unhappy?")[
  A red agent has eight neighboring cells: two red agents, five blue agents and
  one empty cell. The empty cell does not count, so the occupied neighbors are
  $2 + 5 = 7$ and the similar share is $2\/7 approx 0.286.$

  With $theta = 0.15$ the agent is happy, because $0.286 >= 0.15,$ and it stays.
  With $theta = 0.3$ it is unhappy, because $0.286 < 0.3,$ and it jumps to a
  random empty cell. Its departure changes the neighborhoods of the seven agents
  around it: each of the five blue agents gains an empty cell in place of an
  unlike neighbor, and each of the two red agents loses a similar one, so the
  move may make others unhappy in turn.
]

Starting from a random mixture, the outcome depends sharply on the threshold, as
@fig:schelling-segregation shows. With $theta = 0.15$ the population remains
mixed as time passes. With $theta = 0.3,$ a threshold that most people would
call tolerant, the two groups separate into large single-color regions. With
higher thresholds the segregation becomes stark. The mechanism is the chain
reaction visible in the example: every move changes the neighborhoods of the
cells left and entered, so local dissatisfaction propagates until a
configuration is reached in which almost every agent is surrounded mostly by its
own group. The emergent segregation is much stronger than any individual
preference, which is the central message of the model.

#figure(
  image("../images/chapter11/schelling-segregation.pdf", width: 100%),
  caption: [
    Schelling model on a $40 times 40$ periodic grid with 10% empty cells and
    equal red and blue populations. From the random initial state (left),
    unhappy agents move until at most 60 sweeps have been performed. The mean
    similar share grows from about one half to strongly segregated values as the
    threshold $theta$ rises from $0.15$ to $0.5.$
  ],
) <fig:schelling-segregation>

== Agents Beyond Agent-Based Modeling

The word _agent_ appears in many areas of computer science with related but
different meanings. Placing agent-based modeling among them clarifies what it is
for: agents are used here to _explain_ a complex system, not to build a system
that performs a task.

=== Multi-agent systems

A _multi-agent system_ (MAS) is an engineered distributed system whose
components are autonomous and interact. Its components, often called
_intelligent agents_, have four properties: _autonomy_ (they decide by
themselves whether and how to act), _social ability_ (they communicate and
negotiate with other agents), _reactivity_ (they sense the environment and
respond to it) and _proactiveness_ (they pursue a goal and may anticipate
actions according to a strategy that leads to it). In software engineering an
agent of this kind can be seen as an object plus autonomy. An object is a
container of state and methods, and invoking a method makes it execute; an agent
can be asked to do something, but it acts only if it decides to. Implementations
of agent-based models exploit the same correspondence, since agents are
typically programmed as objects whose behavior is a step method.

A personal digital assistant is a classical software example. Each user owns an
agent that manages the user's agenda, and the agents communicate to schedule
meetings: one agent proposes a date and the others accept or refuse it according
to their users' agendas. Autonomy, social ability and proactiveness are all
visible, since an agent that notices a project deadline may refuse meetings in
the preceding week. A robotic example is the Kiva system used in Amazon
warehouses, in which robots carry shelves of products across a grid-shaped
floor. Each robot has the goal of bringing a shelf from one place to another,
plans its path and interacts with the others to avoid collisions at
intersections.

#table(
  columns: (1fr, 1.2fr, 1.2fr),
  align: (left, left, left),
  table.header([Aspect], [Agent-based modeling], [Multi-agent systems]),
  [Nature], [A model of an existing system], [An engineered system],
  [Agent complexity], [As low as possible], [Whatever the task requires],
  [Aim],
  [Study the emergence of global behavior],
  [Cooperate to achieve a global result],

  [Typical example],
  [Flocking, segregation, foraging ants],
  [Meeting schedulers, warehouse robots],
)

The table summarizes the difference. The complexity of an agent in an MAS is
irrelevant as long as the warehouse works, while in ABM low complexity is the
point of the exercise.

=== Agents in artificial intelligence

Artificial intelligence offers two further notions. In _reinforcement learning_,
a paradigm of machine learning distinct from supervised and unsupervised
learning, an agent acts in an environment, receives a positive or negative
_reward_ as feedback, and learns how to behave so as to maximize the reward it
collects; game-playing programs are trained in this way. In its classical form
the agents of reinforcement learning are essentially those of agent-based
modeling, one or several agents with a state interacting with an environment.
The difference lies in the aim. ABM writes the rules and observes the emergent
behavior; reinforcement learning learns the rules from the rewards. The two meet
when the modeler designs the environment and the reward so that the learned
behavior is the one expected to produce a given emergent pattern; readable
learned policies then suggest mechanisms. An agent optimizes the reward it is
given, not the intention behind it, so it may discover shortcuts to the reward;
defining the reward properly, including negative rewards for undesired actions,
is therefore part of the modeling task. Modern variants embed deep neural
networks in the agent and lose this readability. Chapter 12 presents the core
ideas.

The agents of _generative AI_ are built around large language models. They
satisfy the general definition of an agent, but their decisions come from the
language model rather than from explicit rules, and the aim is to perform
complex tasks, not to describe the mechanisms of a system. They play no role in
agent-based modeling.

=== Game theory and the prisoner's dilemma

_Game theory_ studies situations in which several entities, called _players_,
collaborate or compete to achieve a goal. In _cooperative_ games the players try
to win together; in _competitive_ games one player's gain is another's loss, and
in the extreme case of _zero-sum_ games the payoffs of the players always add up
to zero. Three concepts transfer directly to agent-based modeling. Players are
agents. A _strategy_, the sequence of actions a player performs to reach its
goal, corresponds to the behavioral rules of an agent. The _payoff_, what a
player obtains at the end of the game, is a form of reward or utility. Game
theory often looks for _Nash equilibria_: strategy profiles in which no player
can improve its own payoff by changing its own strategy while the others keep
theirs.

The _prisoner's dilemma_ shows that an equilibrium of individual interests may
be collectively bad. Two prisoners, $X$ and $Y,$ decide separately whether to
stay silent or to confess, which betrays the other. If both stay silent, each
serves one year in jail. If one confesses and the other stays silent, the one
who confesses goes free and the other serves ten years. If both confess, each
serves six years. Writing the payoff as minus the years in jail gives the
following table, where each cell lists the payoff of $X$ and then of $Y.$

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, center, center),
  table.header([], [$Y$ silent], [$Y$ confesses]),
  [$X$ silent], [$(-1, -1)$], [$(-10, 0)$],
  [$X$ confesses], [$(0, -10)$], [$(-6, -6)$],
)

#example-box(title: "Finding the Nash equilibrium")[
  _Step 1---mutual confession._ In the cell $(-6, -6),$ suppose $X$ switches to
  silence while $Y$ keeps confessing. The payoff of $X$ goes from $-6$ to $-10,$
  four more years in jail, so $X$ does not want to switch. By symmetry neither
  does $Y.$ The cell is a Nash equilibrium.

  _Step 2---mutual silence._ In the cell $(-1, -1),$ if $X$ switches to
  confessing its payoff goes from $-1$ to $0,$ so $X$ has an incentive to
  deviate; the cell is not an equilibrium, and the same holds for the two mixed
  cells, where the silent prisoner gains four years by confessing.

  _Step 3---comparison._ At the equilibrium the prisoners serve $6 + 6 = 12$
  years in total, while mutual silence would cost only $1 + 1 = 2.$ Individual
  rationality leads to a collectively worse outcome.
]

This analysis is static: it inspects the payoff table without simulating
anything. The _iterated prisoner's dilemma_ turns the game into an agent-based
model. The same choice is repeated many times, and each player can look at the
past decisions of its opponent and adapt; players thereby acquire a
_reputation_. A well-known strategy is _tit-for-tat_: cooperate (stay silent) on
the first move, then repeat whatever the opponent did in the previous move.
Tournaments in which agents with many different strategies play against each
other show that strategies introducing some form of cooperation can be, on
average, much more profitable than always confessing. The macro outcome, the
success of cooperation, emerges from repeated micro interactions and cannot be
read off the one-shot table.

== Environments and Time

The environment is not a background on which agents do their job. Agents are
usually simple, and the behavior of the model often depends mostly on the state,
the dynamics or the shape of the environment, which is frequently the real main
character of an agent-based model.

=== Kinds of environment

The simplest environment is the _soup_: there is no physical space at all, only
a collection of agents, any of which may interact with any other, plus possibly
some global variables. This is the environment implicitly assumed by the
differential equations of Part I, where every predator can meet every prey and
nothing describes the territory on which they move.

Most models give the environment a topology. The most common is a _grid_ that
divides space into cells; each agent is located in a cell, and each cell has its
own state variables, such as the amount of grass that prey can eat. Cells have a
notion of proximity: the neighbors of a cell are either the four cells sharing a
side with it or the eight cells that also include the corners, two choices
formalized below as the von Neumann and Moore neighborhoods. Cells may also have
their own behavioral rules, for instance grass that grows back after some time;
in this sense cells are limited agents as well, although they are not usually
called agents. Generalizations replace the grid by a _continuous space_, in
which an agent occupies a point with real coordinates; by a _geographic
information system_, a map with custom locations such as the streets of a city;
or by a _network_, in which locations are nodes and edges are the paths agents
can follow or the channels through which they communicate. Networks are the
natural environment for social-network analysis, where each agent sits in a node
and interacts only with its graph neighbors. These few kinds cover almost all
models in practice.

The environment plays several roles. It provides a _topology_ in which agents
live, move and interact. It provides _resources_, like grass for prey, on which
the agents' activity depends. It imposes _constraints_: a road network admits
only so many cars at the same time and adds crossroads and traffic lights. It
can have its own _dynamics_, with variables and rules that change them over
time, for instance substances that diffuse, dissipate or are produced. Its
behavior can be local, defined cell by cell, or global, like gravity or
temperature acting on all agents at once. Finally, it can be an indirect channel
of interaction. Chapter 1 described how ants forage through _stigmergy_: an ant
that has found food releases a chemical on its way back to the nest, and other
ants perceive the chemical and follow the trail. The chemical diffuses in the
soil and evaporates after some time, so the environment has its own dynamics,
and it acts as a shared, asynchronous memory that coordinates the colony without
any direct communication between ants.

Environments are further classified as fully or partially observable (a boid
sees only within its radius), deterministic or stochastic, static or dynamic
(depending on whether their variables change), and discrete or continuous.

=== Ticks and step functions

Agent-based models are dynamical systems, and in the majority of them time is
discrete and advances in _ticks_. Every agent implements a _step_ function that
reads its own state and its surroundings and performs one action; the simulation
is a main loop that, at every tick, asks every agent to perform one step. In a
_synchronous_ update all agents perform their step within the same tick; in an
_asynchronous_ update one agent at a time is picked, often at random, and its
step takes effect before the next agent is chosen. A third option, used when
agents act at heterogeneous times, is _event-based_ scheduling, in which each
action is scheduled at its own time instant; Chapter 12 develops this idea as
discrete-event simulation.

```python
for tick in range(n_ticks):
    order = random.sample(agents, len(agents))   # new random order each tick
    for agent in order:
        agent.step(environment)
    environment.step()                           # grass regrows, chemical evaporates
```

In principle the order in which agents are updated within a synchronous tick
should not matter, and any permutation of the agents could be used. In practice
two agents acting in the same tick can produce _conflicts_ or _artifacts_:
configurations that the model declares impossible.

#example-box(title: "A conflict in a synchronous tick")[
  On a grid where each cell holds at most one agent, agent $A$ sits in cell
  $(2, 3)$ and agent $B$ in cell $(4, 3).$ Cell $(3, 3)$ between them is empty.
  Both perceive the environment at the start of the tick, both see $(3, 3)$
  free, and both decide to move there.

  If both moves are applied, the tick ends with two agents in $(3, 3),$ an
  inconsistent state. If instead each agent checks what the agents already
  processed in this tick have done, the first one processed, say $A,$ moves into
  $(3, 3)$ and $B$ finds the cell taken and stays in $(4, 3)$ or picks another
  free cell.
]

The check in the example solves the conflict but moves the problem to the order
of the updates: the agent processed first always wins. With a fixed order some
agents would implicitly receive a priority over others, so fairness requires
_randomizing_ the order at every tick, as in the loop above. The alternative is
to switch to asynchronous updates, in which conflicts cannot arise because each
step sees the effects of all previous ones. No choice is best in every case; the
timing scheme is a modeling decision like any other, even though most models use
synchronous ticks, as cellular automata do.

== Cellular Automata: Definition and Ingredients

A _cellular automaton_ (CA) is an environment without agents: a grid of cells,
each with a state, all evolving by the same local rule. The formalism was
originally conceived as the simplest model able to mimic mechanisms of life,
starting from an intuition about biological cells forming a tissue: components
with their own behavior cover an area or a volume, touch each other and interact
physically where they touch. Many famous automata belong to _artificial life_,
because their behavior resembles that of living entities. Since the behavior
they can express is complex, irregular and even chaotic, cellular automata have
become models of complex systems in computer science, biology and mathematics.
Their interest lies again in emergence: cells with very simple behavior give
rise, through interaction, to global phenomena.

=== The ingredients

A cellular automaton is specified by six ingredients.

+ The _cell space_: a one-, two- or three-dimensional grid of cells.
+ The _neighborhood_ of each cell: the cells whose states it can see.
+ The _state set_ $Sigma:$ a finite set of states, encoded by symbols, numbers
  or colors.
+ The _transition rule_: the function that computes the next state of a cell.
+ The _boundary condition_: what the cells at the edge of a finite grid see.
+ The _initial condition_: the state of every cell at time zero.

In almost every model the cells are squares, but other shapes that tile the
plane are possible, as @fig:grid-neighborhoods shows. In a _hexagonal_ grid
every cell has six neighbors, all sharing an edge with it and all at the same
distance from its center, which avoids the distinction between side and corner
neighbors of the square grid. In a _triangular_ grid, triangles point
alternately up and down; each shares an edge with three others. Both shapes are
rarely used.

In one dimension the neighborhood is described by a _radius_ $r:$ a cell sees
the $r$ cells on each side, so together with itself its neighborhood contains
$2r + 1$ cells. In two dimensions there are two standard choices. The _von
Neumann neighborhood_ contains the four cells that share a side with the central
cell; the _Moore neighborhood_ adds the four diagonal cells, for eight neighbors
in total. The same distinction exists in three dimensions, where a cube has six
face neighbors and twenty-six neighbors if edges and corners are included.

#figure(
  image("../images/chapter11/grid-neighborhoods.pdf", width: 100%),
  caption: [
    Neighborhoods of the dark central cell: von Neumann (four side neighbors)
    and Moore (eight neighbors) on a square grid, the six neighbors of a
    hexagonal cell, and the three edge neighbors of a triangular cell.
  ],
) <fig:grid-neighborhoods>

=== The transition rule

Write $s_i (t) in Sigma$ for the state of cell $i$ at time $t$ and $N(i)$ for
its neighborhood, which by convention includes $i$ itself. The transition rule
is a function $f$ that maps the states of the neighborhood at time $t$ to the
state of the cell at time $t + 1:$

$ s_i (t+1) = f(s_j (t) : j in N(i)). $

In one dimension with radius $r$ this reads
$s_i (t+1) = f(s_(i-r)(t), dots, s_i (t), dots, s_(i+r)(t)).$ Three properties
are built into this definition. The rule is _local_, because a cell sees only
its neighborhood. The same $f$ applies to every cell, a property called _total
homogeneity_; unlike the agents of an agent-based model, cells never differ in
behavior. The update is _synchronous_: all next states are computed from the
states at time $t,$ and then all cells switch together.

Since $Sigma$ and $N(i)$ are finite, $f$ can be written as a table listing the
next state for every possible configuration of the neighborhood. With $k$ states
and $n$ cells in the neighborhood there are $k^n$ configurations, and in one
dimension $n = 2r + 1,$ which gives $k^(2r+1)$ rows. This number grows so
quickly that listing the table becomes impractical. A _totalistic_ rule avoids
it by depending only on how many cells of the neighborhood are in each state,
regardless of their positions: "a cell becomes yellow if at least five of its
neighbors are yellow". An _outer-totalistic_ rule depends on the state of the
cell itself and on the counts over the other cells of the neighborhood.

#example-box(title: "How much a totalistic rule saves")[
  Take binary states, $k = 2,$ and the Moore neighborhood, so $n = 9$ cells
  including the center. A general rule must list $2^9 = 512$ configurations. An
  outer-totalistic rule needs only the state of the center (two values) and the
  number of live cells among its eight neighbors (nine values, from $0$ to $8$),
  hence $2 times 9 = 18$ cases. The number of distinct rules falls from $2^512$
  to $2^18 = 262 144.$

  In one dimension with $k = 3$ states and radius $r = 1,$ a general rule has
  $3^3 = 27$ configurations. A totalistic rule depends on how many of the three
  cells are in each state, that is on a multiset of size three drawn from three
  states; there are $binom(3 + 2, 2) = 10$ such multisets.
]

=== Boundaries, initial states and visualization

Grids are finite, so the neighborhood of a cell on the edge is incomplete and a
_boundary condition_ must say what lies beyond the edge. The usual device is a
layer of _ghost cells_ outside the grid whose states are determined by the
condition, illustrated in @fig:boundary-conditions for a row of six cells.

+ _Periodic_: the grid is closed on itself, so the cell beyond the last one is
  the first one; a 2D grid becomes a torus. This is the most common choice.
+ _Fixed_: every ghost cell has a constant external state.
+ _Adiabatic_: each ghost cell copies the state of the edge cell next to it, so
  no difference is felt across the boundary.
+ _Reflecting_: the ghost cell copies the state of the cell one step inside the
  edge, as in a mirror placed on the boundary.
+ _Absorbing_: used when the states represent moving entities, such as cars on a
  road, which simply disappear when they cross the edge.

#figure(
  image("../images/chapter11/boundary-conditions.pdf", width: 62%),
  caption: [
    Ghost cells (grey) added at both ends of a row of cells $a, dots, f$ under
    four boundary conditions: periodic wrapping, a fixed external state $0,$
    adiabatic copying of the edge cell, and reflection of the cell next to the
    edge.
  ],
) <fig:boundary-conditions>

The initial condition assigns a state to every cell, and cells need not start in
the same state. Since the rule is deterministic, an initial configuration
determines a single evolution, so the standard methodology is to run the
automaton from many different initial configurations, often random ones, and
look for behavior that recurs. An execution is a sequence of iterations, each
updating all cells at once. A one-dimensional automaton is visualized as a
_space-time diagram_: the initial row of states on top, each subsequent row one
step later, so time runs downward and one looks for patterns that repeat over
time. A two-dimensional automaton is shown as an animation of successive grids,
in which one looks for spatial structures that persist or move. Even a table
chosen at random is worth running: the rule is then fixed and deterministic, it
simply has no designed meaning, and structured patterns may still appear.

A grid is a very regular graph, so cellular automata are a special case of a
more general construction in which cells are the nodes of an arbitrary network
and the neighborhood of a node is given by its edges; network environments in
agent-based models generalize them in exactly this way.

== One-Dimensional Automata: Traffic and Wolfram's Rules

One-dimensional automata look trivial, but even the smallest of them shows
emergent behavior and a surprising range of dynamics.

=== Single-lane traffic

A single-lane road where all cars travel in the same direction is a row of
locations, each either empty $(0)$ or holding one car $(1).$ A car advances by
one location per step if the location in front of it is free and waits
otherwise. The next state of a location therefore depends on the location itself
and on the ones immediately behind and in front: a radius-one neighborhood.
Reading each configuration as (`behind`, `here`, `in front`), the eight cases
are the following. If `here` is occupied and `in front` is occupied, the car
waits and `here` stays occupied. If `here` is occupied and `in front` is free,
the car leaves and `here` becomes empty. If `here` is empty and `behind` is
occupied, the car behind arrives. If `here` and `behind` are both empty, `here`
stays empty. With binary states, radius one and a single dimension, this is the
simplest kind of automaton one can define; the complete rule is

#table(
  columns: (auto,) + (1fr,) * 8,
  align: center,
  table.header(
    [Configuration],
    [`111`],
    [`110`],
    [`101`],
    [`100`],
    [`011`],
    [`010`],
    [`001`],
    [`000`],
  ),
  [Next state], [1], [0], [1], [1], [1], [0], [0], [0],
)

#example-box(title: "Traffic on a ring of eight cells")[
  Take a periodic road of eight cells, numbered $0$ to $7,$ with cars in cells
  $0, 1, 3$ and $6:$ the configuration is `11010010`. A cell becomes $1$ when it
  holds a car whose front cell is occupied, or when it is empty and the cell
  behind it holds a car.

  _Step 1._ The car in cell $0$ has a car in front and waits, so cell $0$ stays
  $1.$ The cars in cells $1,$ $3$ and $6$ have free cells in front and move to
  cells $2,$ $4$ and $7.$ The new configuration is `10101001`.

  _Step 2._ By periodicity the cell in front of cell $7$ is cell $0,$ which is
  occupied at the start of the step, so the car in cell $7$ waits, even though
  the car in cell $0$ leaves during the same step: all cells read the states at
  time $t.$ The cars in cells $0,$ $2$ and $4$ have free cells in front and move
  to $1,$ $3$ and $5.$ The configuration becomes `01010101`.

  _Step 3._ Every car now has a free cell in front, so all four advance and the
  configuration shifts by one cell at every step. The number of cars stays four
  throughout, and the small jam at cells $0$ and $1$ has dissolved.
]

Starting from a random distribution of cars, the space-time diagram of
@fig:rule184-spacetime shows the emergent phenomenon: queues. Each jam appears
as a black stripe, and because cars leave a jam from its front while new cars
join at its back, the jam itself drifts backward, against the direction of
travel. The control parameter is the _density_ $rho$ of cars. For $rho < 1\/2$
every jam eventually dissolves and all cars flow freely. For $rho > 1\/2$ jams
persist forever. The threshold has a simple explanation: free flow requires an
empty cell in front of every car, which is possible only if there are at least
as many empty cells as cars. The road is periodic, so the car that exits on the
right re-enters on the left, as on a ring road. This is the typical analysis of
an automaton: vary the initial condition, identify the emergent behavior and
find the parameter that causes it.

#figure(
  image("../images/chapter11/rule184-spacetime.pdf", width: 92%),
  caption: [
    Space-time diagrams of the traffic automaton (Rule 184) on a periodic road
    of 60 cells, time running downward and cars moving right. At density
    $rho = 0.3$ (left) the initial jams dissolve into free flow; at $rho = 0.7$
    (right) jams persist as black stripes drifting backward.
  ],
) <fig:rule184-spacetime>

=== Wolfram numbering and the four classes

The traffic rule is one of many automata with binary states and radius one,
called _elementary_ cellular automata. Each is determined by the next state it
assigns to the eight configurations, so there are exactly $2^8 = 256$ of them,
few enough to be studied one by one. Stephen Wolfram, the mathematician who
later created the Mathematica system, did so and introduced a numbering. List
the configurations in decreasing binary order, `111`, `110`, ..., `000`, as in
the table above; the eight next states then form an eight-bit binary number, and
its decimal value is the _rule number_. For the traffic rule the bits are
`10111000`, and

$
  1 dot 2^7 + 0 dot 2^6 + 1 dot 2^5 + 1 dot 2^4 + 1 dot 2^3 = 128 + 32 + 16
  + 8 = 184,
$

so single-lane traffic is _Rule 184_.

Running all 256 rules from random initial rows, Wolfram found four kinds of
global behavior, the _Wolfram classes_ illustrated in @fig:wolfram-classes. In
_class 1_ all cells quickly reach the same state and the diagram becomes
uniform. In _class 2_ simple periodic patterns emerge, such as stable or
oscillating stripes. In _class 3_ the patterns are non-periodic and look
chaotic, at least over the observed time span. In _class 4_ localized
structures, such as small triangles and particles, persist and move against a
regular background and interact when they collide. Strictly, every finite
automaton is eventually periodic: a ring of $L$ binary cells has $2^L$
configurations, so within $2^L$ steps some configuration must repeat, and from
then on the evolution loops. For $L = 120$ the bound $2^120$ is astronomically
larger than any feasible simulation, which is why class 3 behavior is
indistinguishable from chaos in practice.

#figure(
  image("../images/chapter11/wolfram-classes.pdf", width: 100%),
  caption: [
    Representatives of the four Wolfram classes, run for 90 steps from the same
    random row of 120 cells with periodic boundaries: Rule 160 (homogeneous),
    Rule 108 (periodic), Rule 30 (chaotic) and Rule 110 (localized structures).
  ],
) <fig:wolfram-classes>

=== Rule 30 as a random-number generator

The apparent chaos of class 3 can be put to use. _Rule 30_ has bits `00011110`,
so it maps `100`, `011`, `010` and `001` to $1$ and the other four
configurations to $0.$ A compact way to state it is
$s_i (t+1) = s_(i-1)(t) xor (s_i (t) or s_(i+1)(t)),$ where $xor$ is exclusive
or. Wolfram used this automaton as the random-number generator of Mathematica:
the sequence of states taken over time by a single cell looks random, and
reading it as a sequence of bits yields numbers whose distribution looks
uniform. Generating random numbers with a deterministic machine is a hard
problem, usually solved with elaborate arithmetic; here a three-cell rule does
the job.

#example-box(title: "Rule 30 from a single live cell")[
  Start from a row with a single $1$ at position $0$ and $0$ everywhere else.
  Apply $s_i (t+1) = s_(i-1)(t) xor (s_i (t) or s_(i+1)(t)).$

  _Step 1._ Position $-1$ has right neighbor $1,$ so $0 xor 1 = 1.$ Position $0$
  gives $0 xor (1 or 0) = 1,$ and position $1$ has left neighbor $1$ and gives
  $1 xor 0 = 1.$ The row reads `111` on positions $-1$ to $1.$

  _Step 2._ On positions $-2$ to $2$ the rule gives $0 xor 1 = 1,$
  $0 xor 1 = 1,$ $1 xor 1 = 0,$ $1 xor 1 = 0$ and $1 xor 0 = 1,$ so the row is
  `11001`.

  _Step 3._ On positions $-3$ to $3$ the row becomes `1101111`.

  The center cell has taken the values $1, 1, 0, 1$ so far; continued further,
  this column never settles into a visible period, and it is the bit stream used
  as a random source.
]

#enrichment-box(
  title: "Optional enrichment: computing with an elementary rule",
)[
  Rules can also be designed to compute. Rule 240, with bits `11110000`, simply
  copies the left neighbor: $s_i (t+1) = s_(i-1)(t).$ Every pattern therefore
  shifts one cell to the right per step. If a row of fixed length holds a number
  in binary, most significant bit on the left, and the leftmost ghost cell is
  fixed at $0,$ one step turns `0110` (six) into `0011` (three): each step
  divides the number by two, discarding the remainder. The computation is fully
  distributed, each cell reading only its neighbor.
]

== Two-Dimensional Automata: The Game of Life and Beyond

=== Conway's rules

The most famous two-dimensional automaton is John Conway's _Game of Life_. Its
aim was to obtain patterns that look alive from rules as simple as possible.
Cells are binary, _alive_ (black) or _dead_ (white), and each cell looks at its
Moore neighborhood of eight cells. The rule has three parts, named after a loose
analogy with life.

+ _Birth_: a dead cell with exactly three live neighbors becomes alive.
+ _Survival_: a live cell with two or three live neighbors stays alive.
+ _Death_: in every other case the cell is dead at the next step, whether by
  isolation (fewer than two live neighbors) or by overcrowding (more than
  three).

The rule depends only on the state of the cell and on the number of live
neighbors, so it is outer-totalistic, with the eighteen cases counted earlier.

#example-box(title: "The blinker")[
  Three live cells in a horizontal row, at positions $(2, 1),$ $(2, 2)$ and
  $(2, 3)$ (row, column), form a _blinker_. Count live neighbors for the cells
  that matter.

  _Step 1---the center._ Cell $(2, 2)$ is alive and has two live neighbors,
  $(2, 1)$ and $(2, 3),$ so it survives.

  _Step 2---the ends._ Cell $(2, 1)$ is alive with one live neighbor, $(2, 2),$
  so it dies; by symmetry so does $(2, 3).$

  _Step 3---above and below._ The dead cells $(1, 2)$ and $(3, 2)$ each touch
  all three live cells, so each has exactly three live neighbors and is born. A
  dead corner such as $(1, 1)$ touches only $(2, 1)$ and $(2, 2)$ and stays
  dead.

  The result is a vertical row of three cells centered at $(2, 2).$ The same
  computation turned by ninety degrees brings the horizontal row back, so the
  blinker oscillates with period two.
]

Despite these minimal rules, a zoo of patterns emerges, shown in part in
@fig:game-of-life. _Still lifes_, such as the $2 times 2$ block, never change
once reached. _Oscillators_, such as the blinker, stay in place and cycle
through a few configurations. _Spaceships_ travel across the grid: the _glider_,
made of five live cells, returns to its own shape after four steps, shifted by
one cell diagonally, and keeps moving forever; larger ships are called
lightweight, middleweight and heavyweight spaceships according to their size.
_Glider guns_ are configurations that periodically emit gliders, and _eaters_
are configurations that absorb the gliders hitting them. Starting from a random
initial grid, many of these structures appear spontaneously as the chaotic
initial activity settles.

#figure(
  image("../images/chapter11/game-of-life.pdf", width: 88%),
  caption: [
    Game of Life patterns. Top: a glider at steps $0$ to $4;$ after four steps
    it has the same shape, moved one cell down and one cell right. Bottom: the
    block, a still life, and the blinker, an oscillator of period two.
  ],
) <fig:game-of-life>

=== Computing with gliders

The Game of Life also measures the expressive power of cellular automata. A
finite grid with finitely many states is a finite-state system, so it cannot be
Turing-complete as such; but the time dimension, together with an unbounded
grid, can be exploited to represent information. Gliders provide signals: a
glider gun emits a regular stream, and a stream can encode a sequence of Boolean
values, with a glider standing for $1$ and a gap for $0.$ Collisions provide
operations. If a stream carrying a value crosses a second stream coming from a
gun, gliders annihilate where both are present, so the second stream lets a
glider through exactly where the first had a gap, which is the negation of the
input. Suitably engineered collisions implement all logical operators, eaters
delete signals and other configurations preserve them as memory. With operators
and memory one can encode data structures and programs, and a complete Turing
machine has been built this way, with its finite control and its tape made of
guns, gliders and eaters. The construction has no practical use, but it shows
that from three simple rules the most complex behavior one can imagine,
universal computation, emerges.

=== Solving a maze

Once simple local rules are known to produce algorithms, they can be designed
for a purpose. A maze is represented on a two-state grid, with wall cells and
free cells, and the goal is a path from the entrance to the exit. The rule is: a
free cell with only one free cell among its four side neighbors is a _dead end_
and becomes a wall; the entrance and exit are never filled. Applied
synchronously and repeatedly, the rule consumes every dead-end corridor from its
tip backward, and when nothing changes any more the free cells that remain are
exactly the solution path, as @fig:maze-solving shows for a maze without loops.
Each cell looks only at its four neighbors, yet the grid as a whole solves a
global search problem, with a rule far simpler than a centralized algorithm that
explores paths and backtracks.

#figure(
  image("../images/chapter11/maze-solving.pdf", width: 100%),
  caption: [
    Maze solving by dead-end filling on a $21 times 21$ grid. Free cells are
    white and walls black; the entrance (top left) and exit (bottom right) are
    marked. Every step turns into a wall each free cell with a single free side
    neighbor, until only the path from entrance to exit remains.
  ],
) <fig:maze-solving>

=== Particle and probabilistic automata

Two variants extend the basic formalism. _Particle cellular automata_, popular
in physical modeling of particles moving in space, apply the rule to a $2 times
2$ block of cells at once rather than to a single cell: the rule reads the four
cells of the block and writes all four together. At each iteration the grid is
partitioned into blocks, all blocks are updated, and at the next iteration the
partition is shifted by one cell in both directions, so that effects propagate
across block borders. Updating a block as a whole makes synchronized changes
easy to express, for example two particles side by side that move together,
which a single-cell rule can describe only with difficulty. Such models show
what happens to particles near obstacles or under friction that prevents them
from moving or forces them to move together.

In a _probabilistic cellular automaton_, a neighborhood configuration may have
several possible next states, each with a probability, so the rule assigns a
probability distribution over $Sigma$ instead of a single state. This makes the
automata much more useful as models of real systems. The particle model above is
typically probabilistic: from a given block configuration, two particles either
both stay or both move, with given probabilities, which mimics friction. Fire
spreading through a forest is another classical example, since ignition depends
on random effects.

#example-box(title: "A probabilistic forest fire")[
  Each cell is empty, a tree, or burning. A burning cell becomes empty at the
  next step. A tree catches fire from each burning neighbor independently with
  probability $p = 0.4.$ Consider a tree with two burning neighbors.

  It stays unburnt only if neither neighbor ignites it, which has probability
  $(1 - 0.4) dot (1 - 0.4) = 0.36.$ It therefore burns at the next step with
  probability $1 - 0.36 = 0.64,$ and remains a tree with probability $0.36.$ A
  tree with one burning neighbor burns with probability $0.4,$ and a tree with
  no burning neighbor stays a tree. Running the automaton from a single burning
  cell produces a different fire front each time, and the relevant output
  becomes statistical, for instance the fraction of the forest burnt.
]

In all these variants the goal of modeling with cellular automata is the one
stated at the beginning: patterns, from fluid-like flows of particles to
fractals, that emerge from very simple local rules.

/*
== Implementing Models: NetLogo and Mesa

Cellular automata and agent-based models share a structure: the environment is a
cellular automaton, homogeneous in its rules, and the agents placed on it may
differ from one another in behavior, rules and goals, and move from cell to
cell. Any general-purpose language can implement this structure, since an agent
is an object whose step method is called inside a loop over a data structure
representing the environment. Dedicated tools and libraries are nevertheless
widely used, for three reasons: they impose a systematic, commonly accepted
structure on the model; they provide the repetitive parts, such as scheduling
and data collection; and they offer visualization of running simulations for
free.

The main options differ in language and scale. _NetLogo_ is the traditional
tool, with its own programming language, and is presented in detail below.
_Mesa_ is a Python library, also presented below. _Agents.jl_ serves the
high-performance language Julia, and _AgentScript_ is a lighter JavaScript
library whose models run directly in a browser. _Repast_ and _MASON_, written in
Java, were for years the reference libraries and remain the choice for models
with very large populations, on the order of a million agents. _GAMA_ has its
own modeling language and is designed for models whose environment is a
geographic information system, such as the map of a city, for urban development
and traffic studies.

=== NetLogo

NetLogo descends from _Logo_, an old teaching language in which a _turtle_ with
coordinates and a pen, either drawing or not, draws figures on a surface through
commands such as "move three steps right". In NetLogo the agents are therefore
called _turtles_, and the cells of the grid environment are called _patches_.
Both have predefined variables, such as `color` and `size` used for display, and
can be given additional ones; subtypes of turtles and patches can also be
declared. The tool is organized in three tabs: _Interface_, showing the
environment and graphical controls such as sliders, buttons and plots; _Info_, a
description of the model; and _Code_. A huge model library, classified by
discipline and topic, contains hundreds of documented models, which makes
NetLogo especially valuable for learning, while its reporting facilities (plots,
tables, export to files) are basic, so it is mainly used to watch simulations
live.

The _ants_ model of the library implements the stigmergy mechanism. The
interface has three sliders, `population` (number of ants), `diffusion-rate`
(how fast released chemical spreads to neighboring patches) and
`evaporation-rate` (how fast it disappears), and two buttons. `setup`
initializes a grid with ordinary patches, a nest in the center and three food
sources; `go` runs the simulation. The essential code is the following.

```netlogo
patches-own [ chemical food nest? nest-scent food-source-number ]

to setup
  clear-all
  set-default-shape turtles "bug"
  create-turtles population [ set size 2 set color red ]
  ask patches [ setup-nest setup-food recolor-patch ]
  reset-ticks
end

to setup-nest                       ;; patch procedure
  set nest? (distancexy 0 0) < 5
  set nest-scent 200 - distancexy 0 0
end

to go                               ;; called by a forever button
  ask turtles [
    if who >= ticks [ stop ]        ;; leave the nest one by one
    ifelse color = red [ look-for-food ] [ return-to-nest ]
    wiggle
    fd 1 ]
  diffuse chemical (diffusion-rate / 100)
  ask patches [ set chemical chemical * (100 - evaporation-rate) / 100
                recolor-patch ]
  tick
end

to look-for-food                    ;; turtle procedure
  if food > 0 [ set color orange + 1  set food food - 1  rt 180  stop ]
  if (chemical >= 0.05) and (chemical < 2) [ uphill-chemical ]
end

to return-to-nest                   ;; turtle procedure
  ifelse nest? [ set color red  rt 180 ]
               [ set chemical chemical + 60  uphill-nest-scent ]
end

to wiggle                           ;; turtle procedure
  rt random 40  lt random 40
  if not can-move? 1 [ rt 180 ]
end
```

The first line adds variables to every patch: the amount of `chemical`, the
amount of `food`, the Boolean `nest?` (a trailing question mark marks a
Boolean), the `nest-scent` and the number of the food source. Procedures are
defined with `to ... end`, may take parameters in square brackets, and are
attached to buttons. `setup` clears the world, creates `population` turtles with
size and color set, and initializes all patches. The keyword `ask` is a for-each
loop over a set of agents: all patches, all turtles, or any subset. In
`setup-nest` the origin of the coordinates is the center of the grid, and the
built-in `distancexy 0 0` gives the distance of the current patch from it;
patches within distance five form the nest. Every patch also receives
`nest-scent` equal to $200$ minus that distance, a value that grows toward the
nest, so an ant carrying food finds the way home by always moving to the
neighboring patch with the largest scent, which is what `uphill-nest-scent`
does.

`go` performs a single tick. The loop over ticks is supplied by the interface:
the `go` button is a _forever_ button, which calls the procedure repeatedly
until it is pressed again. Inside `ask turtles`, the line
`if who >= ticks [ stop ]` staggers the departure: `who` is the sequential
identifier of a turtle, starting from zero, and `ticks` is the global clock, so
at tick $t$ only turtles with identifier below $t$ move, and the ants leave the
nest one by one. The color doubles as a state variable: red ants are searching
and run `look-for-food`, orange ants carry food and run `return-to-nest`. A
searching ant that finds food picks it up, turns orange, reduces the food of the
patch and turns around by 180 degrees; otherwise it moves up the chemical
gradient when it smells enough chemical. A returning ant that reaches the nest
drops the food, turns red and turns around; otherwise it adds 60 units of
chemical to its patch and heads toward the nest. `wiggle` adds a random turn,
right and then left by up to 40 degrees each (`rt` and `lt` stand for right and
left turn), and makes the ant turn back at the border of the world. Finally the
environment updates: chemical diffuses to neighboring patches and evaporates by
`evaporation-rate` percent on every patch.

The code also shows NetLogo's scoping rule. Inside `ask turtles`, and inside the
procedures called from there, the code sees the global variables, the variables
of the current turtle, such as `color`, and the variables of the patch on which
the turtle stands, such as `food` and `chemical`.

Running the model, the ants first wander randomly; when some of them find food
and return, the chemical trails become visible, other ants intercept them and
follow them, and a plot shows the three food sources being emptied, usually the
nearest one first. When the food is finished the ants go on wandering, since the
model contains no death. Setting the diffusion rate to zero produces thin trails
that other ants rarely intercept, while raising the evaporation rate makes the
trails disappear sooner; both slow down foraging.

=== The NetLogo model library

A few other library models illustrate the range of the tool. The _flocking_
model implements boids with sliders for separation, alignment and cohesion and
for the vision radius of the birds, on a periodic world. _Wolf---sheep
predation_ is a prey-predator model, but unlike the Lotka---Volterra equations
it limits interactions spatially, since a wolf can eat a sheep only if they are
on the same or a nearby patch. With the default parameters the populations
oscillate, but one of them may go extinct; a variant adds grass that sheep eat
and that regrows only after some time, giving three interacting populations
whose oscillations persist or damp depending on the regrowth parameter. The
_cellular automata_ folder contains models that use only patches, which is
exactly a cellular automaton, among them the Game of Life, with random or
hand-drawn initial patterns in which blinkers and gliders appear. A _k-means
clustering_ model implements the clustering algorithm with agents: centroids are
attracted by the points, one cluster per centroid, until they stabilize. The
_virus on a network_ model places individuals on the nodes of a network, so that
each can infect only its neighbors; after an infection an individual either
becomes susceptible again or, with a given probability (for example five
percent), becomes resistant. Such a topology is more realistic than assuming
that every individual of a whole region can infect every other. The _Lunar
Lander_ game shows that buttons can also be bound to keyboard keys to steer a
spacecraft to a landing.

=== Mesa

Mesa is a Python library for agent-based modeling, recent but growing fast and
now production ready; the stable releases belong to the 3.x series. Being
Python, it lets models use the whole Python ecosystem, both inside the agents,
for example embedding machine-learning models in their behavior, and for
collecting and analyzing simulation results with standard data-analysis
libraries. Its visualization is based on _Solara_, which builds a web interface
served locally with a single command. A minimal model needs three ingredients.
An `Agent` subclass, whose instances receive a unique identifier and implement a
`step` method. A `Model` subclass, the container of all agents, which defines
the space and the model's own `step`, called repeatedly by the simulation,
specifying how the agents' steps are invoked. Optionally, a `DataCollector` that
records variables over time. Predefined spaces include grids, in which
`SingleGrid` allows one agent per cell and `MultiGrid` several; a
two-dimensional `ContinuousSpace` with real coordinates; a `NetworkGrid`; and a
_Voronoi_ space, which covers the plane with irregular polygonal cells, each
containing the points closest to a given seed. Agents are grouped in _agent
sets_, collections that can be iterated, filtered and shuffled.

```python
import mesa
from mesa.discrete_space import CellAgent, OrthogonalMooreGrid


class AgingAgent(CellAgent):
    def __init__(self, model, cell, age):
        super().__init__(model)
        self.cell = cell
        self.age = age

    def step(self):
        self.age += 1


class AgingModel(mesa.Model):
    def __init__(self, n=20, seed=None):
        super().__init__(seed=seed)
        self.grid = OrthogonalMooreGrid((10, 10), torus=True, random=self.random)
        for _ in range(n):
            cell = self.random.choice(self.grid.all_cells.cells)
            AgingAgent(self, cell, age=self.random.randint(0, 50))

    def step(self):
        self.agents.shuffle_do("step")


model = AgingModel()
for _ in range(100):
    model.step()
```

The agent has a single variable, `age`, initialized randomly by the constructor,
and its behavior is to grow older at every step. The environment is a
$10 times 10$ grid with Moore neighborhood, and `torus=True` sets periodic
boundaries. The model creates the agents and places each in a random cell. Its
`step` calls `shuffle_do("step")` on the set of all agents, which invokes the
`step` method of every agent in a random order that changes at every tick:
exactly the randomized synchronous update recommended earlier. The argument is
the name of the method to call, so an agent may define several behaviors, such
as `move` and `eat`, invoked at different moments with separate calls. By
default the model's time advances by one at each step, so running for a number
of steps and running up to a time coincide, but time can be customized.

The Mesa examples include a boids model whose agents subclass a continuous-space
agent and apply separation, alignment and cohesion in their `step`. Its code is
split into an agents file, a model file and an application file that configures
the Solara visualization; the command `solara run app.py` starts a local web
server with the running environment, controls for the simulation, sliders for
the parameters and optional charts. The experience is close to NetLogo, although
the animation is slower. Mesa also supports _event scheduling_: actions can be
scheduled at given times, so that different agents act at different instants and
the simulation is no longer driven by ticks.

This last feature leads beyond the tick-based view of time adopted throughout
this chapter. Chapter 12 develops discrete-event simulation, in which the model
jumps from one scheduled event to the next, and then reinforcement learning, the
learning approach in which agents discover their rules from rewards instead of
receiving them from the modeler.
*/
