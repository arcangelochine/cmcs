#import "@preview/bookly:5.1.0": *
#import "../lib.typ": example-box

#show: chapter.with(
  title: "Classical Models: Lotka-Volterra and SIR",
  abstract: [
    This chapter presents two foundational ODE models of complex systems: the
    Lotka-Volterra prey-predator equations and the SIR epidemic compartmental
    model. Both illustrate minimal hypothesis-driven modeling, nonlinear
    interaction terms, equilibrium analysis, sustained oscillations, and
    policy-relevant extensions such as vaccination.
  ],
  toc: true,
)

== Minimal Models and Hypothesis Validation

Classical ODE models rarely reproduce every detail of reality. They validate
_hypotheses_ with minimal ingredients. The guiding principle is _smaller is
better_: if qualitative behavior persists when mechanisms are removed, those
mechanisms were not essential. Qualitative agreement with observation makes
included mechanisms plausible, not proof, but valuable scientific reasoning.

We write $x$ for current values, $dot(x)$ for derivatives, and $x_0$ for initial
conditions. Throughout this chapter, time dependence is understood from context.

Alfred Lotka sought a minimal model producing _oscillations_ in chemical
concentrations. Vito Volterra studied Adriatic fish after World War I, when
fishing had been severely reduced and some species rebounded rapidly while
predators remained scarce for years. He hypothesized that reduced predator
pressure let prey explode before predators could recover. His two-equation
model captures this intuition without modeling ocean currents, fish age, or
spatial distribution---yet it still tests whether predation alone explains the
observed asymmetry.

The SIR model, developed by Kermack and McKendrick in the early twentieth
century, partitions a population into susceptibles, infected, and recovered
individuals. Two events---infection and recovery---suffice to produce epidemic
peaks, threshold behavior, and vaccination thresholds that inform public health
policy. Its compartmental structure became the template for hundreds of
extensions.

A spatially distributed model with age structure might fit data better but
would require dozens of unmeasurable parameters. A four-parameter Lotka-Volterra
system or a three-equation SIR model can still answer whether a proposed
mechanism is _necessary_ for the observed qualitative behavior. Removing an
ingredient and checking whether the pattern survives is sensitivity analysis
central to hypothesis validation.

== Lotka-Volterra: Structure and Equilibria

Variables $V$ (prey density) and $P$ (predator density) evolve as:

$ dot(V) = r V - a b V P $
$ dot(P) = -s P + a b V P $

In isolation, prey grow exponentially $(dot(V) = r V)$ and predators decay
$(dot(P) = -s P)$ because predators need prey as food. Together, encounter rate
is proportional to $V P:$ the more prey and predators present, the more meetings
occur. Fraction $a$ of encounters result in successful hunts; each hunt yields
$b$ predator offspring, bundled into the single interaction term $a b V P.$
Predation removes prey and adds predators. The product $V P$ makes the system
_nonlinear_, the hallmark of encounter-driven dynamics in ODE models.

Steady states satisfy $dot(V) = dot(P) = 0.$ The trivial equilibrium is
$(0, 0),$ where both populations are extinct. The nontrivial equilibrium is
found by setting $dot(P) = 0$ with $P > 0,$ which gives $V = s/(a b);$
substituting into $dot(V) = 0$ yields $P = r/(a b).$

#example-box(title: "Equilibrium and oscillations")[
  With $r = s = 10,$ $a = 0.01,$ $b = 1:$ equilibrium
  $(V^*, P^*) = (1000, 1000).$ Verify:
  $dot(V) = 10(1000) - 0.01 times 1 times 1000 times 1000 = 0;$
  $dot(P) = -10(1000) + 0.01 times 1 times 1000 times 1000 = 0.$

  Away from equilibrium, _sustained oscillations_ occur. From $(900, 900),$ prey
  initially rise $(dot(V) > 0)$ while predators decline $(dot(P) < 0);$ predators
  eventually follow as food becomes abundant; prey crash under predation; predators
  decline from starvation; prey recover, and the cycle repeats. Trajectories orbit
  indefinitely around $(1000, 1000).$ From $(200, 200),$ prey may spike above
  $3000$ while predators lag near $500,$ qualitatively matching Volterra's
  post-war observations.
]

_Phase-plane view._ Plotting $P$ against $V$ reveals the geometry of these
oscillations. _Nullclines_ are curves where one derivative vanishes: $dot(V) = 0$
gives the vertical line $P = r/(a b),$ and $dot(P) = 0$ gives the horizontal
line $V = s/(a b).$ They intersect at the equilibrium. Between nullclines, the
signs of $dot(V)$ and $dot(P)$ determine whether trajectories move up, down,
left, or right. In the classical model the nontrivial equilibrium is a _center_:
orbits neither converge nor diverge, so oscillation amplitude is fixed by initial
conditions.

