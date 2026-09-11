#!/usr/bin/env python3
"""Generate figures for Chapter 2 (discrete dynamical systems)."""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

OUT = Path(__file__).resolve().parents[1] / "src" / "images" / "chapter2"

plt.rcParams.update(
    {
        "figure.facecolor": "white",
        "axes.facecolor": "white",
        "savefig.facecolor": "white",
        "font.family": "serif",
        "mathtext.fontset": "cm",
        "font.size": 10,
        "axes.labelsize": 10,
        "axes.titlesize": 10,
        "legend.fontsize": 9,
        "xtick.labelsize": 9,
        "ytick.labelsize": 9,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.grid": True,
        "grid.color": "#cccccc",
        "grid.linewidth": 0.6,
        "lines.linewidth": 1.4,
    }
)

BLACK = "#000000"
DARK = "#333333"
MID = "#666666"
LIGHT = "#999999"


def save(fig: plt.Figure, name: str) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    fig.savefig(path, format="pdf", bbox_inches="tight", dpi=300)
    plt.close(fig)
    print(f"wrote {path}")


def cobweb(
    ax,
    f,
    n0: float,
    steps: int,
    n_max: float,
    recurrence_label: str,
    show_legend: bool = True,
) -> None:
    ns = np.linspace(0, n_max, 400)
    ax.plot(ns, ns, color=LIGHT, linewidth=1.2, linestyle="--", label=r"$n_{t+1} = n_t$")
    ax.plot(ns, f(ns), color=BLACK, linewidth=1.6, label=recurrence_label)

    x = n0
    xs, ys = [x], [x]
    for _ in range(steps):
        y = float(f(x))
        xs.extend([x, y])
        ys.extend([y, y])
        x = y
    ax.plot(xs, ys, color=MID, linewidth=1.2, marker="o", markersize=3.5, label=r"trajectory")
    ax.set_xlim(0, n_max)
    ax.set_ylim(0, n_max)
    ax.set_aspect("equal", adjustable="box")
    ax.set_xlabel(r"$n_t$")
    ax.set_ylabel(r"$n_{t+1}$")
    if show_legend:
        ax.legend(frameon=False, fontsize=8)


def plot_growth_bacteria_fish() -> None:
    t = np.arange(0, 6)
    bacteria = 2.0 ** t
    fish = 13.0 ** t

    fig, ax = plt.subplots(figsize=(5.0, 3.2))
    ax.semilogy(t, bacteria, color=BLACK, marker="o", label=r"$R_d = 2$")
    ax.semilogy(t, fish, color=MID, marker="s", linestyle="--", label=r"$R_d = 13$")
    ax.set_xlabel(r"$t$")
    ax.set_ylabel(r"$n_t$")
    ax.set_title(r"Exponential growth ($n_0 = 1$)")
    ax.legend(frameon=False)
    fig.tight_layout()
    save(fig, "growth-bacteria-fish.pdf")


def plot_phase_portrait_growth() -> None:
    fig, ax = plt.subplots(figsize=(4.2, 4.2))
    r_d = 2.0
    cobweb(
        ax,
        lambda n: r_d * n,
        n0=3.0,
        steps=6,
        n_max=40,
        recurrence_label=r"$n_{t+1} = R_d n_t$",
    )
    ax.set_title(r"$R_d = 2$")
    save(fig, "phase-portrait-growth.pdf")


def plot_phase_portrait_alpha_equilibrium(ax, n_max: float) -> None:
    ns = np.linspace(0, n_max, 400)
    ax.plot(ns, ns, color=BLACK, linewidth=2.0, label=r"$n_{t+1} = n_t$")
    for n0 in (6, 12, 18):
        ax.plot(n0, n0, "o", color=MID, markersize=6)
    ax.annotate(
        r"fixed points",
        xy=(15, 15),
        xytext=(n_max * 0.45, n_max * 0.78),
        fontsize=8,
        arrowprops={"arrowstyle": "->", "color": MID, "lw": 0.9},
    )
    ax.set_xlim(0, n_max)
    ax.set_ylim(0, n_max)
    ax.set_aspect("equal", adjustable="box")
    ax.set_xlabel(r"$n_t$")
    ax.set_ylabel(r"$n_{t+1}$")
    ax.legend(frameon=False, fontsize=8, loc="lower right")


