#!/usr/bin/env python3
"""Generate figures for Chapter 4 (classical compartmental models)."""

import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp

from figure_common import BLACK, DARK, LIGHT, MID, apply_style, save

CHAPTER = 4


def lotka_volterra_rhs(_t: float, y: np.ndarray, r: float, s: float, a: float, b: float) -> list[float]:
    v, p = y
    ab = a * b
    return [r * v - ab * v * p, -s * p + ab * v * p]


def plot_lotka_volterra_phase_portrait() -> None:
    r = s = 10.0
    a = 0.01
    b = 1.0
    v_eq = s / (a * b)
    p_eq = r / (a * b)

    t_span = (0.0, 8.0)
    sol = solve_ivp(
        lotka_volterra_rhs,
        t_span,
        [900.0, 900.0],
        args=(r, s, a, b),
        dense_output=True,
        max_step=0.05,
    )
    t = np.linspace(0.0, t_span[1], 800)
    v_orbit, p_orbit = sol.sol(t)

    v_max = max(v_orbit.max(), v_eq) * 1.15
    p_max = max(p_orbit.max(), p_eq) * 1.15

    fig, ax = plt.subplots(figsize=(4.8, 4.2))
    ax.axhline(p_eq, color=LIGHT, linewidth=1.2, linestyle="--", label=r"$\dot{V}=0$")
    ax.axvline(v_eq, color=MID, linewidth=1.2, linestyle="--", label=r"$\dot{P}=0$")
    ax.plot(v_orbit, p_orbit, color=BLACK, linewidth=1.4, label="trajectory from $(900,900)$")
    ax.plot(v_eq, p_eq, "o", color=DARK, markersize=7, zorder=5, label=r"equilibrium $(1000,1000)$")
    ax.plot(900.0, 900.0, "o", color=MID, markersize=5, zorder=5)

    ax.set_xlim(0, v_max)
    ax.set_ylim(0, p_max)
    ax.set_xlabel(r"prey $V$")
    ax.set_ylabel(r"predator $P$")
    ax.set_title(r"Lotka--Volterra phase portrait ($r=s=10$, $a=0.01$, $b=1$)")
    ax.legend(frameon=False, fontsize=8, loc="lower left")
    fig.tight_layout()
    save(fig, CHAPTER, "lotka-volterra-phase-portrait.pdf")


def plot_sir_time_series() -> None:
    beta = 3.0
    gamma = 1.0
    s0, i0 = 0.99, 0.01
    r0 = 1.0 - s0 - i0

    def sir_rhs(_t: float, y: np.ndarray) -> list[float]:
        s, i, r = y
        inf = beta * s * i
        return [-inf, inf - gamma * i, gamma * i]

    sol = solve_ivp(sir_rhs, (0.0, 15.0), [s0, i0, r0], max_step=0.05, dense_output=True)
    t = np.linspace(0.0, 15.0, 400)
    s, i, r = sol.sol(t)

    fig, ax = plt.subplots(figsize=(5.2, 3.2))
    ax.plot(t, s, color=BLACK, label=r"$S(t)$")
    ax.plot(t, i, color=MID, linestyle="--", label=r"$I(t)$")
    ax.plot(t, r, color=LIGHT, linestyle=":", label=r"$R(t)$")
    ax.set_xlabel(r"$t$")
    ax.set_ylabel(r"fraction")
    ax.set_title(r"SIR epidemic ($S_0=0.99$, $I_0=0.01$, $\beta=3$, $\gamma=1$)")
    ax.set_ylim(0, 1.02)
    ax.legend(frameon=False)
    fig.tight_layout()
    save(fig, CHAPTER, "sir-time-series.pdf")


