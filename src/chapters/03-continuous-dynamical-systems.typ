#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Continuous Models: Ordinary Differential Equations",
  abstract: [
    Ordinary differential equations describe continuous-time dynamical systems
    through derivatives of state variables. This chapter derives ODEs from
    recurrence relations, solves simple cases analytically, contrasts discrete
    and continuous growth, introduces numerical integration including Euler's
    method and stiff solvers, and demonstrates implementation in Octave and
    Python.
  ],
  toc: true,
)

== From Recurrence Relations to ODEs

Rearranging the pure-growth update
$n_(t+Delta t) = n_t + (lambda (Delta t) / sigma) n_t$ by bringing $n_t$ to the
left and dividing by $Delta t:$

$ (n_(t+Delta t) - n_t) / (Delta t) = (lambda / sigma) n_t $

The left side is a difference quotient, the discrete analogue of a derivative.
As $Delta t -> 0:$

$ dot(n)(t) = R_c n(t) quad "with" R_c = lambda / sigma $

Time $t$ is any real number; the ODE gives the _instantaneous rate of change_,
not the next discrete value. This is an _ordinary differential equation_: a
relation between a function and its derivative. Notation $dot(n)$ and
$(d n) / (d t)$ are equivalent. The continuous rate $R_c$ counts offspring per
unit time, while the discrete rate $R_d$ counted offspring per step.

#example-box[
  With $lambda = 2,$ $sigma = 1$ year, $R_c = 2$ per year, $n_0 = 10:$ after
  half a year $n(0.5) = 10 e^1 approx 27.18;$ after one year $n(1) = 10 e^2
  approx 73.89;$ after two years $n(2) = 10 e^4 approx 545.98.$
]

Separating variables for $dot(n) = R_c n:$ rewrite as $dot(n)/n = R_c,$
recognize the left side as $d/(d t) ln n,$ integrate to obtain
$ln n = R_c t + C,$ and exponentiate to get $n(t) = n_0 e^(R_c t).$ Mathematical
induction cannot be used here because $t$ ranges over uncountably many real
values, not countably many steps.

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  table.header([Feature], [Discrete], [Continuous]),
  [Rate], [$R_d = 1 + lambda (Delta t) / sigma$], [$R_c = lambda / sigma$],
  [Solution], [$n_t = R_d^t n_0$], [$n(t) = n_0 e^(R_c t)$],
  [Equilibrium condition], [$n_(t+1) = n_t$], [$dot(n) = 0$],
)

Growth remains exponential in both cases, but the discrete solution raises $R_d$
to the power $t$ while the continuous solution raises $e$ to the power $R_c t.$
The rates are defined differently because rearranging the difference quotient
absorbed $Delta t$ into the coefficient.

The condition for growth in both settings is that offspring are produced:
$lambda > 0,$ hence $R_d > 1$ in the discrete case and $R_c > 0$ in the
continuous case. In the discrete model, $R_d >= 1$ by construction. In the
continuous model, $R_c$ can be any positive real number, including values less
than one, corresponding to slow growth. The exponential base differs but the
qualitative conclusion, unlimited growth when resources are unconstrained, is
the same.

== Decay, Logistic Growth, and Equilibria

Mortality gives $dot(n) = -B n$ with solution $n(t) = n_0 e^(-B t),$ called
_exponential decay_ after its origin in radioactive decay but applicable to any
proportional removal at rate $B.$

Resource limits yield the _logistic ODE_:

$ dot(n) = r n (1 - n/K) $

When $n << K,$ growth is nearly exponential with rate $r.$ As $n -> K,$
$dot(n) -> 0$ and population stabilizes. When $n > K,$ $dot(n) < 0$ and
population declines toward $K.$ The analytical solution

$ n(t) = K / (1 + ((K - n_0)/n_0) e^(-r t)) $

converges to $K$ from any positive $n_0.$ Equilibria satisfy $dot(n) = 0,$
giving $n = 0$ and $n = K;$ only $K$ is a stable positive equilibrium.

#example-box[
  With $r = 0.5,$ $K = 1000,$ $n_0 = 50:$ early growth is near-exponential; at
  $n = 500,$ $dot(n) = 125;$ at $n = 900,$ $dot(n) = 45;$ at $n = 990,$
  $dot(n) = 4.95;$ convergence to $1000$ is smooth without oscillation, unlike
  the discrete logistic at high $r.$
]

A crucial distinction from recurrences: $n_(t+1) = n_t$ means the _next value
equals the current value_; $dot(n) = 0$ means the _rate of change is zero_ while
the population remains at its current level. A discrete death term subtracts
individuals at the next step; a continuous death term drives exponential
decline. Always interpret ODE terms as rates per unit time.

