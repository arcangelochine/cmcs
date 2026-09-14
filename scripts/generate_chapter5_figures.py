#!/usr/bin/env python3
"""Generate figures for Chapter 5 (chemical reactions and stochastic simulation)."""

import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp

from figure_common import (
    BLACK,
    DARK,
    LIGHT,
    MID,
    apply_style,
    draw_arrow,
    draw_box_state,
    new_diagram_figure,
    save,
)

CHAPTER = 5


def reversible_abc_rhs(_t: float, y: np.ndarray, kf: float, kr: float) -> list[float]:
    a, b, c = y
    forward = kf * a * b
    backward = kr * c
    return [-forward + backward, -forward + backward, forward - backward]


def plot_reversible_equilibrium() -> None:
    kf = 1.0
    kr = 0.2
    y0 = [10.0, 15.0, 2.0]

    sol = solve_ivp(
        reversible_abc_rhs,
        (0.0, 25.0),
        y0,
        args=(kf, kr),
        max_step=0.1,
        dense_output=True,
    )
    t = np.linspace(0.0, 25.0, 400)
    a, b, c = sol.sol(t)

    fig, ax = plt.subplots(figsize=(5.2, 3.2))
    ax.plot(t, a, color=BLACK, label=r"$[A](t)$")
    ax.plot(t, b, color=MID, linestyle="--", label=r"$[B](t)$")
    ax.plot(t, c, color=LIGHT, linestyle=":", label=r"$[C](t)$")
    ax.set_xlabel(r"$t$")
    ax.set_ylabel(r"concentration")
    ax.set_title(r"$A + B \rightleftharpoons C$ from $(10,15,2)$, $k_f=1$, $k_r=0.2$")
    ax.legend(frameon=False)
    fig.tight_layout()
    save(fig, CHAPTER, "reversible-equilibrium.pdf")


def _draw_enzyme_panel(ax, title: str) -> None:
    species_box = (0.72, 0.40)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title(title, fontsize=9, pad=6)

    if title.startswith("Binding"):
        enzyme = (1.0, 1.4)
        substrate = (2.8, 1.4)
        complex_state = (6.2, 1.4)
        for pos, label in [(enzyme, r"$E$"), (substrate, r"$S$"), (complex_state, r"$ES$")]:
            draw_box_state(ax, pos, label, width=species_box[0], height=species_box[1], fontsize=11)
        ax.text(1.9, 1.4, r"$+$", ha="center", va="center", fontsize=13, color=DARK, zorder=4)
        draw_arrow(
            ax,
            enzyme,
            complex_state,
            start_box=species_box,
            end_box=species_box,
            curvature=0.12,
            linewidth=1.2,
        )
        draw_arrow(
            ax,
            substrate,
            complex_state,
            start_box=species_box,
            end_box=species_box,
            curvature=-0.12,
            linewidth=1.2,
        )
        draw_arrow(
            ax,
            complex_state,
            substrate,
            start_box=species_box,
            end_box=species_box,
            curvature=-0.5,
            linewidth=1.0,
            color=MID,
        )
        ax.text(4.5, 1.72, r"$k_f$", ha="center", va="center", fontsize=10, color=DARK, zorder=4)
        ax.text(4.5, 0.95, r"$k_r$", ha="center", va="center", fontsize=10, color=MID, zorder=4)
        ax.set_xlim(-0.2, 7.2)
        ax.set_ylim(0.55, 2.25)
        return

    complex_state = (1.2, 1.4)
    enzyme = (4.2, 2.15)
    product = (4.2, 0.65)
    draw_box_state(ax, complex_state, r"$ES$", width=species_box[0], height=species_box[1], fontsize=11)
    draw_box_state(ax, enzyme, r"$E$", width=species_box[0], height=species_box[1], fontsize=11)
    draw_box_state(ax, product, r"$P$", width=species_box[0], height=species_box[1], fontsize=11)
    draw_arrow(
        ax,
        complex_state,
        enzyme,
        start_box=species_box,
        end_box=species_box,
        curvature=0.18,
        linewidth=1.2,
    )
    draw_arrow(
        ax,
        complex_state,
        product,
        start_box=species_box,
        end_box=species_box,
        curvature=-0.18,
        linewidth=1.2,
    )
    ax.text(2.55, 1.4, r"$k_c$", ha="center", va="center", fontsize=10, color=DARK, zorder=4)
    ax.text(5.35, 1.4, r"$+$", ha="center", va="center", fontsize=13, color=DARK, zorder=4)
    ax.set_xlim(-0.2, 6.0)
    ax.set_ylim(0.2, 2.55)


