#!/usr/bin/env python3
"""Generate figures for Chapter 7 (Markov chains)."""

import numpy as np

from figure_common import (
    BLACK,
    DARK,
    LIGHT,
    MID,
    apply_style,
    chapter_out_dir,
    connect_tree,
    draw_arrow,
    draw_box_state,
    draw_edge_label,
    draw_self_loop,
    draw_state,
    draw_tree_node,
    new_diagram_figure,
    save_figure,
)


OUT = chapter_out_dir(7)


def plot_light_bulb_dtmc() -> None:
    fig, ax = new_diagram_figure(6.4, 3.2)

    off = (-1.6, 0.0)
    on = (0.0, 0.55)
    broken = (1.6, 0.0)

    draw_state(ax, off, "off")
    draw_state(ax, on, "on")
    draw_state(ax, broken, "broken", facecolor="#f8f8f8")

    draw_arrow(ax, off, on, start_radius=0.28, end_radius=0.28)
    draw_edge_label(ax, off, on, "1.0", offset=(0.0, 0.12))

    draw_arrow(ax, on, off, curvature=0.25, start_radius=0.28, end_radius=0.28)
    draw_edge_label(ax, on, off, "0.99", offset=(-0.35, 0.05))

    draw_arrow(ax, on, broken, curvature=-0.2, start_radius=0.28, end_radius=0.28)
    draw_edge_label(ax, on, broken, "0.01", offset=(0.0, 0.12))

    draw_self_loop(ax, broken, "1.0", direction="top")

    ax.set_xlim(-2.4, 2.4)
    ax.set_ylim(-0.7, 1.5)
    ax.set_title("Light-bulb DTMC", fontsize=10, pad=8)
    save_figure(fig, OUT, "light-bulb-dtmc.pdf")


def plot_dice_coin_tree() -> None:
    fig, ax = new_diagram_figure(8.8, 4.6)

    root = (0.0, 3.6)
    level1 = [(-1.8, 2.5), (1.8, 2.5)]
    level2 = [(-2.8, 1.4), (-0.8, 1.4), (0.8, 1.4), (2.8, 1.4)]

    draw_tree_node(ax, root, "start")
    for pos, label in zip(level1, ["H", "T"]):
        draw_tree_node(ax, pos, label, facecolor="#fafafa")
        connect_tree(ax, root, pos, label="0.5")

    l2_labels = ["HH", "HT", "TH", "TT"]
    for parent, child, label in zip(level1 * 2, level2, l2_labels):
        connect_tree(ax, parent, child, label="0.5")

    outcomes = {
        "HHH": 1,
        "HHT": 2,
        "HTH": 3,
        "HTT": 4,
        "THH": 5,
        "THT": 6,
        "TTH": "loop",
        "TTT": "loop",
    }

    parent_map = {
        "HHH": level2[0],
        "HHT": level2[0],
        "HTH": level2[1],
        "HTT": level2[1],
        "THH": level2[2],
        "THT": level2[2],
        "TTH": level2[3],
        "TTT": level2[3],
    }

    x_positions = np.linspace(-3.3, 3.3, 8)
    for idx, (path, outcome) in enumerate(outcomes.items()):
        pos = (float(x_positions[idx]), 0.2)
        if outcome == "loop":
            label = f"{path}\n(loop)"
            face = "#f5f5f5"
        else:
            label = f"{path}\nface {outcome}"
            face = "#fff8e6"
        draw_tree_node(ax, pos, label, facecolor=face, fontsize=7)
        connect_tree(ax, parent_map[path], pos, label="0.5")

    ax.text(
        0.0,
        -0.55,
        "Three fair coin flips; paths TTH and TTT loop back to start",
        ha="center",
        va="center",
        fontsize=8,
        color=MID,
    )
    ax.set_xlim(-4.2, 4.2)
    ax.set_ylim(-0.8, 4.2)
    ax.set_title("Dice from coin flips (DTMC tree)", fontsize=10, pad=8)
    save_figure(fig, OUT, "dice-coin-tree.pdf")


def plot_ctmc_race() -> None:
    fig, ax = new_diagram_figure(7.0, 3.4)

    s0 = (0.0, 0.0)
    s1 = (-1.8, -0.9)
    s2 = (1.8, -0.9)

    draw_state(ax, s0, r"$s$", radius=0.32)
    draw_state(ax, s1, r"$s_1$", radius=0.3)
    draw_state(ax, s2, r"$s_2$", radius=0.3)

    draw_arrow(ax, s0, s1, curvature=0.12, start_radius=0.32, end_radius=0.3)
    draw_edge_label(ax, s0, s1, r"rate $2$", offset=(-0.15, 0.0))

    draw_arrow(ax, s0, s2, curvature=-0.12, start_radius=0.32, end_radius=0.3)
    draw_edge_label(ax, s0, s2, r"rate $3$", offset=(0.15, 0.0))

    ax.text(
        0.0,
        0.95,
        r"exit rate $q(s)=5$, mean holding time $1/q(s)=0.2$",
        ha="center",
        va="center",
        fontsize=9,
    )
    ax.text(
        0.0,
        -1.75,
        r"successor probabilities: $P(s_1)=2/5$, $P(s_2)=3/5$",
        ha="center",
        va="center",
        fontsize=9,
        color=DARK,
    )

    ax.annotate(
        "",
        xy=(0.55, 0.55),
        xytext=(0.9, 0.55),
        arrowprops=dict(arrowstyle="-|>", color=LIGHT, lw=1.0),
    )
    ax.text(1.05, 0.55, "race winner", ha="left", va="center", fontsize=8, color=MID)

    ax.set_xlim(-2.6, 2.6)
    ax.set_ylim(-2.1, 1.2)
    ax.set_title("CTMC race semantics", fontsize=10, pad=8)
    save_figure(fig, OUT, "ctmc-race.pdf")


def main() -> None:
    apply_style()
    plot_light_bulb_dtmc()
    plot_dice_coin_tree()
    plot_ctmc_race()


if __name__ == "__main__":
    main()
