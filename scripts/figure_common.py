"""Shared matplotlib styling and drawing helpers for CMCS book figures."""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Circle, FancyArrowPatch, FancyBboxPatch, Rectangle

BLACK = "#000000"
DARK = "#333333"
MID = "#666666"
LIGHT = "#999999"
RED = "#c0392b"
YELLOW = "#f1c40f"
YELLOW_EDGE = "#d4ac0d"
GREEN = "#27ae60"
BLUE = "#2980b9"


def apply_style() -> None:
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


def out_dir(chapter: int | str) -> Path:
    return Path(__file__).resolve().parents[1] / "src" / "images" / f"chapter{chapter}"


def chapter_out_dir(chapter: int | str) -> Path:
    return out_dir(chapter)


def save(fig: plt.Figure, chapter: int | str, name: str) -> Path:
    directory = out_dir(chapter)
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / name
    fig.savefig(path, format="pdf", bbox_inches="tight", dpi=300)
    plt.close(fig)
    print(f"wrote {path}")
    return path


def save_figure(fig: plt.Figure, out_dir: Path, name: str) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / name
    fig.savefig(path, format="pdf", bbox_inches="tight", dpi=300)
    plt.close(fig)
    print(f"wrote {path}")
    return path


def new_diagram_figure(
    width: float = 6.8,
    height: float = 3.8,
    *,
    grid: bool = False,
) -> tuple[plt.Figure, plt.Axes]:
    fig, ax = plt.subplots(figsize=(width, height))
    ax.set_aspect("equal")
    ax.axis("off")
    if not grid:
        ax.grid(False)
    return fig, ax


def draw_state(
    ax,
    xy: tuple[float, float],
    label: str,
    *,
    radius: float = 0.28,
    facecolor: str = "white",
    edgecolor: str = BLACK,
    fontsize: float = 9,
    linewidth: float = 1.2,
) -> Circle:
    circle = Circle(
        xy,
        radius,
        facecolor=facecolor,
        edgecolor=edgecolor,
        linewidth=linewidth,
        zorder=2,
    )
    ax.add_patch(circle)
    ax.text(xy[0], xy[1], label, ha="center", va="center", fontsize=fontsize, zorder=3)
    return circle


def draw_box_state(
    ax,
    xy: tuple[float, float],
    label: str,
    *,
    width: float = 0.9,
    height: float = 0.45,
    facecolor: str = "white",
    edgecolor: str = BLACK,
    fontsize: float = 8,
) -> FancyBboxPatch:
    x, y = xy
    box = FancyBboxPatch(
        (x - width / 2, y - height / 2),
        width,
        height,
        boxstyle="round,pad=0.03",
        facecolor=facecolor,
        edgecolor=edgecolor,
        linewidth=1.1,
    )
    ax.add_patch(box)
    ax.text(x, y, label, ha="center", va="center", fontsize=fontsize, zorder=3)
    return box


def draw_place(
    ax,
    xy: tuple[float, float],
    label: str,
    tokens: int | str = 0,
    *,
    radius: float = 0.22,
) -> Circle:
    circle = Circle(xy, radius, facecolor="white", edgecolor=BLACK, linewidth=1.1)
    ax.add_patch(circle)
    ax.text(xy[0], xy[1] + 0.34, label, ha="center", va="center", fontsize=8)
    if tokens:
        token_text = str(tokens) if tokens != "omega" else r"$\omega$"
        ax.text(xy[0], xy[1], token_text, ha="center", va="center", fontsize=8)
    return circle


def draw_transition(
    ax,
    xy: tuple[float, float],
    label: str = "",
    *,
    width: float = 0.08,
    height: float = 0.42,
) -> Rectangle:
    x, y = xy
    rect = Rectangle(
        (x - width / 2, y - height / 2),
        width,
        height,
        facecolor=BLACK,
        edgecolor=BLACK,
        linewidth=0.8,
    )
    ax.add_patch(rect)
    if label:
        ax.text(x, y - 0.34, label, ha="center", va="center", fontsize=7)
    return rect


STATE_RADIUS = 0.28
TREE_BOX = (1.05, 0.38)
LTS_BOX = (1.6, 0.55)
PETRI_PLACE_RADIUS = 0.22
PETRI_TRANS_BOX = (0.08, 0.42)


