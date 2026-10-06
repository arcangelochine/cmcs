#!/usr/bin/env python3
"""Generate figures for Chapter 11 (agent-based modeling and cellular automata)."""

from __future__ import annotations

import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
from matplotlib.patches import Circle, FancyArrowPatch, Polygon, Rectangle

from figure_common import BLACK, LIGHT, MID, apply_style, circle_anchor, save

CHAPTER = 11
RED = "#c44"
BLUE = "#48c"
NEIGHBOR_FILL = "#d9d9d9"

apply_style()


def save_fig(fig: plt.Figure, name: str) -> None:
    preview_dir = os.environ.get("FIG_PREVIEW")
    if preview_dir:
        directory = Path(preview_dir)
        directory.mkdir(parents=True, exist_ok=True)
        fig.savefig(directory / (Path(name).stem + ".png"), bbox_inches="tight", dpi=110)
    save(fig, CHAPTER, name)


def plot_ode_vs_abm() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(10.0, 3.8))

    ax = axes[0]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6)
    ax.axis("off")
    ax.set_title("Top-down (ODE / aggregate)", fontsize=10)
    ax.add_patch(Rectangle((1, 2), 8, 2.5, fill=False, edgecolor=BLACK, linewidth=1.5))
    ax.text(5, 3.25, r"$S(t),\ I(t),\ R(t)$", ha="center", va="center", fontsize=12)
    ax.text(5, 5.2, "Population-level variables", ha="center", fontsize=9, color=MID)
    ax.annotate(
        r"$\dot{S} = f(S,I,R)$",
        xy=(5, 2),
        xytext=(5, 0.8),
        ha="center",
        fontsize=9,
        arrowprops={"arrowstyle": "->", "color": MID},
    )

    ax = axes[1]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6)
    ax.axis("off")
    ax.set_title("Bottom-up (ABM)", fontsize=10)
    rng = np.random.default_rng(7)
    for _ in range(40):
        x, y = rng.uniform(1.5, 8.5), rng.uniform(1.2, 4.8)
        color = RED if rng.random() < 0.5 else BLUE
        ax.add_patch(Circle((x, y), 0.12, facecolor=color, edgecolor=BLACK, linewidth=0.4))
    for _ in range(6):
        x0, y0 = rng.uniform(2, 8), rng.uniform(1.5, 4.5)
        x1, y1 = x0 + rng.uniform(-0.8, 0.8), y0 + rng.uniform(-0.8, 0.8)
        p0 = circle_anchor((x0, y0), (x1, y1), 0.12)
        p1 = circle_anchor((x1, y1), (x0, y0), 0.12)
        ax.add_patch(
            FancyArrowPatch(
                p0, p1, arrowstyle="-|>", mutation_scale=8, color=LIGHT,
                linewidth=0.8, shrinkA=0, shrinkB=0, zorder=1,
            )
        )
    ax.text(5, 5.2, "Individual rules + local interaction", ha="center", fontsize=9, color=MID)
    ax.text(5, 0.5, r"Emergence: clusters, segregation, flocks $\ldots$", ha="center", fontsize=9, color=MID)

    fig.tight_layout()
    save_fig(fig, "ode-vs-abm.pdf")


def _square_panel(ax: plt.Axes, title: str, neighbors: set[tuple[int, int]]) -> None:
    ax.set_xlim(-0.2, 5.2)
    ax.set_ylim(-0.2, 5.2)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title(title, fontsize=10)
    for i in range(5):
        for j in range(5):
            if (i, j) == (2, 2):
                face, edge, lw = MID, BLACK, 1.6
            elif (i, j) in neighbors:
                face, edge, lw = NEIGHBOR_FILL, BLACK, 0.8
            else:
                face, edge, lw = "white", LIGHT, 0.6
            ax.add_patch(Rectangle((i, j), 1, 1, facecolor=face, edgecolor=edge, linewidth=lw))


