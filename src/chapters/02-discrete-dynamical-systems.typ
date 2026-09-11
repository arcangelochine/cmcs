#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Discrete Population Dynamics: Recurrence Relations",
  abstract: [
    Recurrence relations describe discrete-time dynamical systems where
    variables update at fixed steps. This chapter builds from exponential growth
    through death, migration, and the logistic equation to systems of coupled
    recurrences, introducing phase portraits, equilibria, and chaotic dynamics.
  ],
  toc: true,
)

== Recurrence Relations and Pure Growth

A _recurrence relation_ specifies how a variable at time $t+1$ depends on values
at time $t:$

$ n_(t+1) = f(n_t) $

Population size is the standard motivating example. Time advances in discrete
steps; all variables update together. We begin with simplifying assumptions:
identical individuals, unlimited resources, reproduction every $sigma$ time
units with $lambda$ offspring per event, no deaths within a step, and no
reproduction by newborn offspring in the same step.

Over an interval $Delta t,$ new individuals are proportional to the current
count: each individual reproduces on average $(Delta t) / sigma$ times, with
$lambda$ offspring per event. Summing birth and survival of the parent yields

$ n_(t+Delta t) = n_t + (lambda (Delta t) / sigma) n_t $

The factor multiplying $n_t$ on the right is the discrete birth rate
$R_d = 1 + lambda (Delta t) / sigma,$ which is at least 1 whenever reproduction
occurs. If we choose the step size $Delta t$ as the time unit, the update
simplifies to $n_(t+1) = R_d n_t:$ each step multiplies the population by the
constant factor $R_d.$

#example-box(title: "Bacteria")[
  Consider bacteria that duplicate every twenty minutes. Measuring time in
  hours, the reproduction interval is $sigma = 1\/3$ and each event produces
  $lambda = 1$ offspring. Taking one duplication as the step size,
  $Delta t = 1\/3,$ we obtain $R_d = 1 + (1 times 1\/3) / (1\/3) = 2.$

  Starting from a single bacterium $(n_0 = 1),$ the first step yields
  $n_1 = 2 n_0 = 2,$ the second yields $n_2 = 4,$ and the third yields
  $n_3 = 8.$ Each step is one duplication event, so the population doubles at
  every update.
]

#example-box(title: "Fish")[
  Now suppose female fish reproduce every two months $(sigma = 2),$ each event
  produces four female offspring $(lambda = 4),$ and we advance in six-month
  steps $(Delta t = 6).$ Within one step each female reproduces three times, so
  the net factor is $R_d = 1 + 3 times 4 = 13.$

  From $n_0 = 1,$ a single step gives $n_1 = 13.$ A plot of $n_t$ against $t$
  rises far more steeply than in the bacterial case, though the same exponential
  law $n_t = R_d^t n_0$ governs both.
]

Choosing $Delta t$ matters. If $Delta t < sigma,$ reproduction is missed within
a step. If $Delta t$ is not a multiple of $sigma,$ growth is uneven across
steps. For fish with $sigma = 2$ months, a step of one month would require
artificially splitting reproduction across steps. Align the step with the
natural rhythm of the process so that the growth rate $R_d$ remains constant
from step to step.

The variable $n_t$ can represent either absolute population size or density,
such as individuals per square kilometer. The mathematics is identical; only the
interpretation of units changes. Recurrence relations also appear in algorithm
analysis, where $T(n)$ denotes the execution time of a recursive algorithm on
input size $n,$ and $T(n) = T(n-1) + c$ is a recurrence analogous to population
growth with migration. The techniques developed here for solving and visualizing
recurrences apply broadly across discrete dynamical systems.

Collecting all constants into $R_d$ simplifies iteration and analysis. Once
$R_d$ is computed from biological parameters, the recurrence depends on a single
rate parameter. This parameterization is standard in population ecology: the net
reproductive rate summarizes birth and death into one number that determines
whether the population grows, stays constant, or declines. The next sections
decompose $R_d$ again into birth and death components before recombining them as
the net growth rate $alpha.$

