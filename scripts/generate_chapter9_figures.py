#!/usr/bin/env python3
"""Generate figures for Chapter 9 (Petri nets and concurrency)."""

from collections import deque

from figure_common import (
    DARK,
    LIGHT,
    MID,
    RED,
    apply_style,
    chapter_out_dir,
    connect_tree,
    draw_arrow,
    draw_box_state,
    draw_petri_arc,
    draw_place,
    draw_state,
    draw_transition,
    draw_tree_node,
    new_diagram_figure,
    save_figure,
)

import matplotlib.pyplot as plt

OUT = chapter_out_dir(9)


def plot_rewriting_reachability_tree() -> None:
    fig, ax = new_diagram_figure(8.6, 4.4)

    root = (0.0, 3.5)
    left = (-2.2, 2.2)
    right = (2.2, 2.2)
    left_child = (-3.0, 0.8)
    right_child = (3.0, 0.8)
    leaf = (-1.2, 0.8)

    draw_tree_node(ax, root, r"$3a,2b,3c$")
    draw_tree_node(ax, left, r"$2a,1b,4c$", facecolor="#eef6ff")
    draw_tree_node(ax, right, r"$4a,4b,2c$", facecolor="#fff4e6")
    draw_tree_node(ax, left_child, r"$1a,5c$", facecolor="#eef6ff")
    draw_tree_node(ax, right_child, r"$5a,5b,1c$", facecolor="#fff4e6")
    draw_tree_node(ax, leaf, r"$2a,3b,3c$", facecolor="#f5f5f5")

    connect_tree(ax, root, left, label=r"$ab \to c$")
    connect_tree(ax, root, right, label=r"$c \to ab$")
    connect_tree(ax, left, left_child, label=r"$ab \to c$")
    connect_tree(ax, right, right_child, label=r"$c \to ab$")
    connect_tree(ax, root, leaf, label=r"(alt. order)", label_offset=(0.55, 0.0))

    ax.text(
        0.0,
        -0.2,
        "Interleaving: both rules enabled at the root; branches differ by firing order",
        ha="center",
        va="center",
        fontsize=8,
        color=MID,
    )
    ax.set_xlim(-4.2, 4.2)
    ax.set_ylim(-0.6, 4.0)
    ax.set_title("Rewriting reachability tree", fontsize=10, pad=8)
    save_figure(fig, OUT, "rewriting-reachability-tree.pdf")