#example-box(title: "Decay")[
  With $B = 0.1$ per year and $n_0 = 1000:$ after one year
  $n(1) = 1000 e^(-0.1) approx 904.8;$ after ten years
  $n(10) = 1000 e^(-1) approx 367.9;$ after fifty years $n(50) approx 0.67.$ The
  population never reaches exactly zero in finite time, approaching it
  asymptotically. This half-life behavior is characteristic of exponential decay
  and appears in radioactive decay, drug elimination from the bloodstream, and
  proportional mortality models.
]

For the logistic equation, setting $dot(n) = 0$ gives equilibria at $n = 0$ and
$n = K.$ The equilibrium at $n = 0$ is unstable: any positive perturbation grows
initially. The equilibrium at $n = K$ is stable: perturbations above or below
$K$ decay back toward it. This stability analysis, determining whether small
deviations grow or shrink, extends to systems of multiple equations studied in
the next chapter.

== The Rate Interpretation Trap in Coupled Models

In the discrete two-sex fish model, a term $-delta M_t$ removes a fraction of
males at each step while females and males otherwise follow the same logistic
structure. Both sexes stabilize near carrying capacity with females slightly
outnumbering males.

In the continuous analogue:

$ dot(F) = r F (1 - (F+M)/K) $
$ dot(M) = r F (1 - (F+M)/K) - delta M $

the negative term drives exponential decay of males. Simulation shows males
approaching zero while females persist, unlike the discrete case.

#figure(
  image("../images/chapter3/two-sex-discrete-vs-continuous.pdf", width: 100%),
  caption: [
    Two-sex fish model in discrete and continuous form with $r_F = r_M = 2,$
    $K = 100,$ $delta = 0.1,$ $F_0 = 40,$ and $M_0 = 30.$ Both sexes persist in
    the discrete simulation, whereas males decline toward zero in the continuous
    ODE while females approach $K.$
  ],
) <fig:two-sex-discrete-vs-continuous>

To find equilibria, set $dot(F) = dot(M) = 0.$ From $dot(M) = 0$ with
$delta > 0,$ we need $M = 0$ because the logistic term is identical in both
equations and cannot cancel a positive $delta M$ term otherwise. Substituting
$M = 0$ into $dot(F) = 0$ gives $F = K.$ The discrete model allowed coexistence
because death removed a fixed fraction per step; the continuous model interprets
the same coefficient as a per-unit-time decay rate. This example shows why
translating between formalisms requires rethinking each term's meaning.

This distinction generalizes: when moving from $n_(t+1) = n_t + Delta$ to
$dot(n) = Delta,$ the term $Delta$ changes from an increment to a rate. A
discrete subtraction of $delta M_t$ removes a fraction of males at the next
step. A continuous term $-delta M$ removes males at rate $delta M$ per unit
time, causing exponential decline. To model per-step fractional removal in
continuous time, one would write $dot(M) = ... - delta' M$ where $delta'$ is
calibrated differently, or use a discrete-time model when the biological process
is inherently step-based.

== The Cauchy Problem and Euler's Method

Complex ODEs rarely have closed solutions. We solve the _Cauchy problem_: given
$n(0) = n_0,$ approximate $n(t)$ for $t > 0$ numerically. Solvers discretize
time with step $tau$ and approximate the continuous trajectory with a discrete
recurrence.

_Euler's method:_

$ n_(k+1) = n_k + tau f(n_k) $

The derivative approximates the solution as a straight segment over length
$tau.$ This is the first-order Taylor approximation:
$n(t + tau) approx n(t) + tau dot(n)(t),$ truncating all higher-order terms.

Local discretization error is $O(tau^2):$ starting from a correct point, the
computed value differs from the exact solution by a quantity proportional to
$tau^2.$ Global discretization error after $k$ steps to time $t = k tau$ is
$O(tau):$ roughly $k$ local errors of order $tau^2$ sum to order
$k tau^2 = t tau.$

For $dot(n) = 2n,$ $tau = 0.1,$ $n_0 = 1:$ explicit Euler gives $n_1 = 1.2$
while the exact value is $e^0.2 approx 1.221.$ After ten steps to $t = 1,$ Euler
gives approximately $6.19$ while the exact value is $e^2 approx 7.39.$ Halving
$tau$ to $0.05$ halves the global error but doubles the number of steps.

_Implicit Euler_ uses the derivative at the endpoint:
$n_(k+1) = n_k + tau f(n_(k+1)),$ requiring algebraic solution each step but
often better accuracy for rapidly growing functions because the slope is
evaluated where the segment ends rather than where it begins.

#figure(
  image("../images/chapter3/euler-explicit-implicit.pdf", width: 100%),
  caption: [
    Explicit and implicit Euler approximations for $dot(n) = 2n$ with $n_0 = 1$ and
    $tau = 0.1.$ Gray segments show the first five Euler steps; the exact solution
    is $n(t) = e^(2t).$ Explicit Euler underestimates convex growth; implicit
    Euler uses the slope at the segment endpoint.
  ],
) <fig:euler-explicit-implicit>