def circle_anchor(
    center: tuple[float, float],
    other: tuple[float, float],
    radius: float,
    pad: float = 0.02,
) -> tuple[float, float]:
    cx, cy = center
    dx, dy = other[0] - cx, other[1] - cy
    norm = float(np.hypot(dx, dy))
    if norm == 0:
        return center
    scale = (radius + pad) / norm
    return (cx + dx * scale, cy + dy * scale)


def box_anchor(
    center: tuple[float, float],
    other: tuple[float, float],
    width: float,
    height: float,
    pad: float = 0.02,
) -> tuple[float, float]:
    cx, cy = center
    dx, dy = other[0] - cx, other[1] - cy
    if abs(dx) < 1e-12 and abs(dy) < 1e-12:
        return center
    hw = width / 2 + pad
    hh = height / 2 + pad
    if abs(dx) < 1e-12:
        scale = hh / abs(dy)
    elif abs(dy) < 1e-12:
        scale = hw / abs(dx)
    else:
        scale = min(hw / abs(dx), hh / abs(dy))
    return (cx + dx * scale, cy + dy * scale)


def _resolve_anchor(
    center: tuple[float, float],
    other: tuple[float, float],
    *,
    radius: float | None = None,
    box: tuple[float, float] | None = None,
) -> tuple[float, float]:
    if box is not None:
        return box_anchor(center, other, box[0], box[1])
    if radius is not None:
        return circle_anchor(center, other, radius)
    return center


def draw_arrow(
    ax,
    start: tuple[float, float],
    end: tuple[float, float],
    *,
    color: str = DARK,
    style: str = "-|>",
    curvature: float = 0.0,
    linewidth: float = 1.1,
    shrink: float = 0.28,
    connectionstyle: str | None = None,
    start_radius: float | None = None,
    end_radius: float | None = None,
    start_box: tuple[float, float] | None = None,
    end_box: tuple[float, float] | None = None,
    zorder: int = 1,
) -> FancyArrowPatch:
    if connectionstyle is None:
        connectionstyle = f"arc3,rad={curvature}"

    use_geometry = any(
        value is not None
        for value in (start_radius, end_radius, start_box, end_box)
    )
    if use_geometry:
        p0 = _resolve_anchor(start, end, radius=start_radius, box=start_box)
        p1 = _resolve_anchor(end, start, radius=end_radius, box=end_box)
        shrink_a, shrink_b = 0.0, 0.0
    else:
        p0, p1 = start, end
        shrink_a, shrink_b = shrink * 12, shrink * 12

    arrow = FancyArrowPatch(
        p0,
        p1,
        arrowstyle=style,
        mutation_scale=10,
        linewidth=linewidth,
        color=color,
        connectionstyle=connectionstyle,
        shrinkA=shrink_a,
        shrinkB=shrink_b,
        zorder=zorder,
    )
    ax.add_patch(arrow)
    return arrow


def draw_edge_label(
    ax,
    start: tuple[float, float],
    end: tuple[float, float],
    label: str,
    *,
    offset: tuple[float, float] = (0.0, 0.0),
    fontsize: float = 8,
    color: str = DARK,
) -> None:
    mid = (
        (start[0] + end[0]) / 2 + offset[0],
        (start[1] + end[1]) / 2 + offset[1],
    )
    ax.text(mid[0], mid[1], label, ha="center", va="center", fontsize=fontsize, color=color)


def _self_loop_rad(chord: float, bulge: float, outward: bool) -> float:
    magnitude = max(bulge / max(chord * 0.45, 0.12), 1.2)
    return -magnitude if outward else magnitude