def _hex_panel(ax: plt.Axes) -> None:
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Hexagonal (6 neighbors)", fontsize=10)
    radius = 0.5
    width = np.sqrt(3) * radius
    angles = np.deg2rad(np.arange(30, 390, 60))
    center = (2, 2)
    # Axial neighbours of an odd-r offset layout for the centre (2, 2).
    neighbor_cells = {(1, 2), (3, 2), (1, 1), (2, 1), (1, 3), (2, 3)}
    for row in range(5):
        for col in range(5):
            cx = col * width + (width / 2 if row % 2 else 0)
            cy = row * 1.5 * radius
            verts = np.column_stack([cx + radius * np.cos(angles), cy + radius * np.sin(angles)])
            if (col, row) == center:
                face, edge, lw = MID, BLACK, 1.6
            elif (col, row) in neighbor_cells:
                face, edge, lw = NEIGHBOR_FILL, BLACK, 0.8
            else:
                face, edge, lw = "white", LIGHT, 0.6
            ax.add_patch(Polygon(verts, closed=True, facecolor=face, edgecolor=edge, linewidth=lw))
    ax.set_xlim(-0.6, 5 * width + 0.2)
    ax.set_ylim(-0.7, 4 * 1.5 * radius + 0.7)


def _triangle_panel(ax: plt.Axes) -> None:
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Triangular (3 edge neighbors)", fontsize=10)
    h = np.sqrt(3) / 2
    center = (2, 4)
    neighbors = {(2, 3), (2, 5), (1, 4)}
    for row in range(4):
        for k in range(9):
            x0 = k * 0.5
            up = (k + row) % 2 == 0
            y0 = row * h
            if up:
                verts = [(x0, y0), (x0 + 1, y0), (x0 + 0.5, y0 + h)]
            else:
                verts = [(x0, y0 + h), (x0 + 1, y0 + h), (x0 + 0.5, y0)]
            if (row, k) == center:
                face, edge, lw = MID, BLACK, 1.6
            elif (row, k) in neighbors:
                face, edge, lw = NEIGHBOR_FILL, BLACK, 0.8
            else:
                face, edge, lw = "white", LIGHT, 0.6
            ax.add_patch(Polygon(verts, closed=True, facecolor=face, edgecolor=edge, linewidth=lw))
    ax.set_xlim(-0.2, 5.2)
    ax.set_ylim(-0.4, 4 * h + 0.4)


def plot_grid_neighborhoods() -> None:
    fig, axes = plt.subplots(1, 4, figsize=(12.0, 3.3))
    von = {(2, 1), (2, 3), (1, 2), (3, 2)}
    moore = von | {(1, 1), (1, 3), (3, 1), (3, 3)}
    _square_panel(axes[0], "von Neumann (4 neighbors)", von)
    _square_panel(axes[1], "Moore (8 neighbors)", moore)
    _hex_panel(axes[2])
    _triangle_panel(axes[3])
    fig.tight_layout()
    save_fig(fig, "grid-neighborhoods.pdf")


def _similar_fraction(grid: np.ndarray, i: int, j: int) -> float | None:
    size = grid.shape[0]
    own = grid[i, j]
    occupied = similar = 0
    for di in (-1, 0, 1):
        for dj in (-1, 0, 1):
            if di == 0 and dj == 0:
                continue
            other = grid[(i + di) % size, (j + dj) % size]
            if other:
                occupied += 1
                similar += other == own
    return None if occupied == 0 else similar / occupied


def mean_similarity(grid: np.ndarray) -> float:
    values = [
        _similar_fraction(grid, i, j)
        for i in range(grid.shape[0])
        for j in range(grid.shape[1])
        if grid[i, j]
    ]
    return float(np.mean([v for v in values if v is not None]))


def run_schelling(grid: np.ndarray, theta: float, sweeps: int, rng: np.random.Generator) -> np.ndarray:
    """Unhappy agents (similar share below theta) jump to a random empty cell."""
    grid = grid.copy()
    size = grid.shape[0]
    for _ in range(sweeps):
        unhappy = [
            (i, j)
            for i in range(size)
            for j in range(size)
            if grid[i, j] and (_similar_fraction(grid, i, j) or 0.0) < theta
        ]
        if not unhappy:
            break
        rng.shuffle(unhappy)
        for i, j in unhappy:
            empties = np.argwhere(grid == 0)
            ei, ej = empties[rng.integers(len(empties))]
            grid[ei, ej], grid[i, j] = grid[i, j], 0
    return grid