Graphically, Euler's method approximates the solution curve with a sequence of
straight-line segments. At each point, the slope is given by the ODE. The
segment follows that slope for distance $tau,$ landing at a new point where the
process repeats. The gap between the segment and the true curve is the local
error. For convex growing functions, explicit Euler underestimates because it
uses the slope at the left endpoint, which is smaller than slopes further along
the curve.

#example-box(title: "Euler steps for logistic growth")[
  For $dot(n) = n(1 - n/100)$ with $n_0 = 10$ and $tau = 0.5:$ at $t = 0,$
  $dot(n) = 10(0.9) = 9,$ so $n_1 = 10 + 0.5(9) = 14.5.$ At $t = 0.5,$
  $dot(n) = 14.5(0.855) approx 12.4,$ so $n_2 = 14.5 + 0.5(12.4) = 20.7.$ The
  exact solution at $t = 1$ is approximately $24.5,$ so Euler with $tau = 0.5$
  underestimates. Reducing $tau$ improves accuracy at the cost of more steps.
]

== Advanced Solvers, Stiffness, and Jacobians

Runge-Kutta methods evaluate derivatives at several intermediate points per step
and average them, achieving global error $O(tau^p)$ with $p = 3$ or $4.$
Multi-step methods also use values from previous steps. Libraries adapt $tau$
dynamically: small steps near sharp transients, large steps near equilibria
where the function changes slowly.

_Stiff_ systems have variables changing at very different rates. An explicit
method must use a step small enough to capture the fastest variable, making
simulation of slow variables wastefully slow or numerically unstable. _Implicit_
methods compute derivatives at future states by solving linear systems each
step. The trade-off is more computation per step against the ability to take
longer steps.

#figure(
  image("../images/chapter3/oregonator-stiff.pdf", width: 100%),
  caption: [
    Oregonator trajectories integrated with a stiff BDF solver $(s = 77.27,$
    $w = 0.161,$ initial state $[1, 1, 2]).$ Sharp oscillations in $B$ and $C$
    require small adaptive steps or implicit methods.
  ],
) <fig:oregonator-stiff>

The _Jacobian_ matrix $J_(i j) = (partial f_i) / (partial x_j)$ contains all partial
derivatives of each equation with respect to each variable. Implicit solvers use
the Jacobian to solve the linear system at each step. Supplying an analytically
computed Jacobian improves accuracy over internal finite-difference
approximations. LSODA and BDF methods in SciPy's `solve_ivp` switch
automatically between explicit and implicit modes when they detect stiffness.

Runge-Kutta methods of order four evaluate the derivative at four points within
each step and combine them with weighted averaging, achieving global error
$O(tau^4).$ This means halving $tau$ reduces error by a factor of sixteen, a
substantial improvement over Euler's $O(tau)$ global error. Modern libraries
also adapt $tau$ during simulation: when the solution changes rapidly, $tau$
shrinks; near equilibria, $tau$ grows. Users specify absolute and relative
tolerances; the solver adjusts discretization to meet them.

Stiffness arises when the system has widely separated time scales. In the
Oregonator, variable $A$ may change on a scale of $1/s$ while variable $C$
changes on a scale of $1/w.$ If $s >> w,$ an explicit method must use steps
small enough to resolve the fast dynamics, even when the slow dynamics would
permit much larger steps. Implicit methods evaluate the derivative at the
endpoint, capturing the curvature of the solution and allowing longer steps
without instability.

== Oregonator and Python Code

#example-box(title: "Oregonator")[
  The Oregonator is a stiff three-variable system modeling oscillatory chemical
  kinetics:

  $ dot(A) = s (B - A) $
  $ dot(B) = (1/s) (C - B - B A) $
  $ dot(C) = w (A - C) $

  Parameters $s$ and $w$ control time scales. Trajectories exhibit sharp peaks
  requiring stiff-capable solvers.

  ```python
  from scipy.integrate import solve_ivp
  import numpy as np

  def oregonator(t, x, s=77.27, w=0.161):
      a, b, c = x
      return [s*(b-a), (c-b-b*a)/s, w*(a-c)]

  sol = solve_ivp(oregonator, (0, 2), [1, 1, 2], method="BDF", dense_output=True)
  t = np.linspace(0, 2, 1000)
  y = sol.sol(t)
  ```

  Octave follows the same pattern with `lsode`. The partial derivative of
  $dot(B)$ with respect to $A$ is $-B/s,$ one entry of the Jacobian. A separate
  function can return the full Jacobian matrix for improved solver performance.
  Non-stiff methods applied to this system fail or halt when local error exceeds
  tolerance. Complex systems may take minutes or hours to simulate.
]