def endemic_infected(p: float, beta: float, gamma: float, mu: float) -> float:
    """Endemic infected fraction at equilibrium with vaccination fraction p."""
    if p >= 1.0 - (gamma + mu) / beta:
        return 0.0
    # beta * S = gamma + mu at endemic equilibrium; S = (1-p)*mu / (mu + beta*I)
    # and I = 1 - S - R with R steady from births: mu*I = gamma*I + ... 
    # Standard result: I* = mu*(1-p) / beta - (gamma+mu)/beta * (1-p) ... 
    # Use numerical root on dot(I)=0 with demography:
    # dot(S) = (1-p)*mu - beta*S*I - mu*S = 0 => S = (1-p)/(beta*I + mu) * mu ... 
    # Simpler: solve beta*S*I = gamma*I => at endemic beta*S = gamma when mu small
    # With births/deaths: endemic I satisfies:
    # I* = 1 - (gamma+mu)/beta - p/(1-p) * ... 
    # Use steady state: (1-p)*mu = beta*S*I + mu*S, gamma*I = beta*S*I (at I>0)
    # => S = gamma/beta, then (1-p)*mu = beta*(gamma/beta)*I + mu*(gamma/beta)
    # => (1-p)*mu = gamma*I + mu*gamma/beta
    # => I = ((1-p)*mu - mu*gamma/beta) / gamma = mu/beta * ((1-p)*beta - gamma) / ... 
    # Actually: from dot(I)=0: beta*S = gamma+mu, S = (gamma+mu)/beta
    # From dot(S)=0: (1-p)*mu = beta*S*I + mu*S = S*(beta*I + mu)
    # I = ((1-p)*mu/S - mu) / beta = ((1-p)*mu * beta/(gamma+mu) - mu) / beta
    s_star = (gamma + mu) / beta
    if s_star >= 1.0:
        return 0.0
    i_star = ((1.0 - p) * mu / s_star - mu) / beta
    return max(0.0, i_star)


def plot_vaccination_endemic() -> None:
    mu = 0.01
    gamma = 0.5
    beta = 2.0
    threshold = 1.0 - (gamma + mu) / beta

    p_vals = np.linspace(0.0, 1.0, 300)
    i_vals = np.array([endemic_infected(p, beta, gamma, mu) for p in p_vals])

    fig, ax = plt.subplots(figsize=(5.2, 3.2))
    ax.plot(p_vals, i_vals, color=BLACK, linewidth=1.6)
    ax.axvline(threshold, color=MID, linewidth=1.2, linestyle="--", label=rf"eradication threshold $p={threshold:.3f}$")
    ax.set_xlabel(r"vaccination fraction $p$")
    ax.set_ylabel(r"endemic infected fraction $I$")
    ax.set_title(rf"Endemic disease ($\mu={mu}$, $\gamma={gamma}$, $\beta={beta}$)")
    ax.set_xlim(0, 1)
    ax.set_ylim(0, max(i_vals.max() * 1.1, 0.05))
    ax.legend(frameon=False)
    fig.tight_layout()
    save(fig, CHAPTER, "vaccination-endemic.pdf")


def plot_sir_phase_plane() -> None:
    beta = 3.0
    gamma = 1.0
    s0, i0 = 0.99, 0.01

    def sir_si_rhs(_t: float, y: np.ndarray) -> list[float]:
        s, i = y
        inf = beta * s * i
        return [-inf, inf - gamma * i]

    sol = solve_ivp(sir_si_rhs, (0.0, 15.0), [s0, i0], max_step=0.05, dense_output=True)
    t = np.linspace(0.0, 15.0, 400)
    s_traj, i_traj = sol.sol(t)

    s_null = gamma / beta
    fig, ax = plt.subplots(figsize=(4.8, 4.0))
    ax.axhline(0.0, color=LIGHT, linewidth=1.0, linestyle="--")
    ax.axvline(s_null, color=MID, linewidth=1.2, linestyle="--", label=r"$\dot{I}=0$: $S=\gamma/\beta$")
    ax.plot([0, 1], [1, 0], color=LIGHT, linewidth=1.2, linestyle=":", label=r"$\dot{S}=0$: $I=0$ or $S=0$")
    ax.plot(s_traj, i_traj, color=BLACK, linewidth=1.4, label="epidemic trajectory")
    ax.plot(s0, i0, "o", color=MID, markersize=5)
    peak_idx = np.argmax(i_traj)
    ax.plot(s_traj[peak_idx], i_traj[peak_idx], "o", color=DARK, markersize=6, label="epidemic peak")

    ax.set_xlim(0, 1.02)
    ax.set_ylim(0, max(i_traj.max() * 1.2, 0.12))
    ax.set_xlabel(r"$S$")
    ax.set_ylabel(r"$I$")
    ax.set_title(r"$S$-$I$ phase plane ($\beta=3$, $\gamma=1$)")
    ax.legend(frameon=False, fontsize=8, loc="upper right")
    fig.tight_layout()
    save(fig, CHAPTER, "sir-phase-plane.pdf")


def main() -> None:
    apply_style()
    plot_lotka_volterra_phase_portrait()
    plot_sir_time_series()
    plot_vaccination_endemic()
    plot_sir_phase_plane()


if __name__ == "__main__":
    main()