Plotting $n_t$ against $t$ for bacteria $(R_d = 2)$ and fish $(R_d = 13),$ both
starting from $n_0 = 1,$ produces dramatically different curves. After five
steps the bacteria count is $2^5 = 32,$ whereas the fish count is
$13^5 approx 371000.$ The steepness of the curves suggests exponential growth in
both cases; the induction argument below confirms that the closed form is
$n_t = R_d^t n_0,$ with base $R_d$ rather than $e.$

#figure(
  image("../images/chapter2/growth-bacteria-fish.pdf", width: 70%),
  caption: [
    Population growth for bacteria $(R_d = 2)$ and fish $(R_d = 13),$ both with
    $n_0 = 1,$ on a logarithmic scale.
  ],
) <fig:growth-bacteria-fish>

== Closed Solutions, Phase Portraits, and Death

Repeated application of $n_(t+1) = R_d n_t$ suggests the closed form
$n_t = R_d^t n_0.$

#proof-box[
  We verify it by induction.

  At $t = 0$ the identity holds because $R_d^0 = 1.$

  Assuming $n_k = R_d^k n_0$ for some $k >= 0$

  $n_(k+1) = R_d n_k = R_d dot (R_d^k n_0) = R_d^(k+1) n_0$

  Thus the formula holds for all non-negative integers $t.$ Growth is therefore
  exponential in the step index, with base $R_d.$
]

A _phase portrait_ plots the next value $n_(t+1)$ against the current value
$n_t,$ together with the bisector $n_(t+1) = n_t$ where the population would
stay unchanged. For pure growth, $n_(t+1) = R_d n_t$ is a line through the
origin with slope $R_d.$ To advance one step graphically, start at $n_0$ on the
horizontal axis, move vertically to the recurrence line, then horizontally to
the bisector. Repeating this construction traces the trajectory. When $R_d > 1,$
successive points drift increasingly far from the bisector, visualizing
exponential divergence.

#figure(
  image("../images/chapter2/phase-portrait-growth.pdf", width: 50%),
  caption: [
    Phase portrait and cobweb trajectory for $n_(t+1) = R_d n_t$ with $R_d = 2$
    and $n_0 = 3.$
  ],
) <fig:phase-portrait-growth>

If a fraction $S in [0,1]$ of the population dies at each step, the update
becomes

$ n_(t+1) = (R_d - S) n_t = alpha n_t $

where $alpha = R_d - S$ is the _net growth rate_. When $alpha > 1,$ growth
remains exponential but slower than without mortality. For bacteria with
$R_d = 2$ and $S = 0.5,$ we have $alpha = 1.5,$ so each step increases the
population by fifty percent. Starting from $n_0 = 100,$ the first three steps
give $n_1 = 150,$ then $n_2 = 225,$ then $n_3 = 337.5.$

When $alpha = 1,$ births and deaths balance exactly: each parent is replaced by
one surviving offspring. With $R_d = 2$ and $S = 1,$ every parent dies but
leaves one descendant, so a population of ten individuals remains at ten even
though turnover is continuous.

When $alpha < 1,$ the population decays toward zero. With $R_d = 1.5$ and
$S = 0.9,$ the net rate is $alpha = 0.6;$ from $n_0 = 100$ we obtain $n_1 = 60,$
then $n_2 = 36,$ then $n_3 = 21.6,$ each step retaining sixty percent of the
previous count.

Death in this model is an _individual_ event: each member of the population has
a constant probability $S$ of dying per step, independent of other individuals.
There is no interaction such as predation or competition for mates. Adding
interaction will introduce nonlinearity and dramatically richer dynamics, as we
will see with the logistic equation. For now, birth and death are proportional
to $n_t,$ keeping the recurrence linear and solvable in closed form.