The Octave script defines a function `f` that maps state vector $x = [A, B, C]$
to derivative vector $[dot(A), dot(B), dot(C)],$ sets the time span from $0$ to
$2,$ specifies one thousand output points, sets initial conditions $[1, 1, 2],$
and calls `lsode(f, x0, t)`. The returned trajectory can be plotted to reveal
sharp peaks in $B$ and $C$ that characterize oscillatory chemical kinetics.
LSODA automatically selects stiff or non-stiff methods. Users can tighten
tolerances for higher accuracy at greater computational cost.

SciPy offers both the legacy `odeint` wrapper around LSODE and the modern
`solve_ivp` with methods including RK45, BDF, and Radau. For stiff systems,
`method="BDF"` or `method="Radau"` is appropriate. The `dense_output=True`
option constructs an interpolant over the solution, allowing evaluation at
arbitrary time points without re-running the solver. JIT-compilation libraries
such as JAX can accelerate repeated simulations for parameter sweeps.

== Connecting Discrete and Continuous Modeling

Numerical integration _is_ discrete approximation of continuous dynamics. Every
ODE solver implements a recurrence internally, even when the user works only
with continuous equations. Understanding discretization error, adaptive step
size, and the rate-versus-next-value distinction is essential for interpreting
simulation output.

Combined growth and decay $dot(n) = (R_c - B) n$ mirrors discrete net rate
$alpha = R_d - S,$ but continuous and discrete death terms are not
interchangeable by setting $S = B.$ The next chapter applies ODEs to classical
Lotka-Volterra and SIR models where nonlinear product terms encode interaction
between populations, producing sustained oscillations and epidemic peaks that no
linear model can capture.

Every numerical integrator is a recurrence relation in disguise. Euler's method
is literally $n_(k+1) = n_k + tau f(n_k).$ Runge-Kutta methods are more
elaborate recurrences using multiple evaluations of $f$ per step. When we
simulate an ODE, we are running a discrete dynamical system whose step size is
chosen adaptively to control error. Understanding recurrences therefore remains
essential even when the primary model is continuous.

The Cauchy problem fixes an initial condition $n(0) = n_0$ and seeks the
solution forward in time. Most applications in population dynamics and
epidemiology require forward integration only. Some problems, such as finding
periodic orbits, require solving boundary-value problems with conditions at both
endpoints. Standard libraries focus on initial-value problems; boundary-value
problems require specialized methods beyond this chapter's scope.

== Summary and Comparison with Discrete Models

Ordinary differential equations describe continuous-time dynamics through rates
of change. We derived them from recurrence relations by taking $Delta t -> 0,$
obtaining $dot(n) = R_c n$ from $n_(t+1) = R_d n_t.$ The continuous rate
$R_c = lambda/sigma$ differs from the discrete rate
$R_d = 1 + lambda (Delta t) / sigma,$ and solutions $n(t) = n_0 e^(R_c t)$ differ
from $n_t = R_d^t n_0,$ though both exhibit exponential growth.

Equilibrium in ODEs requires $dot(n) = 0,$ not $n(t+1) = n(t).$ This distinction
matters when translating models between formalisms. Logistic growth
$dot(n) = r n (1 - n/K)$ converges smoothly to $K;$ the discrete logistic can
oscillate or chaos at high $r.$ Exponential decay $dot(n) = -B n$ never reaches
zero in finite time; discrete proportional death reaches zero asymptotically in
steps.

Numerical integration solves ODEs by discretizing time. Euler's method is a
first-order recurrence with local error $O(tau^2)$ and global error $O(tau).$
Higher-order Runge-Kutta methods and adaptive step-size control improve
accuracy. Stiff systems require implicit methods that solve linear systems at
each step using the Jacobian matrix. The Oregonator example demonstrates
implementation in Python and Octave with stiff-capable solvers.

#example-box(title: "Comparing discrete and continuous growth")[
  With $lambda = 1,$ $sigma = 1$ year, $Delta t = 1$ year: discrete $R_d = 2,$
  so $n_5 = 32 n_0$ after five years. Continuous $R_c = 1,$ so
  $n(5) = n_0 e^5 approx 148.4 n_0.$ The continuous model grows faster because
  it compounds every instant rather than once per year. Aligning parameters and
  time scales is essential when comparing discrete and continuous predictions.
]

The next chapter applies ODEs to Lotka-Volterra prey-predator dynamics and SIR
epidemic models, where nonlinear product terms encode interactions and produce
oscillations and epidemic peaks. Chemical reaction networks, introduced
afterward, provide an alternative modeling language that translates to the same
ODEs while remaining more readable for complex interaction networks.