def plot_phase_portrait_alpha() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(10.5, 3.6))

    cobweb(
        axes[0],
        lambda n: 0.6 * n,
        n0=18.0,
        steps=10,
        n_max=20,
        recurrence_label=r"$n_{t+1} = 0.6\, n_t$",
        show_legend=False,
    )
    axes[0].set_title(r"$\alpha = 0.6$")

    plot_phase_portrait_alpha_equilibrium(axes[1], n_max=20)
    axes[1].set_title(r"$\alpha = 1$")

    cobweb(
        axes[2],
        lambda n: 1.5 * n,
        n0=4.0,
        steps=5,
        n_max=28,
        recurrence_label=r"$n_{t+1} = 1.5\, n_t$",
        show_legend=False,
    )
    axes[2].set_title(r"$\alpha = 1.5$")

    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, frameon=False, loc="upper center", ncol=3, bbox_to_anchor=(0.5, 1.02))
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    save(fig, "phase-portrait-alpha.pdf")


def iterate_migration(alpha: float, beta: float, n0: float, steps: int) -> np.ndarray:
    n = np.empty(steps + 1)
    n[0] = n0
    for t in range(steps):
        n[t + 1] = alpha * n[t] + beta
    return n


def plot_migration_regimes() -> None:
    betas = [5, 10, 20]
    steps = 20
    t = np.arange(steps + 1)
    n0 = 5.0
    styles = ["-", "--", ":"]
    grays = [BLACK, MID, LIGHT]

    fig, axes = plt.subplots(1, 3, figsize=(9.0, 2.8))

    for beta, style, gray in zip(betas, styles, grays):
        axes[0].plot(
            t,
            iterate_migration(1.5, beta, n0, steps),
            linestyle=style,
            color=gray,
            label=rf"$\beta = {beta}$",
        )
    axes[0].set_title(r"$\alpha = 1.5$")
    axes[0].set_xlabel(r"$t$")
    axes[0].set_ylabel(r"$n_t$")
    axes[0].legend(frameon=False)

    for beta, style, gray in zip(betas, styles, grays):
        axes[1].plot(
            t,
            iterate_migration(1.0, beta, n0, steps),
            linestyle=style,
            color=gray,
            label=rf"$\beta = {beta}$",
        )
    axes[1].set_title(r"$\alpha = 1$")
    axes[1].set_xlabel(r"$t$")
    axes[1].set_ylabel(r"$n_t$")
    axes[1].legend(frameon=False)

    for beta, style, gray in zip(betas, styles, grays):
        axes[2].plot(
            t,
            iterate_migration(0.5, beta, n0, steps),
            linestyle=style,
            color=gray,
            label=rf"$\beta = {beta}$",
        )
        eq = beta / (1 - 0.5)
        axes[2].axhline(eq, color=gray, linewidth=0.8, alpha=0.5)
    axes[2].set_title(r"$\alpha = 0.5$")
    axes[2].set_xlabel(r"$t$")
    axes[2].set_ylabel(r"$n_t$")
    axes[2].legend(frameon=False)

    fig.tight_layout()
    save(fig, "migration-regimes.pdf")


def iterate_logistic_trajectory(
    n0: float, r: float, k: float, steps: int
) -> np.ndarray:
    """n_{t+1} = r n_t (1 - n_t / K); equilibrium K(1 - 1/r) for r > 1."""
    values = [n0]
    for _ in range(steps):
        n = values[-1]
        n_next = r * n * (1 - n / k)
        if not np.isfinite(n_next) or n_next < 0:
            break
        values.append(n_next)
    return np.array(values)