#figure(
  image("../images/chapter2/phase-portrait-alpha.pdf", width: 100%),
  caption: [
    Phase portraits for $n_(t+1) = alpha n_t$ with $alpha < 1,$ $alpha = 1,$ and
    $alpha > 1.$
  ],
) <fig:phase-portrait-alpha>

The phase portrait for $n_(t+1) = alpha n_t$ with $alpha < 1$ shows points
converging toward the origin along the recurrence line. For $alpha = 1,$ all
points lie on the bisector. For $alpha > 1,$ points diverge from the bisector.
This visual tool becomes indispensable when the recurrence is nonlinear and
trajectories form cycles or chaotic attractors rather than simple convergence or
divergence.

== Migration and Dynamic Equilibrium

_Migration_ adds a constant $beta$ individuals per step regardless of population
size:

$ n_(t+1) = alpha n_t + beta $

When $alpha > 1,$ migration accelerates exponential growth because newcomers
also reproduce. When $alpha = 1,$ births and deaths balance among residents but
migration adds $beta$ per step, producing linear growth $n_t = n_0 + beta t.$
When $alpha < 1,$ decay would occur without migration, but constant influx can
sustain a _dynamic equilibrium_.

An equilibrium $n^*$ satisfies $n^* = alpha n^* + beta.$ Solving for $n^*$ when
$alpha != 1$ gives $n^* = beta / (1 - alpha).$ For instance, with $alpha = 0.5$
and $beta = 10,$ the equilibrium is $n^* = 10 / 0.5 = 20,$ regardless of the
initial population.

Starting above equilibrium $(n_0 = 100),$ each step applies
$n_(t+1) = 0.5 n_t + 10:$ we obtain $n_1 = 60,$ then $n_2 = 40,$ $n_3 = 30,$
$n_4 = 25,$ and $n_5 = 22.5,$ approaching $20$ from above. Starting below
$(n_0 = 5),$ the sequence $12.5,$ $16.25,$ $18.125,$ $dots$ rises toward the
same limit. The trajectory always converges to $n^*,$ whether the initial count
is large or small.

For general $t,$ the solution combines decay of the initial population with the
cumulative effect of migration:

$ n_t = alpha^t n_0 + beta sum_(i=0)^(t-1) alpha^i $

The first term shrinks when $alpha < 1;$ the geometric sum in the second term
captures migrants and their descendants. At equilibrium, arrivals, reproduction,
and deaths balance, so the aggregate count is stable even though individuals
continuously turnover---hence the name _dynamic equilibrium_.

To compute equilibria in general, set $n_(t+1) = n_t = n^*$ and solve. For
linear recurrences the equilibrium is unique when $alpha != 1.$ For nonlinear
models, multiple equilibria may exist, as we will see with the logistic
equation.

#example-box(title: "Equilibrium computation")[
  For the recurrence $n_(t+1) = 0.5 n_t + 10,$ an equilibrium must satisfy
  $n^* = 0.5 n^* + 10.$ Subtracting $0.5 n^*$ from both sides leaves
  $0.5 n^* = 10,$ hence $n^* = 20.$ This agrees with the numerical sequences
  above, where $alpha = 0.5$ and $beta = 10.$ More generally, $n^*$ grows
  linearly with the migration rate $beta$ and shrinks as the net decay
  $1 - alpha$ increases: stronger influx or weaker decay raises the steady
  population.
]

When $alpha > 1$ with migration, growth remains exponential but with a larger
effective rate because migrants and their descendants also reproduce. Comparing
$beta = 5,$ $10,$ and $20$ at fixed $alpha = 1.5$ shows that higher migration
accelerates growth from any initial condition. When $alpha = 1,$ plots show
linear growth with slope equal to $beta.$ These three regimes, exponential,
linear, and equilibrating, exhaust the behavior of the linear recurrence with
migration.

