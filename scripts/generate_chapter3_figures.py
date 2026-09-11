#!/usr/bin/env python3
"""Generate figures for Chapter 3 (continuous dynamical systems)."""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp

OUT = Path(__file__).resolve().parents[1] / "src" / "images" / "chapter3"

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


def iterate_two_sex_discrete(
    steps: int,
    r: float = 2.0,
    k: float = 100.0,
    delta: float = 0.1,
    f0: float = 40.0,
    m0: float = 30.0,
) -> tuple[np.ndarray, np.ndarray]:
    fs = np.empty(steps + 1)
    ms = np.empty(steps + 1)
    fs[0] = f0
    ms[0] = m0
    f, m = f0, m0
    for t in range(steps):
        mod = 1 - (f + m) / k
        growth = r * f * mod
        f_next = f + growth
        m_next = m + growth - delta * m
        f, m = f_next, m_next
        fs[t + 1] = f
        ms[t + 1] = m
    return fs, ms


def integrate_two_sex_continuous(
    t_end: float,
    n_points: int = 400,
    r: float = 2.0,
    k: float = 100.0,
    delta: float = 0.1,
    f0: float = 40.0,
    m0: float = 30.0,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    def rhs(_t: float, state: np.ndarray) -> list[float]:
        f, m = state
        mod = 1 - (f + m) / k
        growth = r * f * mod
        return [growth, growth - delta * m]

    sol = solve_ivp(rhs, (0.0, t_end), [f0, m0], max_step=0.1, dense_output=True)
    t = np.linspace(0.0, t_end, n_points)
    y = sol.sol(t)
    return t, y[0], y[1]


def plot_two_sex_discrete_vs_continuous() -> None:
    steps = 30
    t_disc = np.arange(steps + 1)
    fs, ms = iterate_two_sex_discrete(steps)
    t_cont, fc, mc = integrate_two_sex_continuous(80.0)

    fig, axes = plt.subplots(1, 2, figsize=(10.2, 3.4), sharey=True)

    axes[0].plot(t_disc, fs, color=BLACK, label=r"$F_t$")
    axes[0].plot(t_disc, ms, color=MID, linestyle="--", label=r"$M_t$")
    axes[0].axhline(100.0, color=LIGHT, linewidth=1.0, linestyle=":")
    axes[0].set_title("Discrete model")
    axes[0].set_xlabel(r"$t$ (steps)")
    axes[0].set_ylabel(r"population")
    axes[0].legend(frameon=False)

    axes[1].plot(t_cont, fc, color=BLACK, label=r"$F(t)$")
    axes[1].plot(t_cont, mc, color=MID, linestyle="--", label=r"$M(t)$")
    axes[1].axhline(100.0, color=LIGHT, linewidth=1.0, linestyle=":")
    axes[1].set_title("Continuous model")
    axes[1].set_xlabel(r"$t$")
    axes[1].legend(frameon=False)

    fig.suptitle(
        r"$r_F = r_M = 2$, $K = 100$, $\delta = 0.1$, $F_0 = 40$, $M_0 = 30$",
        fontsize=10,
        y=1.02,
    )
    fig.tight_layout()
    save(fig, "two-sex-discrete-vs-continuous.pdf")


def explicit_euler(f, n0: float, tau: float, steps: int) -> tuple[np.ndarray, np.ndarray]:
    values = np.empty(steps + 1)
    values[0] = n0
    for k in range(steps):
        values[k + 1] = values[k] + tau * f(values[k])
    return np.arange(steps + 1) * tau, values


def implicit_euler_linear(
    f_coeff: float, n0: float, tau: float, steps: int
) -> tuple[np.ndarray, np.ndarray]:
    values = np.empty(steps + 1)
    values[0] = n0
    scale = 1 / (1 - tau * f_coeff)
    for k in range(steps):
        values[k + 1] = values[k] * scale
    return np.arange(steps + 1) * tau, values


def plot_euler_methods() -> None:
    r_c = 2.0
    n0 = 1.0
    tau = 0.1
    t_end = 1.0
    steps = int(t_end / tau)

    def f(n: float) -> float:
        return r_c * n

    t_euler, n_explicit = explicit_euler(f, n0, tau, steps)
    t_exact = np.linspace(0.0, t_end, 200)
    n_exact = n0 * np.exp(r_c * t_exact)

    _, n_implicit = implicit_euler_linear(r_c, n0, tau, steps)

    fig, axes = plt.subplots(1, 2, figsize=(10.2, 3.4), sharey=True)

    for ax, method, t_vals, n_vals, title in (
        (
            axes[0],
            "explicit",
            t_euler,
            n_explicit,
            rf"Explicit Euler ($\tau = {tau}$)",
        ),
        (
            axes[1],
            "implicit",
            t_euler,
            n_implicit,
            rf"Implicit Euler ($\tau = {tau}$)",
        ),
    ):
        ax.plot(t_exact, n_exact, color=LIGHT, linewidth=1.2, label="exact")
        ax.plot(t_vals, n_vals, color=BLACK, marker="o", markersize=4, label=method)

        for k in range(min(5, steps)):
            x0, y0 = t_vals[k], n_vals[k]
            x1 = x0 + tau
            if method == "explicit":
                y_end = y0 + tau * r_c * y0
            else:
                y_end = n_vals[k + 1]
            ax.plot([x0, x1], [y0, y_end], color=MID, linewidth=1.0)

        ax.set_title(title, fontsize=9)
        ax.set_xlabel(r"$t$")
        ax.set_ylabel(r"$n(t)$")
        ax.legend(frameon=False, fontsize=8)

    fig.suptitle(r"$\dot{n} = 2n$, $n_0 = 1$", fontsize=10, y=1.02)
    fig.tight_layout()
    save(fig, "euler-explicit-implicit.pdf")


def plot_oregonator() -> None:
    s = 77.27
    w = 0.161

    def oregonator(_t: float, x: np.ndarray) -> list[float]:
        a, b, c = x
        return [s * (b - a), (c - b - b * a) / s, w * (a - c)]

    sol = solve_ivp(oregonator, (0.0, 2.0), [1.0, 1.0, 2.0], method="BDF", max_step=0.01)
    t = sol.t
    a, b, c = sol.y

    fig, axes = plt.subplots(1, 2, figsize=(10.2, 3.4))

    axes[0].plot(t, b, color=BLACK, label=r"$B(t)$")
    axes[0].plot(t, c, color=MID, linestyle="--", label=r"$C(t)$")
    axes[0].set_xlabel(r"$t$")
    axes[0].set_ylabel(r"concentration")
    axes[0].set_title("Oscillatory components")
    axes[0].legend(frameon=False)

    axes[1].plot(t, a, color=BLACK, label=r"$A(t)$")
    axes[1].set_xlabel(r"$t$")
    axes[1].set_ylabel(r"concentration")
    axes[1].set_title("Slow variable")
    axes[1].legend(frameon=False)

    fig.suptitle(
        rf"Oregonator ($s = {s}$, $w = {w}$, $[A_0, B_0, C_0] = [1, 1, 2]$)",
        fontsize=10,
        y=1.02,
    )
    fig.tight_layout()
    save(fig, "oregonator-stiff.pdf")


def main() -> None:
    plot_two_sex_discrete_vs_continuous()
    plot_euler_methods()
    plot_oregonator()


if __name__ == "__main__":
    main()