def plot_producer_consumer_mutex() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(10.4, 3.8))
    for ax in axes:
        ax.set_aspect("equal")
        ax.axis("off")
        ax.grid(False)

    ax = axes[0]
    places = {
        "idleP": (-1.6, 1.0),
        "prodP": (-1.6, 0.0),
        "buffer": (0.0, 0.5),
        "product": (0.0, -0.6),
        "waitC": (1.6, 1.0),
        "consC": (1.6, 0.0),
    }
    transitions = {
        "start": (-1.6, 0.55),
        "deposit": (0.0, 1.0),
        "consume": (1.6, 0.55),
    }
    draw_place(ax, places["idleP"], "idleP", 2)
    draw_place(ax, places["prodP"], "prodP", 0)
    draw_place(ax, places["buffer"], "slots", 5)
    draw_place(ax, places["product"], "product", 0)
    draw_place(ax, places["waitC"], "waitC", 1)
    draw_place(ax, places["consC"], "consC", 0)

    draw_transition(ax, transitions["start"], "produce")
    draw_transition(ax, transitions["deposit"], "deposit")
    draw_transition(ax, transitions["consume"], "consume")

    draw_petri_arc(ax, places["idleP"], transitions["start"])
    draw_petri_arc(ax, transitions["start"], places["prodP"], from_place=False, to_place=True)
    draw_petri_arc(ax, places["prodP"], transitions["deposit"])
    draw_petri_arc(ax, transitions["deposit"], places["product"], from_place=False, to_place=True)
    draw_petri_arc(
        ax,
        transitions["deposit"],
        places["buffer"],
        label="1",
        from_place=False,
        to_place=True,
    )
    draw_petri_arc(ax, places["product"], transitions["consume"])
    draw_petri_arc(ax, places["waitC"], transitions["consume"])
    draw_petri_arc(ax, transitions["consume"], places["consC"], from_place=False, to_place=True)
    draw_petri_arc(
        ax,
        transitions["consume"],
        places["buffer"],
        label="1",
        from_place=False,
        to_place=True,
    )
    draw_petri_arc(ax, transitions["consume"], places["waitC"], from_place=False, to_place=True)

    ax.set_xlim(-2.4, 2.4)
    ax.set_ylim(-1.2, 1.6)
    ax.set_title("Producer-consumer (capacity 5)", fontsize=9)

    ax = axes[1]
    proc1 = [(-1.5, 1.0), (-1.5, 0.0), (-1.5, -1.0)]
    proc2 = [(1.5, 1.0), (1.5, 0.0), (1.5, -1.0)]
    labels1 = ["I1", "R1", "W1"]
    labels2 = ["I2", "R2", "W2"]
    marks1 = [1, 0, 0]
    marks2 = [1, 0, 0]

    for pos, label, mark in zip(proc1, labels1, marks1):
        draw_place(ax, pos, label, mark)
    for pos, label, mark in zip(proc2, labels2, marks2):
        draw_place(ax, pos, label, mark)
    draw_place(ax, (0.0, -0.1), "M", 1)

    t1 = [(-1.5, 0.55), (-1.5, -0.45)]
    t2 = [(1.5, 0.55), (1.5, -0.45)]
    draw_transition(ax, t1[0], "read1")
    draw_transition(ax, t1[1], "write1")
    draw_transition(ax, t2[0], "read2")
    draw_transition(ax, t2[1], "write2")

    draw_petri_arc(ax, proc1[0], t1[0])
    draw_petri_arc(ax, t1[0], proc1[1], from_place=False, to_place=True)
    draw_petri_arc(ax, proc1[1], t1[1])
    draw_petri_arc(ax, (0.0, -0.1), t1[1])
    draw_petri_arc(ax, t1[1], proc1[2], from_place=False, to_place=True)
    draw_petri_arc(ax, t1[1], (0.0, -0.1), from_place=False, to_place=True)

    draw_petri_arc(ax, proc2[0], t2[0])
    draw_petri_arc(ax, t2[0], proc2[1], from_place=False, to_place=True)
    draw_petri_arc(ax, proc2[1], t2[1])
    draw_petri_arc(ax, (0.0, -0.1), t2[1])
    draw_petri_arc(ax, t2[1], proc2[2], from_place=False, to_place=True)
    draw_petri_arc(ax, t2[1], (0.0, -0.1), from_place=False, to_place=True)

    ax.set_xlim(-2.2, 2.2)
    ax.set_ylim(-1.5, 1.5)
    ax.set_title("Database mutex (shared M)", fontsize=9)

    fig.tight_layout()
    save_figure(fig, OUT, "producer-consumer-mutex.pdf")


def mutex_successors(state: tuple[str, str, int]) -> list[tuple[tuple[str, str, int], str]]:
    s1, s2, m = state
    moves: list[tuple[tuple[str, str, int], str]] = []

    if s1 == "I":
        moves.append((("R", s2, m), "P1: I→R"))
    if s1 == "R":
        moves.append((("I", s2, m), "P1: R→I"))
    if s2 == "I":
        moves.append(((s1, "R", m), "P2: I→R"))
    if s2 == "R":
        moves.append(((s1, "I", m), "P2: R→I"))
    if s1 == "R" and m == 1:
        moves.append((("W", s2, 0), "P1: write"))
    if s2 == "R" and m == 1:
        moves.append(((s1, "W", 0), "P2: write"))
    if s1 == "W":
        moves.append((("I", s2, 1), "P1: release"))
    if s2 == "W":
        moves.append(((s1, "I", 1), "P2: release"))

    return moves


def state_label(state: tuple[str, str, int]) -> str:
    s1, s2, m = state
    return f"({s1},{s2},M={m})"