#figure(
  image("../images/chapter2/migration-regimes.pdf", width: 100%),
  caption: [
    Migration with $beta in {5, 10, 20}$ and $n_0 = 5$ for three net-growth
    regimes: exponential growth $(alpha = 1.5),$ linear growth $(alpha = 1),$
    and convergence to equilibrium $(alpha = 0.5).$
  ],
) <fig:migration-regimes>

== The Logistic Equation and Resource Limits

Unlimited growth is unrealistic. The _logistic recurrence_ introduces carrying
capacity $K,$ the maximum population the environment can sustain:

$ n_(t+1) = n_t + r n_t (1 - n_t / K) $

The bracket $(1 - n_t/K)$ modulates growth according to how crowded the
environment is. When $n_t$ is much smaller than $K,$ the factor is close to one
and growth nearly matches the unconstrained case. As $n_t$ approaches $K,$ the
factor tends to zero and additions shrink. Above capacity $(n_t > K),$ the
factor becomes negative and the population declines. Competition is mediated by
the environment rather than by direct combat between individuals.

At a positive equilibrium, setting $n_(t+1) = n_t$ in the logistic recurrence
and cancelling a non-zero $n^*$ yields $n^* = K$ whenever $r > 0.$ With $r = 2$
and $K = 100,$ simulations approach $100$ whether the initial population is
below or above capacity; doubling $K$ to $200$ shifts the equilibrium
accordingly. _Saturation_ names this approach to the ceiling---a term borrowed
from chemistry, where reaction rates level off as substrate is consumed.

Increasing $r$ while holding $K$ fixed produces richer dynamics. At $r = 2.8$
and $K = 50,$ damped oscillations settle to equilibrium. At $r = 3.1,$
_sustained oscillations_ alternate between two values, a period-two attractor
visible as a square in the phase portrait. At $r = 3.5,$ the attractor has four
points; at $r = 3.8,$ the period grows further. Near $r approx 3.57,$
trajectories become _aperiodic_ and _chaotic_: deterministic yet apparently
random.

#figure(
  image("../images/chapter2/logistic-dynamics.pdf", width: 100%),
  caption: [
    Logistic recurrence $n_(t+1) = r n_t (1 - n_t / K)$ for $K = 50$ and
    $n_0 = 10:$ convergence to the equilibrium $K(1 - 1/r)$ $(r = 2.8),$ a
    high-period attractor $(r = 3.8),$ and chaotic dynamics $(r = 4).$ Dashed
    lines mark $K(1 - 1/r);$ dotted lines mark $K.$
  ],
) <fig:logistic-dynamics>

The bifurcation diagram plots attractor values against $r.$ Period doubles at
approximately $r = 3,$ then $3.4,$ then $3.5,$ with intervals decreasing
geometrically so chaos appears before $r = 4.$ A deterministic model that
revisits a previous value must repeat; infinite period means the trajectory
visits infinitely many distinct values without cycling. For $r > 4,$ values can
go negative and lose biological meaning. This classical example demonstrates
that a simple nonlinearity representing resource competition can produce
arbitrarily complex emergent behavior.

#figure(
  image("../images/chapter2/logistic-bifurcation.pdf", width: 60%),
  caption: [
    Bifurcation diagram for $n_(t+1) = r n_t (1 - n_t / K)$ with $K = 50$ and
    $n_0 = 10.$ Vertical dashed lines mark $r = 2.8,$ $3.8,$ and $4,$ the
    parameter values used in @fig:logistic-dynamics.
  ],
) <fig:logistic-bifurcation>

An alternative formulation uses occupancy $x_t = n_t / K$ instead of absolute
population, giving $x_(t+1) = x_t + r x_t (1 - x_t).$ The two forms are related
by the substitution $x_t = n_t / K$ and are found interchangeably in the
literature. We use $n_t$ and $K$ explicitly to keep carrying capacity visible as
a parameter with biological meaning.