def plot_schelling_segregation() -> None:
    rng = np.random.default_rng(42)
    size = 40
    initial = rng.choice([0, 1, 2], size=(size, size), p=[0.1, 0.45, 0.45])
    cmap = ListedColormap(["white", RED, BLUE])

    fig, axes = plt.subplots(1, 4, figsize=(12.0, 3.4))
    panels = [("Initial (random)", initial)]
    for theta in (0.15, 0.30, 0.50):
        final = run_schelling(initial, theta, sweeps=60, rng=np.random.default_rng(int(theta * 100)))
        panels.append((rf"$\theta = {theta:.2f}$", final))
    for ax, (title, grid) in zip(axes, panels):
        ax.imshow(grid, cmap=cmap, interpolation="nearest", vmin=0, vmax=2)
        ax.set_title(f"{title}\nmean similar share {mean_similarity(grid):.2f}", fontsize=9)
        ax.set_xticks([])
        ax.set_yticks([])
        ax.grid(False)
    fig.tight_layout()
    save_fig(fig, "schelling-segregation.pdf")


def run_boids(
    weights: tuple[float, float, float],
    rng: np.random.Generator,
    n: int = 60,
    steps: int = 300,
    radius: float = 12.0,
    size: float = 100.0,
    speed: float = 1.5,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Boids on a torus; weights = (cohesion, alignment, separation)."""
    w_coh, w_ali, w_sep = weights
    pos = rng.uniform(0, size, (n, 2))
    angle = rng.uniform(0, 2 * np.pi, n)
    vel = speed * np.column_stack([np.cos(angle), np.sin(angle)])
    history = [pos.copy()]
    for _ in range(steps):
        new_vel = vel.copy()
        for i in range(n):
            diff = pos - pos[i]
            diff -= size * np.round(diff / size)
            dist = np.linalg.norm(diff, axis=1)
            mask = (dist > 0) & (dist < radius)
            if not np.any(mask):
                continue
            cohesion = 0.01 * diff[mask].mean(axis=0)
            alignment = 0.125 * (vel[mask].mean(axis=0) - vel[i])
            close = mask & (dist < 3)
            separation = -(diff[close] / dist[close, None] ** 2).sum(axis=0) if np.any(close) else 0
            new_vel[i] = vel[i] + w_coh * cohesion + w_ali * alignment + w_sep * separation
            new_vel[i] *= speed / np.linalg.norm(new_vel[i])
        vel = new_vel
        pos = (pos + vel) % size
        history.append(pos.copy())
    return np.array(history), pos, vel


def plot_boids_flock() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(10.0, 4.8))
    cases = [
        ((0.0, 0.0, 0.0), r"$w_1 = w_2 = w_3 = 0$"),
        ((1.0, 1.0, 1.5), r"cohesion $w_1 = 1$, separation $w_2 = 1.5$, alignment $w_3 = 1$"),
    ]
    for ax, (weights, label) in zip(axes, cases):
        history, pos, vel = run_boids(weights, np.random.default_rng(11))
        heading = vel / np.linalg.norm(vel, axis=1, keepdims=True)
        polarization = np.linalg.norm(heading.mean(axis=0))
        for i in range(0, 60, 3):
            track = history[-25:, i]
            jumps = np.where(np.abs(np.diff(track, axis=0)).max(axis=1) > 50)[0] + 1
            for seg in np.split(track, jumps):
                ax.plot(seg[:, 0], seg[:, 1], color=LIGHT, linewidth=0.6)
        ax.quiver(
            pos[:, 0], pos[:, 1], heading[:, 0], heading[:, 1],
            color=BLACK, scale=28, width=0.006, headwidth=4, zorder=3,
        )
        ax.set_xlim(0, 100)
        ax.set_ylim(0, 100)
        ax.set_aspect("equal")
        ax.set_title(f"{label}\npolarization {polarization:.2f}", fontsize=10)
        ax.set_xlabel(r"$x$")
        ax.set_ylabel(r"$y$")
    fig.tight_layout()
    save_fig(fig, "boids-flock.pdf")


def elementary_step(row: np.ndarray, rule: int) -> np.ndarray:
    left = np.roll(row, 1)
    right = np.roll(row, -1)
    index = 4 * left + 2 * row + right
    table = np.array([(rule >> k) & 1 for k in range(8)])
    return table[index]


def space_time(rule: int, row: np.ndarray, steps: int) -> np.ndarray:
    rows = [row]
    for _ in range(steps - 1):
        rows.append(elementary_step(rows[-1], rule))
    return np.array(rows)


def plot_rule184_spacetime() -> None:
    n_cells, n_steps = 60, 45
    fig, axes = plt.subplots(1, 2, figsize=(10.0, 4.2))
    for ax, density in zip(axes, (0.30, 0.70)):
        rng = np.random.default_rng(184)
        row = (rng.random(n_cells) < density).astype(int)
        ax.imshow(space_time(184, row, n_steps), cmap="Greys", aspect="auto", interpolation="nearest")
        ax.set_title(rf"Rule 184, car density $\rho = {density:.2f}$", fontsize=10)
        ax.set_xlabel("cell (road position)")
        ax.set_ylabel(r"time step $t$")
        ax.grid(False)
    fig.tight_layout()
    save_fig(fig, "rule184-spacetime.pdf")


def plot_wolfram_classes() -> None:
    n_cells, n_steps = 120, 90
    rng = np.random.default_rng(30)
    row = (rng.random(n_cells) < 0.5).astype(int)
    cases = [
        (160, "Class 1: rule 160 (homogeneous)"),
        (108, "Class 2: rule 108 (periodic)"),
        (30, "Class 3: rule 30 (chaotic)"),
        (110, "Class 4: rule 110 (localized structures)"),
    ]
    fig, axes = plt.subplots(1, 4, figsize=(12.0, 3.6))
    for ax, (rule, title) in zip(axes, cases):
        ax.imshow(space_time(rule, row, n_steps), cmap="Greys", aspect="auto", interpolation="nearest")
        ax.set_title(title, fontsize=9)
        ax.set_xticks([])
        ax.set_yticks([])
        ax.grid(False)
    axes[0].set_ylabel(r"time step $t$ (downward)")
    fig.tight_layout()
    save_fig(fig, "wolfram-classes.pdf")


def life_step(grid: np.ndarray) -> np.ndarray:
    neighbors = sum(
        np.roll(np.roll(grid, di, axis=0), dj, axis=1)
        for di in (-1, 0, 1)
        for dj in (-1, 0, 1)
        if (di, dj) != (0, 0)
    )
    birth = (grid == 0) & (neighbors == 3)
    survive = (grid == 1) & ((neighbors == 2) | (neighbors == 3))
    return (birth | survive).astype(int)


def _life_panel(ax: plt.Axes, grid: np.ndarray, title: str) -> None:
    rows, cols = grid.shape
    ax.imshow(grid, cmap="Greys", interpolation="nearest", vmin=0, vmax=1)
    ax.set_xticks(np.arange(-0.5, cols, 1), minor=True)
    ax.set_yticks(np.arange(-0.5, rows, 1), minor=True)
    ax.grid(which="minor", color=LIGHT, linewidth=0.5)
    ax.grid(which="major", visible=False)
    ax.tick_params(which="both", length=0, labelbottom=False, labelleft=False)
    for spine in ax.spines.values():
        spine.set_visible(True)
        spine.set_color(LIGHT)
    ax.set_title(title, fontsize=9)


def plot_game_of_life() -> None:
    glider = np.zeros((6, 6), dtype=int)
    glider[0, 1] = glider[1, 2] = 1
    glider[2, 0:3] = 1
    blinker = np.zeros((5, 5), dtype=int)
    blinker[2, 1:4] = 1
    block = np.zeros((4, 4), dtype=int)
    block[1:3, 1:3] = 1

    fig = plt.figure(figsize=(10.0, 4.6))
    grid_spec = fig.add_gridspec(2, 5, hspace=0.35)
    state = glider
    for t in range(5):
        _life_panel(fig.add_subplot(grid_spec[0, t]), state, rf"glider, $t = {t}$")
        state = life_step(state)
    _life_panel(fig.add_subplot(grid_spec[1, 0]), block, "block (still life)")
    _life_panel(fig.add_subplot(grid_spec[1, 1]), blinker, r"blinker, $t = 0$")
    _life_panel(fig.add_subplot(grid_spec[1, 2]), life_step(blinker), r"blinker, $t = 1$")
    _life_panel(fig.add_subplot(grid_spec[1, 3]), life_step(life_step(blinker)), r"blinker, $t = 2$")
    save_fig(fig, "game-of-life.pdf")


def plot_boundary_conditions() -> None:
    labels = ["a", "b", "c", "d", "e", "f"]
    cases = [
        ("Periodic", "f", "a"),
        ("Fixed (state 0)", "0", "0"),
        ("Adiabatic", "a", "f"),
        ("Reflecting", "b", "e"),
    ]
    fig, ax = plt.subplots(figsize=(7.0, 3.4))
    ax.set_xlim(-4.6, 7.2)
    ax.set_ylim(-0.3, len(cases) * 1.2)
    ax.axis("off")
    for row, (name, left, right) in enumerate(cases):
        y = (len(cases) - 1 - row) * 1.2
        ax.text(-4.5, y + 0.45, name, ha="left", va="center", fontsize=10)
        cells = [(-1, left, True)] + [(k, lab, False) for k, lab in enumerate(labels)] + [(6, right, True)]
        for x, lab, ghost in cells:
            face = NEIGHBOR_FILL if ghost else "white"
            style = "--" if ghost else "-"
            ax.add_patch(
                Rectangle((x, y), 0.9, 0.9, facecolor=face, edgecolor=BLACK, linewidth=0.9, linestyle=style)
            )
            ax.text(x + 0.45, y + 0.45, rf"${lab}$", ha="center", va="center", fontsize=11)
        ax.plot([-0.05, -0.05], [y - 0.1, y + 1.0], color=MID, linewidth=1.4)
        ax.plot([5.95, 5.95], [y - 0.1, y + 1.0], color=MID, linewidth=1.4)
    save_fig(fig, "boundary-conditions.pdf")


def make_maze(n_cells: int, rng: np.random.Generator) -> np.ndarray:
    """Perfect maze by randomized depth-first search; 1 = wall, 0 = free."""
    size = 2 * n_cells + 1
    grid = np.ones((size, size), dtype=int)
    visited = np.zeros((n_cells, n_cells), dtype=bool)
    stack = [(0, 0)]
    visited[0, 0] = True
    grid[1, 1] = 0
    while stack:
        i, j = stack[-1]
        options = [
            (i + di, j + dj)
            for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1))
            if 0 <= i + di < n_cells and 0 <= j + dj < n_cells and not visited[i + di, j + dj]
        ]
        if not options:
            stack.pop()
            continue
        ni, nj = options[rng.integers(len(options))]
        grid[2 * i + 1 + (ni - i), 2 * j + 1 + (nj - j)] = 0
        grid[2 * ni + 1, 2 * nj + 1] = 0
        visited[ni, nj] = True
        stack.append((ni, nj))
    grid[0, 1] = 0
    grid[size - 1, size - 2] = 0
    return grid


def dead_end_step(grid: np.ndarray, fixed: set[tuple[int, int]]) -> np.ndarray:
    free = grid == 0
    padded = np.pad(free, 1, constant_values=False)
    free_neighbors = (
        padded[:-2, 1:-1].astype(int) + padded[2:, 1:-1] + padded[1:-1, :-2] + padded[1:-1, 2:]
    )
    new = grid.copy()
    dead = free & (free_neighbors <= 1)
    for i, j in fixed:
        dead[i, j] = False
    new[dead] = 1
    return new


def plot_maze_solving() -> None:
    grid = make_maze(10, np.random.default_rng(5))
    size = grid.shape[0]
    fixed = {(0, 1), (size - 1, size - 2)}
    states = [grid]
    while True:
        nxt = dead_end_step(states[-1], fixed)
        if np.array_equal(nxt, states[-1]):
            break
        states.append(nxt)
    last = len(states) - 1
    picks = [0, 3, last // 2, last]
    fig, axes = plt.subplots(1, 4, figsize=(12.0, 3.4))
    for ax, t in zip(axes, picks):
        ax.imshow(states[t], cmap="Greys", interpolation="nearest", vmin=0, vmax=1)
        for i, j in fixed:
            ax.add_patch(Circle((j, i), 0.35, facecolor=RED, edgecolor=BLACK, linewidth=0.5))
        title = "initial maze" if t == 0 else (f"step {t} (solved)" if t == last else f"step {t}")
        ax.set_title(title, fontsize=10)
        ax.set_xticks([])
        ax.set_yticks([])
        ax.grid(False)
    fig.tight_layout()
    save_fig(fig, "maze-solving.pdf")


def main() -> None:
    plot_ode_vs_abm()
    plot_grid_neighborhoods()
    plot_schelling_segregation()
    plot_boids_flock()
    plot_rule184_spacetime()
    plot_wolfram_classes()
    plot_game_of_life()
    plot_boundary_conditions()
    plot_maze_solving()


if __name__ == "__main__":
    main()