def plot_mutex_reachability_graph() -> None:
    start = ("I", "I", 1)
    seen = {start}
    queue = deque([start])
    edges: list[tuple[tuple[str, str, int], tuple[str, str, int]]] = []

    while queue:
        state = queue.popleft()
        for nxt, _ in mutex_successors(state):
            edges.append((state, nxt))
            if nxt not in seen:
                seen.add(nxt)
                queue.append(nxt)

    forbidden = {s for s in seen if s[0] == "W" and s[1] == "W"}

    fig, ax = new_diagram_figure(7.6, 5.0)
    layers = {
        ("I", "I", 1): (0.0, 4.0),
        ("R", "I", 1): (-1.6, 3.0),
        ("I", "R", 1): (1.6, 3.0),
        ("R", "R", 1): (0.0, 2.0),
        ("W", "I", 0): (-2.2, 1.0),
        ("I", "W", 0): (2.2, 1.0),
        ("W", "R", 0): (-1.0, 0.0),
        ("R", "W", 0): (1.0, 0.0),
        ("I", "I", 0): (0.0, -1.0),
    }

    for state, pos in layers.items():
        if state not in seen:
            continue
        color = "#fdecea" if state in forbidden else "white"
        draw_state(ax, pos, state_label(state), radius=0.42, facecolor=color, fontsize=7)

    for src, dst in edges:
        if src in layers and dst in layers:
            draw_arrow(
                ax,
                layers[src],
                layers[dst],
                start_radius=0.42,
                end_radius=0.42,
                linewidth=0.8,
            )

    ax.text(
        0.0,
        -1.9,
        "No marking with simultaneous writes in W1 and W2",
        ha="center",
        va="center",
        fontsize=8,
        color=RED,
    )
    ax.set_xlim(-3.0, 3.0)
    ax.set_ylim(-2.3, 4.7)
    ax.set_title("Mutex reachability graph", fontsize=10, pad=8)
    save_figure(fig, OUT, "mutex-reachability-graph.pdf")


def plot_karp_miller_omega() -> None:
    fig, ax = new_diagram_figure(7.4, 4.2)

    nodes = {
        "(0,0,0)": (0.0, 3.2),
        "(1,0,0)": (-1.4, 2.2),
        "(1,1,0)": (1.4, 2.2),
        "(2,0,0)": (-2.4, 1.1),
        "(ω,0,0)": (0.0, 1.1),
        "(ω,1,0)": (2.0, 1.1),
        "(ω,0,1)": (2.0, 0.0),
    }

    for label, pos in nodes.items():
        face = "#fff4e6" if "ω" in label else "white"
        draw_tree_node(ax, pos, label, facecolor=face, fontsize=8)

    edges = [
        ("(0,0,0)", "(1,0,0)", "spawn"),
        ("(1,0,0)", "(1,1,0)", "mutex"),
        ("(1,0,0)", "(2,0,0)", "spawn"),
        ("(2,0,0)", "(ω,0,0)", "cover"),
        ("(ω,0,0)", "(ω,1,0)", "mutex"),
        ("(ω,1,0)", "(ω,0,1)", "release"),
    ]
    for src, dst, label in edges:
        connect_tree(ax, nodes[src], nodes[dst], label=label)

    ax.text(
        -2.8,
        0.0,
        r"$P_1$ grows without bound $\Rightarrow \omega$",
        ha="left",
        va="center",
        fontsize=8,
        color=DARK,
    )
    ax.text(
        0.0,
        -0.7,
        "Spawner/mutex fragment: P2 and P3 stay in {0,1}",
        ha="center",
        va="center",
        fontsize=8,
        color=MID,
    )
    ax.set_xlim(-3.4, 3.2)
    ax.set_ylim(-1.0, 3.8)
    ax.set_title("Karp-Miller tree with ω", fontsize=10, pad=8)
    save_figure(fig, OUT, "karp-miller-omega.pdf")


def main() -> None:
    apply_style()
    plot_rewriting_reachability_tree()
    plot_producer_consumer_mutex()
    plot_mutex_reachability_graph()
    plot_karp_miller_omega()


if __name__ == "__main__":
    main()