#example-box(title: "Logistic saturation")[
  Take $r = 2$ and $K = 100.$ With $n_0 = 10,$ the modulator $(1 - n_0/K) = 0.9$
  is close to one, so the first update gives $n_1 = 10 + 2 dot 10 dot 0.9 = 28.$
  At $n_1 = 28$ the factor is $0.72,$ yielding $n_2 = 68.32;$ two further steps
  bring the count to approximately $95.6$ and then $99.2,$ close to the carrying
  capacity.

  Starting above capacity $(n_0 = 150)$ tells a different story. Here
  $(1 - n_0/K) = -0.5,$ so $n_1 = 150 + 2 dot 150 dot (-0.5) = 0:$ the
  population collapses to zero in a single step. This overshoot is a
  discretization artifact; the continuous logistic would decline smoothly toward
  $K$ instead.
]

== Systems of Recurrences and Implementation

Multiple types require coupled variables. A two-sex fish model might use:

$ F_(t+1) = F_t + r_F F_t (1 - (F_t + M_t)/K) $
$ M_(t+1) = M_t + r_M F_t (1 - (F_t + M_t)/K) - delta M_t $

Females drive reproduction through the term proportional to $F_t;$ both sexes
compete for resources through the modulator $(F_t + M_t)/K;$ males suffer extra
mortality $delta$ from fighting. With $r_F = r_M = 2,$ $K = 100,$ $delta = 0.1,$
females stabilize slightly above males and total population stabilizes near
$K = 100.$

#figure(
  image("../images/chapter2/two-sex-trajectories.pdf", width: 78%),
  caption: [
    Female and male populations in the two-sex model with $r_F = r_M = 2,$
    $K = 100,$ $delta = 0.1,$ $F_0 = 40,$ and $M_0 = 30.$
  ],
) <fig:two-sex-trajectories>

_Age structure_ extends the idea with young $Y_t$ and adults $A_t.$ Children
become adults after three steps; only adults reproduce. One approach introduces
separate variables for each age cohort and rules for maturation between cohorts.
Another tracks how many steps each individual has lived. With adults reproducing
at rate $r$ and carrying capacity $K,$ varying the maturation delay changes
whether the population grows exponentially, reaches equilibrium, or goes
extinct. Such extensions foreshadow compartmental epidemic models where
individuals move between Susceptible, Infected, and Recovered states.

#example-box(title: "Two-sex simulation")[
  Set $r_F = r_M = 2,$ $K = 100,$ $delta = 0.1,$ $F_0 = 40,$ and $M_0 = 30.$ The
  shared modulator is $(F_0 + M_0)/K = 0.7,$ so the reproductive term is
  $2 dot 40 dot 0.3 = 24.$ The first step therefore gives $F_1 = 40 + 24 = 64$
  and $M_1 = 30 + 24 - 0.1 dot 30 = 51.$

  Continuing the iteration, $F_t$ settles near $27$ and $M_t$ near $23,$ for a
  total of approximately $50$---well below $K$ because fight-related mortality
  removes males only. Females therefore outnumber males at equilibrium, while
  both sexes compete for the same resources through the term $(F_t + M_t)/K.$
]

In Python, the same model requires only a few lines: initialize $F$ and $M,$
loop over time steps, update both variables using the recurrence formulas, and
append results to lists for plotting. The computational cost is negligible for
thousands of steps. The intellectual effort lies in formulating the model
correctly, choosing parameters, and interpreting the trajectory, not in
implementation.

== When to Use Discrete Models

Discrete models fit processes with natural step structure: annual census,
seasonal reproduction, generational turnover. A species that reproduces every
spring is naturally modeled with yearly steps aligned to the reproductive
calendar. They also underpin numerical ODE solvers, which advance continuous
dynamics in discrete steps internally. Euler's method, Runge-Kutta methods, and
implicit BDF solvers all implement recurrences under the hood, even when the
user specifies a continuous ODE.

