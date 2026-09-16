#!/usr/bin/env python3
"""Generate figures for Chapter 8 (model checking with PRISM)."""

import numpy as np

from figure_common import (
    BLACK,
    DARK,
    GREEN,
    LIGHT,
    MID,
    RED,
    YELLOW,
    YELLOW_EDGE,
    apply_style,
    chapter_out_dir,
    draw_arrow,
    draw_box_state,
    draw_edge_label,
    draw_state,
    new_diagram_figure,
    save_figure,
)

import matplotlib.pyplot as plt

OUT = chapter_out_dir(8)


def plot_ctl_example_graph() -> None:
    fig, ax = new_diagram_figure(7.2, 3.6)

    positions = {
        "s0": (-2.0, 0.0),
        "s1": (0.0, 0.8),
        "s2": (2.0, 0.8),
        "s3": (0.0, -0.8),
        "s4": (2.0, -0.8),
    }
    colors = {
        "s0": YELLOW,
        "s1": YELLOW,
        "s2": RED,
        "s3": YELLOW,
        "s4": RED,
    }

    for name, pos in positions.items():
        draw_state(
            ax,
            pos,
            name,
            facecolor=colors[name],
            edgecolor=YELLOW_EDGE if "yellow" in str(colors[name]) else RED,
        )

    edges = [("s0", "s1"), ("s0", "s3"), ("s1", "s2"), ("s1", "s4"), ("s3", "s4")]
    for start, end in edges:
        draw_arrow(
            ax,
            positions[start],
            positions[end],
            start_radius=0.28,
            end_radius=0.28,
        )

    ax.text(
        -2.0,
        -1.55,
        r"`E F red`" + "\n" + r"`E (yellow U red)`",
        ha="center",
        va="center",
        fontsize=8,
        color=DARK,
    )
    ax.text(
        2.0,
        -1.55,
        r"`A F red`" + "\n" + r"`A G yellow` false",
        ha="center",
        va="center",
        fontsize=8,
        color=DARK,
    )

    ax.set_xlim(-2.8, 2.8)
    ax.set_ylim(-1.9, 1.5)
    ax.set_title("CTL formulas on a small state graph", fontsize=10, pad=8)
    save_figure(fig, OUT, "ctl-example-graph.pdf")


def plot_prism_coffee_machine() -> None:
    fig, ax = new_diagram_figure(9.0, 4.8)

    modules = {
        "machine": (-2.8, 1.6, "Coffee\nmachine"),
        "user1": (-0.2, 2.4, "User 1"),
        "user2": (2.4, 2.4, "User 2"),
        "coord": (0.0, 0.2, "Coordinator\n(turn)"),
    }
    for _, (x, y, label) in modules.items():
        draw_box_state(ax, (x, y), label, width=1.2, height=0.55, facecolor="#f7f7f7")

    module_box = (1.2, 0.55)
    draw_arrow(
        ax,
        (-2.8, 1.6),
        (0.0, 0.2),
        curvature=0.15,
        start_box=module_box,
        end_box=module_box,
    )
    draw_arrow(
        ax,
        (-0.2, 2.4),
        (0.0, 0.2),
        curvature=0.1,
        start_box=module_box,
        end_box=module_box,
    )
    draw_arrow(
        ax,
        (2.4, 2.4),
        (0.0, 0.2),
        curvature=-0.1,
        start_box=module_box,
        end_box=module_box,
    )
    ax.text(0.0, 1.15, "global sync\ncoin / button", ha="center", va="center", fontsize=8, color=MID)

    draw_box_state(
        ax,
        (-2.4, -1.2),
        "deadlock\n(credit2, is1, is1)",
        width=1.5,
        height=0.55,
        facecolor="#fdecea",
        edgecolor=RED,
    )
    draw_box_state(
        ax,
        (2.0, -1.2),
        "success\n(u1=3, u2=3)",
        width=1.3,
        height=0.55,
        facecolor="#e8f8ef",
        edgecolor=GREEN,
    )

    draw_arrow(
        ax,
        (0.0, 0.2),
        (-2.4, -1.2),
        curvature=0.2,
        color=RED,
        start_box=module_box,
        end_box=(1.5, 0.55),
    )
    draw_arrow(
        ax,
        (0.0, 0.2),
        (2.0, -1.2),
        curvature=-0.2,
        color=GREEN,
        start_box=module_box,
        end_box=(1.3, 0.55),
    )
    ax.text(
        -0.2,
        -2.0,
        r"`A F success` false; `P=? [ G deadlock ]` = 0.5 with competition",
        ha="center",
        va="center",
        fontsize=8,
        color=DARK,
    )

    ax.set_xlim(-3.8, 3.8)
    ax.set_ylim(-2.5, 3.2)
    ax.set_title("PRISM coffee-machine composition", fontsize=10, pad=8)
    save_figure(fig, OUT, "prism-coffee-machine.pdf")