def plot_enzyme_network() -> None:
    """Two-step enzymatic network: E + S ⇌ ES, then ES → E + P."""
    fig, axes = plt.subplots(1, 2, figsize=(8.2, 2.6))
    _draw_enzyme_panel(axes[0], r"Binding: $E + S \rightleftharpoons ES$")
    _draw_enzyme_panel(axes[1], r"Catalysis: $ES \to E + P$")
    fig.suptitle("Enzymatic reaction network", fontsize=11, y=1.02)
    fig.tight_layout()
    save(fig, CHAPTER, "enzyme-network.pdf")


def gillespie_a_to_b(
    c: float,
    a0: int,
    t_end: float,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    """SSA for A -> B with propensity c * A."""
    t = 0.0
    a_count = a0
    times = [0.0]
    counts = [a_count]

    while t < t_end and a_count > 0:
        propensity = c * a_count
        tau = -np.log(rng.random()) / propensity
        t += tau
        if t > t_end:
            break
        a_count -= 1
        times.append(t)
        counts.append(a_count)

    return np.array(times), np.array(counts)


def plot_ode_vs_ssa() -> None:
    c = 0.5
    a0 = 20
    t_end = 10.0
    rng = np.random.default_rng(7)

    def ode_rhs(_t: float, y: np.ndarray) -> list[float]:
        return [-c * y[0]]

    sol = solve_ivp(ode_rhs, (0.0, t_end), [float(a0)], max_step=0.05, dense_output=True)
    t_ode = np.linspace(0.0, t_end, 300)
    a_ode = sol.sol(t_ode)[0]

    fig, ax = plt.subplots(figsize=(5.4, 3.2))
    ax.plot(t_ode, a_ode, color=BLACK, linewidth=1.8, label="ODE mean")

    for seed in (1, 2, 3, 4):
        times, counts = gillespie_a_to_b(c, a0, t_end, np.random.default_rng(seed))
        ax.step(
            times,
            counts,
            where="post",
            color=MID,
            linewidth=1.0,
            alpha=0.85,
            label="SSA path" if seed == 1 else None,
        )

    ax.set_xlabel(r"$t$")
    ax.set_ylabel(r"$A$ count")
    ax.set_title(r"$A \to B$ at low counts ($c=0.5$, $A_0=20$)")
    ax.legend(frameon=False)
    fig.tight_layout()
    save(fig, CHAPTER, "ode-vs-ssa.pdf")


def plot_gillespie_staircase() -> None:
    """Staircase SSA trajectory for the worked example in the chapter."""
    c1, c2 = 2.0, 0.1
    state = np.array([10, 5, 20], dtype=int)
    t = 0.0
    t_end = 1.0
    rng = np.random.default_rng(42)

    times = [0.0]
    a_series = [state[0]]
    b_series = [state[1]]
    c_series = [state[2]]

    while t < t_end:
        a1 = c1 * state[0]
        a2 = c2 * state[1] * state[2]
        a0 = a1 + a2
        if a0 <= 0:
            break
        tau = -np.log(rng.random()) / a0
        t += tau
        if t > t_end:
            break
        u = rng.random() * a0
        if u < a1:
            state[0] -= 1
            state[1] += 1
            state[2] += 1
        else:
            state[0] += 1
            state[1] -= 1
            state[2] -= 1
        times.append(t)
        a_series.append(state[0])
        b_series.append(state[1])
        c_series.append(state[2])

    fig, ax = plt.subplots(figsize=(5.4, 3.2))
    ax.step(times, a_series, where="post", color=BLACK, linewidth=1.4, label=r"$A$")
    ax.step(times, b_series, where="post", color=MID, linewidth=1.2, linestyle="--", label=r"$B$")
    ax.step(times, c_series, where="post", color=LIGHT, linewidth=1.2, linestyle=":", label=r"$C$")
    ax.set_xlabel(r"$t$")
    ax.set_ylabel(r"count")
    ax.set_title(r"Gillespie SSA staircase ($A \rightleftharpoons B + C$)")
    ax.legend(frameon=False)
    fig.tight_layout()
    save(fig, CHAPTER, "gillespie-staircase.pdf")


def main() -> None:
    apply_style()
    plot_reversible_equilibrium()
    plot_enzyme_network()
    plot_ode_vs_ssa()
    plot_gillespie_staircase()


if __name__ == "__main__":
    main()