When events occur continuously throughout time, ODEs may be more accurate, but
understanding recurrences remains prerequisite to understanding those solvers.
Discretization introduces approximation error whose magnitude depends on step
size $tau.$ Halving $tau$ typically halves global error for first-order methods
but doubles computation time. The next chapter derives ODEs as limits of the
recurrences developed here, making the discrete-continuous relationship explicit
and explaining why the meaning of terms changes when we pass from $n_(t+1)$ to
$dot(n).$

Suggested exercises include implementing the age-structured model with adults
and children, varying parameters to find regimes of exponential growth,
equilibrium, and extinction, and comparing phase portraits of the logistic
equation at different values of $r$ to observe the transition from convergence
through period doubling to chaos.

The connection to continuous models is direct. When we take the limit
$Delta t -> 0$ in the next chapter, the recurrence
$n_(t+1) = n_t + r n_t (1 - n_t/K)$ becomes the logistic ODE
$dot(n) = r n (1 - n/K).$ The discrete logistic can exhibit chaos at high $r;$
the continuous logistic converges smoothly to $K$ for all positive $r.$ This
difference arises because discretization can overshoot the equilibrium in one
step, triggering oscillations that the continuous model avoids. Understanding
both versions is essential for choosing the right formalism and for interpreting
numerical ODE solvers that discretize continuous equations internally.

Recurrence relations are the foundation of discrete-time population dynamics and
of numerical integration. Mastery of closed-form solutions, phase portraits,
equilibrium analysis, and coupled systems prepares us for differential
equations, where the same concepts appear in continuous time with derivatives
replacing finite differences. The logistic map, in particular, stands as a
canonical demonstration that interaction, even mediated through the environment,
can transform simple growth into chaotic emergent behavior.

== Summary of Modeling Assumptions

Throughout this chapter we accumulated assumptions incrementally. Pure growth
assumes identical individuals, unlimited resources, reproduction every $sigma$
time units with $lambda$ offspring, no death, and no reproduction by newborns
within a step. Death adds proportional removal at rate $S$ per step. Migration
adds constant influx $beta.$ The logistic equation replaces unlimited growth
with competition for resources modulated by carrying capacity $K.$ Coupled
systems distinguish subpopulations with separate update rules linked through
shared resource terms.

Each assumption can be relaxed, at the cost of additional variables or
nonlinearity. Heterogeneous individuals require multiple variables or an
agent-based representation. Spatial structure requires variables per location or
a grid. Stochastic birth and death require probabilities rather than
deterministic rates. The progression from simple to complex follows the
knowledge-driven methodology: start minimal, validate against observation, add
mechanisms only when the simple model fails.

The mathematical tools developed here apply beyond population biology.
Equilibrium analysis by setting $n_(t+1) = n_t$ generalizes to any recurrence.
Phase portraits visualize dynamics regardless of whether $n_t$ represents
organisms, molecules, or dollars. Induction proves closed-form solutions when
the recurrence is linear. Bifurcation analysis reveals how parameter changes
alter qualitative behavior. These techniques reappear in continuous form when we
study ODEs and in stochastic form when we study Markov chains.

#example-box(title: "Comparing growth rates")[
  Bacteria with $R_d = 2$ double at every step, whereas fish with $R_d = 13$
  multiply by thirteen. From $n_0 = 1,$ the closed form $n_t = R_d^t n_0$ gives
  $n_5 = 2^5 = 32$ for bacteria and $n_5 = 13^5 = 371293$ for fish---a
  difference of four orders of magnitude after only five updates. The gap
  reflects both a shorter reproduction interval and a larger litter size in the
  fish model. Aligning the step size with the natural rhythm of each species
  keeps $R_d$ constant and avoids artificial distortion of the growth rate.
]

Discrete models remain the correct choice when the system itself updates at
discrete intervals. Annual population censuses, seasonal breeding cycles, and
generational models in ecology naturally align with step-based dynamics. Even
when the underlying process is continuous, discrete approximations via numerical
integration are how computers actually solve continuous models. Understanding
recurrences is therefore prerequisite to understanding both discrete and
continuous dynamical systems in complex systems science.