def simulate_lotka_extinction_curve(
    bounds: np.ndarray,
    n_sims: int = 2000,
    seed: int = 7,
    v0: int = 100,
    p0: int = 100,
    k1: float = 1.0,
    k2: float = 0.01,
    k3: float = 1.0,
    capacity: int = 1000,
) -> np.ndarray:
    """Estimate bounded predator-extinction probabilities for a Lotka-Volterra CTMC."""
    rng = np.random.default_rng(seed)
    extinction_times = np.full(n_sims, np.inf)

    for idx in range(n_sims):
        v, p = v0, p0
        t = 0.0
        while p > 0:
            rate_birth = k1 * v if v > 0 and v < capacity else 0.0
            rate_pred = k2 * v * p if v > 0 and p > 0 and p < capacity else 0.0
            rate_death = k3 * p if p > 0 else 0.0
            total = rate_birth + rate_pred + rate_death
            if total <= 0.0:
                break
            dt = rng.exponential(1.0 / total)
            t += dt
            u = rng.random() * total
            if u < rate_birth:
                v += 1
            elif u < rate_birth + rate_pred:
                v = max(0, v - 1)
                p = min(capacity, p + 1)
            else:
                p -= 1
                if p == 0:
                    extinction_times[idx] = t
                    break

    return np.array([(extinction_times <= bound).mean() for bound in bounds])


def plot_lotka_smc_extinction() -> None:
    apply_style()
    bounds = np.array([10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 75.0, 100.0, 125.0, 150.0])
    probs = simulate_lotka_extinction_curve(bounds)

    fig, ax = plt.subplots(figsize=(6.4, 3.4))
    ax.plot(bounds, probs, color=BLACK, marker="o", markersize=4, label="SMC estimate")
    ax.axhline(1.0, color=LIGHT, linestyle=":", linewidth=1.0, label=r"$P=? [ F\ p=0 ] = 1$ (unbounded)")
    ax.set_xlabel(r"time bound $t$")
    ax.set_ylabel(r"$P(\mathrm{predator\ extinction\ by}\ t)$")
    ax.set_ylim(-0.02, 1.05)
    ax.set_xlim(5, 155)
    ax.legend(frameon=False, fontsize=8, loc="lower right")
    ax.set_title("Lotka-Volterra CTMC: bounded extinction probability")
    fig.tight_layout()
    save_figure(fig, OUT, "lotka-smc-extinction.pdf")


def sir_cumulative(t: np.ndarray, beta: float, gamma: float, p_lock: float, lock_day: float) -> np.ndarray:
    s, i, r = 0.99, 0.01, 0.0
    values = []
    dt = 0.05
    for day in t:
        steps = max(1, int(day / dt))
        s, i, r = 0.99, 0.01, 0.0
        elapsed = 0.0
        for _ in range(steps):
            contact = beta * (p_lock if elapsed >= lock_day else 1.0) * s * i
            ds = -contact
            di = contact - gamma * i
            dr = gamma * i
            s = max(0.0, s + ds * dt)
            i = max(0.0, i + di * dt)
            r = min(1.0, r + dr * dt)
            elapsed += dt
        values.append(i + r)
    return np.array(values)


def plot_tuscany_covid() -> None:
    apply_style()
    rng = np.random.default_rng(42)
    days = np.arange(0, 71)
    beta, gamma = 0.11, 0.07
    p_loc = 0.35
    fitted = sir_cumulative(days, beta, gamma, p_lock=p_loc, lock_day=35.0)
    noise = rng.normal(0.0, 0.004, size=days.shape)
    observed = np.clip(fitted + noise, 0.0, 1.0)
    observed[::3] += rng.normal(0.0, 0.006, size=observed[::3].shape)

    horizons = np.array([10, 20, 30])
    no_lock = np.array([0.42, 0.68, 0.81])
    lockdown = np.array([0.03, 0.09, 0.18])

    fig, axes = plt.subplots(1, 2, figsize=(10.2, 3.6))

    axes[0].plot(days, fitted, color=BLACK, label="fitted ODE ($I+R$)")
    axes[0].scatter(days[::4], observed[::4], s=14, color=MID, alpha=0.8, label="synthetic data")
    axes[0].axvline(35, color=LIGHT, linestyle="--", linewidth=1.0)
    axes[0].text(36, 0.05, "lockdown", fontsize=8, color=MID)
    axes[0].set_xlabel("day")
    axes[0].set_ylabel("cumulative identified cases (fraction)")
    axes[0].set_title("Pisa-style ODE fit (first 70 days)")
    axes[0].legend(frameon=False, fontsize=8)

    width = 2.5
    axes[1].bar(horizons - width / 4, no_lock, width=width / 2, color=MID, label=r"$p=1$ (no lockdown)")
    axes[1].bar(horizons + width / 4, lockdown, width=width / 2, color=BLACK, label=rf"$p={p_loc}$ (lockdown)")
    axes[1].set_xlabel("horizon (days)")
    axes[1].set_ylabel(r"$P(\mathrm{reach\ infection\ cap})$")
    axes[1].set_xticks(horizons)
    axes[1].set_ylim(0, 1.0)
    axes[1].set_title("PRISM infection risk comparison")
    axes[1].legend(frameon=False, fontsize=8)

    fig.tight_layout()
    save_figure(fig, OUT, "tuscany-covid.pdf")


def main() -> None:
    apply_style()
    plot_ctl_example_graph()
    plot_prism_coffee_machine()
    plot_lotka_smc_extinction()
    plot_tuscany_covid()


if __name__ == "__main__":
    main()