def draw_self_loop(
    ax,
    center: tuple[float, float],
    label: str,
    *,
    radius: float | None = None,
    box: tuple[float, float] | None = None,
    direction: str = "top",
    spread: float = 0.55,
    loop_height: float | None = None,
    fontsize: float = 8,
    color: str = DARK,
    zorder: int = 1,
) -> None:
    """Draw a transition that leaves and re-enters the same node along its border."""
    x, y = center
    pad = 0.02

    if box is not None:
        width, height = box
        hw, hh = width / 2, height / 2
        if direction == "top":
            start = box_anchor(center, (x - hw, y + hh + 1.0), width, height, pad=pad)
            end = box_anchor(center, (x + hw, y + hh + 1.0), width, height, pad=pad)
            bulge = loop_height if loop_height is not None else max(hh * 1.5, 0.4)
            label_pos = (x, max(start[1], end[1]) + bulge * 0.55)
            chord = float(np.hypot(end[0] - start[0], end[1] - start[1]))
            rad = _self_loop_rad(chord, bulge, outward=True)
        elif direction == "right":
            start = box_anchor(center, (x + hw + 1.0, y - hh), width, height, pad=pad)
            end = box_anchor(center, (x + hw + 1.0, y + hh), width, height, pad=pad)
            bulge = loop_height if loop_height is not None else max(hw * 1.2, 0.35)
            label_pos = (max(start[0], end[0]) + bulge * 0.55, y)
            chord = float(np.hypot(end[0] - start[0], end[1] - start[1]))
            rad = _self_loop_rad(chord, bulge, outward=False)
        else:
            raise ValueError(f"unknown self-loop direction: {direction}")
    else:
        r = radius if radius is not None else STATE_RADIUS
        if direction == "top":
            theta_start = np.pi / 2 + spread
            theta_end = np.pi / 2 - spread
            start = circle_anchor(
                center,
                (x + np.cos(theta_start), y + np.sin(theta_start)),
                r,
                pad=pad,
            )
            end = circle_anchor(
                center,
                (x + np.cos(theta_end), y + np.sin(theta_end)),
                r,
                pad=pad,
            )
            bulge = loop_height if loop_height is not None else r * 1.1
            label_pos = (x, y + r + pad + bulge * 0.65)
            chord = float(np.hypot(end[0] - start[0], end[1] - start[1]))
            rad = _self_loop_rad(chord, bulge, outward=True)
        elif direction == "right":
            theta_start = -spread
            theta_end = spread
            start = circle_anchor(
                center,
                (x + np.cos(theta_start), y + np.sin(theta_start)),
                r,
                pad=pad,
            )
            end = circle_anchor(
                center,
                (x + np.cos(theta_end), y + np.sin(theta_end)),
                r,
                pad=pad,
            )
            bulge = loop_height if loop_height is not None else r * 1.1
            label_pos = (x + r + pad + bulge * 0.65, y)
            chord = float(np.hypot(end[0] - start[0], end[1] - start[1]))
            rad = _self_loop_rad(chord, bulge, outward=False)
        else:
            raise ValueError(f"unknown self-loop direction: {direction}")

    arc = FancyArrowPatch(
        start,
        end,
        arrowstyle="-|>",
        mutation_scale=10,
        linewidth=1.0,
        color=color,
        connectionstyle=f"arc3,rad={rad}",
        shrinkA=0,
        shrinkB=0,
        zorder=zorder,
    )
    ax.add_patch(arc)
    ax.text(
        label_pos[0],
        label_pos[1],
        label,
        ha="center",
        va="center",
        fontsize=fontsize,
        color=color,
        zorder=3,
    )


def draw_petri_arc(
    ax,
    start: tuple[float, float],
    end: tuple[float, float],
    *,
    label: str = "",
    from_place: bool = True,
    to_place: bool = False,
) -> None:
    start_radius = PETRI_PLACE_RADIUS if from_place else None
    start_box = None if from_place else PETRI_TRANS_BOX
    end_radius = PETRI_PLACE_RADIUS if to_place else None
    end_box = None if to_place else PETRI_TRANS_BOX
    draw_arrow(
        ax,
        start,
        end,
        start_radius=start_radius,
        start_box=start_box,
        end_radius=end_radius,
        end_box=end_box,
        linewidth=0.9,
    )
    if label:
        mid = ((start[0] + end[0]) / 2, (start[1] + end[1]) / 2)
        ax.text(mid[0], mid[1], label, ha="center", va="center", fontsize=7, color=MID, zorder=3)


def draw_tree_node(
    ax,
    xy: tuple[float, float],
    label: str,
    *,
    facecolor: str = "white",
    fontsize: float = 8,
) -> None:
    draw_box_state(ax, xy, label, width=1.05, height=0.38, facecolor=facecolor, fontsize=fontsize)


def connect_tree(
    ax,
    parent: tuple[float, float],
    child: tuple[float, float],
    *,
    label: str = "",
    label_offset: tuple[float, float] = (0.0, 0.05),
    box_size: tuple[float, float] = TREE_BOX,
) -> None:
    draw_arrow(
        ax,
        parent,
        child,
        start_box=box_size,
        end_box=box_size,
    )
    if label:
        mid = (
            (parent[0] + child[0]) / 2 + label_offset[0],
            (parent[1] + child[1]) / 2 + label_offset[1],
        )
        ax.text(mid[0], mid[1], label, ha="center", va="center", fontsize=7, color=MID)