#figure(
  image("../images/chapter4/lotka-volterra-phase-portrait.pdf", width: 70%),
  caption: [
    Lotka-Volterra phase portrait with nullclines, equilibrium
    $(V^*, P^*) = (1000, 1000),$ and a closed orbit from $(900, 900)$ for
    $r = s = 10,$ $a = 0.01,$ $b = 1.$
  ],
) <fig:lotka-volterra-phase>

Deterministic oscillations are perfectly regular; predators approach zero but
never reach extinction. Stochastic extinction of small predator populations
during a trough is invisible to ODEs---a limitation motivating later stochastic
models.

== Lotka-Volterra Applications and Extensions

The model applies wherever one population consumes another: ecology, market
competition where firms play metaphorical prey and predator roles, and
rock-paper-scissors three-species cycles where A eats B, B eats C, and C eats A.
Simulations often show the least aggressive species persisting longest. Varying
encounter rate $a$ changes oscillation amplitude; varying $r$ and $s$ shifts the
equilibrium without removing oscillations.

An extension adds vegetation $G$ as a third variable: prey consume vegetation,
predators consume prey, vegetation regrows logistically. This three-variable
system can exhibit richer dynamics including additional equilibria. Chemical
reaction networks underlying the Lotka-Volterra equations will be derived in
Chapter 5, showing how mass-action kinetics produces the same ODE structure from
a rule-based description of molecular interactions.

== The SIR Epidemic Model

The _SIR model_ partitions a population into _Susceptible_ $S,$ _Infected_ $I,$
and _Recovered_ $R$ fractions with $S + I + R = 1.$ Assumptions: horizontal
transmission through random contacts, no births or deaths initially, permanent
immunity after recovery.

$ dot(S) = -beta S I $
$ dot(I) = beta S I - gamma I $
$ dot(R) = gamma I $

Parameter $beta$ is the infection rate; $gamma$ is the recovery rate; mean
infectious period is $1/gamma.$ Infection terms cancel between $S$ and $I;$
recovery terms cancel between $I$ and $R;$ total population stays normalized at
one. Since $S + I + R = 1,$ one variable can be eliminated and many papers
present only $dot(S)$ and $dot(I).$

_Qualitative analysis without simulation._ $S$ decreases monotonically because
infection removes susceptibles. $R$ increases monotonically because recovery
adds to the recovered class. For $I,$ $dot(I) = I(beta S - gamma).$ When
$beta S > gamma,$ infections grow; when $beta S < gamma,$ they shrink. Since $S$
falls over time, an outbreak that starts with $beta S_0 > gamma$ eventually
crosses threshold $S = gamma/beta$ and $I$ declines, producing the classic
epidemic peak.

#example-box(title: "Outbreak threshold")[
  With $S_0 = 0.99,$ $I_0 = 0.01,$ $gamma = 1:$

  + $beta = 3:$ since $beta S_0 = 2.97 > gamma,$ the epidemic spreads, $I$ peaks
    near ten percent when $S$ crosses $gamma/beta = 1/3,$ and roughly ninety-five
    percent eventually recover.
  + $beta = 0.5:$ $beta S_0 = 0.495 < gamma$ and infection dies out from the
    initial one percent without a significant outbreak.

  This threshold reasoning requires no simulation, only inspection of the sign of
  $dot(I).$
]

#figure(
  image("../images/chapter4/sir-time-series.pdf", width: 70%),
  caption: [
    SIR epidemic curves for $S_0 = 0.99,$ $I_0 = 0.01,$ $beta = 3,$ $gamma = 1:$
    infection peaks near ten percent while most of the population eventually
    recovers.
  ],
) <fig:sir-time-series>

The $S$-$I$ phase plane makes the same logic geometrically visible: the
nullcline $dot(I) = 0$ is the vertical line $S = gamma/beta,$ and trajectories
move through the feasible triangle $S, I, R >= 0$ with $S + I + R = 1$ until
infection dies out.

#figure(
  image("../images/chapter4/sir-phase-plane.pdf", width: 70%),
  caption: [
    $S$-$I$ phase plane for the toy SIR model: nullclines and epidemic
    trajectory showing the peak of $I$ when $S$ crosses $gamma/beta.$
  ],
) <fig:sir-phase-plane>