def plot_logistic_dynamics() -> None:
    k = 50.0
    n0 = 10.0
    steps = 35
    cases = [
        (2.8, r"Convergence to $K(1 - 1/r)$ ($r = 2.8$)"),
        (3.8, r"High period ($r = 3.8$)"),
        (4.0, r"Infinite period / chaos ($r = 4$)"),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(10.8, 3.2), sharey=True)
    t = np.arange(steps + 1)

    for ax, (r_val, title) in zip(axes, cases):
        values = iterate_logistic_trajectory(n0, r_val, k, steps)
        ax.plot(np.arange(len(values)), values, color=BLACK)
        eq = k * (1 - 1 / r_val)
        ax.axhline(eq, color=LIGHT, linewidth=1.0, linestyle="--")
        ax.axhline(k, color=MID, linewidth=0.8, linestyle=":", alpha=0.7)
        ax.set_title(title, fontsize=9)
        ax.set_xlabel(r"$t$")
        ax.set_ylim(-5, k)

    axes[0].set_ylabel(r"$n_t$")
    fig.tight_layout()
    save(fig, "logistic-dynamics.pdf")


def plot_logistic_bifurcation() -> None:
    k = 50.0
    n0 = 10.0
    highlight_r = (2.8, 3.8, 4.0)
    r_values = np.linspace(1.5, 4.1, 900)
    transient = 500
    record = 80

    r_points: list[float] = []
    n_points: list[float] = []

    for r in r_values:
        n = n0
        for _ in range(transient):
            n = r * n * (1 - n / k)
            if not np.isfinite(n) or n < 0:
                n = n0
                break

        for _ in range(record):
            n = r * n * (1 - n / k)
            if not np.isfinite(n) or n < 0:
                break
            r_points.append(r)
            n_points.append(n)

    fig, ax = plt.subplots(figsize=(6.8, 3.4))
    ax.plot(
        r_points,
        n_points,
        ",",
        color=BLACK,
        markersize=3,
        alpha=1,
        rasterized=True,
    )
    for r_val in highlight_r:
        ax.axvline(r_val, color=MID, linewidth=1.0, linestyle="--")
    ax.set_xlabel(r"$r$")
    ax.set_ylabel(r"$n$")
    ax.set_xlim(r_values[0], r_values[-1] + 0.1)
    ax.set_ylim(0, k)
    ax.set_title(rf"Bifurcation diagram ($K = {k:.0f}$, $n_0 = {n0:.0f}$)")
    fig.tight_layout()
    save(fig, "logistic-bifurcation.pdf")


def iterate_two_sex(steps: int) -> tuple[np.ndarray, np.ndarray]:
    r_f = r_m = 2.0
    k = 100.0
    delta = 0.1
    f = 40.0
    m = 30.0
    fs = np.empty(steps + 1)
    ms = np.empty(steps + 1)
    fs[0] = f
    ms[0] = m
    for t in range(steps):
        mod = 1 - (f + m) / k
        f_next = f + r_f * f * mod
        m_next = m + r_m * f * mod - delta * m
        f, m = f_next, m_next
        fs[t + 1] = f
        ms[t + 1] = m
    return fs, ms


def plot_two_sex() -> None:
    steps = 30
    t = np.arange(steps + 1)
    fs, ms = iterate_two_sex(steps)

    fig, ax = plt.subplots(figsize=(5.5, 3.0))
    ax.plot(t, fs, color=BLACK, label=r"$F_t$")
    ax.plot(t, ms, color=MID, linestyle="--", label=r"$M_t$")
    ax.set_xlabel(r"$t$")
    ax.set_ylabel(r"$N_t$")
    ax.set_title(
        r"$r_F = r_M = 2$, $K = 100$, $\delta = 0.1$, $F_0 = 40$, $M_0 = 30$"
    )
    ax.legend(frameon=False)
    fig.tight_layout()
    save(fig, "two-sex-trajectories.pdf")


def main() -> None:
    plot_growth_bacteria_fish()
    plot_phase_portrait_growth()
    plot_phase_portrait_alpha()
    plot_migration_regimes()
    plot_logistic_dynamics()
    plot_logistic_bifurcation()
    plot_two_sex()


if __name__ == "__main__":
    main()