_Influenza-scale parameters._ Days as time unit: $gamma = 0.125$ (eight-day
recovery), $beta = 0.02$ (twenty percent of contacts infect). Over 120 days from
one percent infected: peak near month two with roughly ten percent ill
simultaneously, roughly sixty-five percent eventually recovered. These numbers
are illustrative, not formally calibrated, but the qualitative shape matches
familiar epidemic curves.

The model assumes random mixing: every susceptible has equal probability of
contacting every infected individual. Real populations have spatial structure,
household clusters, and heterogeneous contact rates. The basic SIR structure
nonetheless captures the essential logic of epidemic growth, peak, and decline
that informed public health reasoning during the COVID-19 pandemic, where
lockdowns temporarily reduced $beta$ and vaccination reduced the susceptible
fraction $S.$

== Endemic Disease, Vaccination, and Policy

Long-horizon diseases require births and deaths at equal rate $mu,$ keeping
total population constant. Births add new susceptibles; deaths remove
individuals from all compartments proportionally. The extended equations add
birth term $mu$ to $dot(S)$ and death terms $-mu S,$ $-mu I,$ $-mu R$ to each
equation. Since $S + I + R = 1,$ the death terms sum to $-mu,$ canceling the
birth term and preserving normalization.

With $beta > gamma + mu,$ new susceptibles sustain _endemic_ infection: $I$
stabilizes at a positive level because births continuously replenish the pool of
individuals who can be infected. At endemic equilibrium with $I > 0,$ setting
$dot(I) = 0$ gives $beta S = gamma + mu,$ determining the susceptible fraction
needed to sustain transmission.

Vaccination sends fraction $p$ of newborns directly to $R,$ fraction $1-p$ to
$S.$ The birth term in $dot(S)$ becomes $(1-p) mu$ and a term $p mu$ appears in
$dot(R).$ Low $p$ reduces but does not eliminate endemic levels. Above a
critical threshold, disease is eradicated because too few susceptibles enter the
population to sustain transmission:

$ p > 1 - (gamma + mu) / beta $

#example-box(title: "Vaccination threshold")[
  With $mu = 0.01,$ $gamma = 0.5,$ $beta = 2:$ the eradication threshold is
  $p > 1 - (0.5 + 0.01)/2 = 0.745.$ At $p = 0.25$ or $p = 0.50,$ endemic
  infection persists. At $p = 0.80,$ above threshold, $I$ approaches zero over
  several years.

  _Measles parameters_ $(mu approx 0.01,$ $gamma approx 0.1,$ $beta approx 2)$
  yield threshold $p > 0.945.$ Mandatory vaccination of approximately ninety-five
  percent of newborns is needed for measles eradication---a high bar that
  supports aggressive vaccination policy despite modeling approximations.
]

#figure(
  image("../images/chapter4/vaccination-endemic.pdf", width: 70%),
  caption: [
    Endemic infected fraction versus vaccination rate $p$ for $mu = 0.01,$
    $gamma = 0.5,$ $beta = 2,$ with the eradication threshold
    $p > 1 - (gamma + mu)/beta$ marked.
  ],
) <fig:vaccination-endemic>

Lockdown during COVID-19 can be modeled by temporarily halving $beta;$ ending
restrictions with many susceptibles remaining risks a second wave. Hundreds of
SIR variants add exposed compartments (SEIR), reinfection (SIRS), spatial
structure, and time-varying contact rates.

== Applications, Limitations, and Outlook

Information spreads like disease: susceptibles encounter content and become
aware; recovery is forgetting or loss of interest. Urban mobility uses
compartments for zones connected by commuting flows. The bilinear terms $V P$
and $S I$ encode that both interacting populations must be present---one of the
most reused patterns in complex systems modeling.

Shared limitations of these ODE models matter for what comes next. Determinism
yields a single trajectory and misses random extinction when predator
populations trough near zero. Continuous variables allow fractional individuals
$(0.3$ infected$)$, which is meaningless when the actual count is zero or one.
Readability decays as equation systems grow.

Lotka-Volterra and SIR exemplify the knowledge-driven methodology: write minimal
mechanisms, analyze equilibria and phase planes, simulate when necessary,
interpret results as hypothesis support rather than exact forecast. Chemical
reaction networks, introduced in Chapter 5, offer a more modeler-friendly
language translatable to ODEs or stochastic simulation. Gillespie's algorithm and
probabilistic model checking will ask questions ODEs cannot: What is the
probability of predator extinction during a trough? What fraction of runs reaches
herd immunity? Formal behavioral models in Part II address complementary
verification questions on transition systems and Markov chains.
