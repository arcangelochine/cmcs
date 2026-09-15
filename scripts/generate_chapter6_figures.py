#!/usr/bin/env python3
"""Generate figures for Chapter 6 (transition systems) with Graphviz."""

from graphviz_common import DotGraph

CHAPTER = 6


def plot_coffee_machine_lts() -> None:
    graph = DotGraph(
        title="Coffee machine LTS composition",
        rankdir="LR",
        compound=True,
        nodesep=0.8,
        ranksep=1.4,
        splines="true",
    )

    def success_panel(panel: DotGraph) -> None:
        panel.node("s0", "(ready, ready)", highlight=True)
        panel.node("s1", "(credit1, is1)")
        panel.node("s2", "(credit2, is2)")
        panel.node("s3", "(coffee, drink)")
        panel.node("s4", "(ready, drink)")
        panel.edge("s0", "s1", "insertCoin", minlen=2)
        panel.edge("s1", "s2", "insertCoin", minlen=2)
        panel.edge("s2", "s3", "pressButton", minlen=2)
        panel.edge("s3", "s4", "τ", style="dashed", minlen=2)

    def deadlock_panel(panel: DotGraph) -> None:
        panel.node("d0", "(ready, ready)")
        panel.node("d1", "(credit1, is1)", deadlock=True)
        panel.edge("d0", "d1", "insertCoin", minlen=3)
        panel.edge("d1", "d1", "pressButton?", minlen=2)
        panel.raw(
            'deadlock_note [shape=plaintext, label="no enabled transitions", '
            'fontsize=10, color="#333333", margin="0.25,0.10"];'
        )
        panel.raw("d1 -> deadlock_note [style=invis, weight=0];")

    graph.subgraph(
        "cluster_success",
        "Correct protocol",
        nodesep=0.9,
        ranksep=1.8,
        build=success_panel,
    )
    graph.subgraph(
        "cluster_deadlock",
        "Deadlock after coin + button",
        nodesep=1.1,
        ranksep=1.6,
        build=deadlock_panel,
    )
    graph.edge(
        "s4",
        "d0",
        style="invis",
        weight=0,
        minlen=4,
        ltail="cluster_success",
        lhead="cluster_deadlock",
    )
    graph.render(CHAPTER, "coffee-machine-lts.pdf")


def plot_microwave_lts() -> None:
    graph = DotGraph(
        title="Microwave LTS with error state",
        rankdir="LR",
        nodesep=0.7,
        ranksep=1.1,
    )
    graph.node("init", "initial\n(door open)", highlight=True, width=1.8)
    graph.node("closed", "door closed", width=1.6)
    graph.node("cooking", "cooking", width=1.4)
    graph.node("error", "error", width=1.3)

    graph.edge("init", "closed", "close")
    graph.edge("closed", "cooking", "start")
    graph.edge("init", "error", "start", weight=0.4)
    graph.edge("cooking", "init", "open", style="dashed", weight=0.2)
    graph.raw("{ rank=same; closed; cooking; }")
    graph.render(CHAPTER, "microwave-lts.pdf")


def plot_server_queue_graph() -> None:
    graph = DotGraph(
        title="Server queue reachable subgraph (N=2)",
        rankdir="LR",
        nodesep=1.0,
        ranksep=2.0,
        splines="true",
    )

    graph.node("q00", "(0, false)", highlight=True)
    graph.node("q01", "(0, true)")
    graph.node("q11", "(1, true)")
    graph.node("q21", "(2, true)")

    graph.edge("q00", "q01", "arrival", minlen=2)
    graph.edge("q01", "q11", "enqueue", minlen=2)
    graph.edge("q11", "q21", "enqueue", minlen=2)

    graph.edge(
        "q01",
        "q00",
        "service",
        constraint=False,
        weight=0,
        minlen=2,
        tailport="n",
        headport="n",
    )
    graph.edge(
        "q11",
        "q01",
        "service",
        constraint=False,
        weight=0,
        minlen=2,
        tailport="n",
        headport="n",
    )
    graph.edge(
        "q21",
        "q11",
        "service",
        constraint=False,
        weight=0,
        minlen=2,
        tailport="n",
        headport="n",
    )

    graph.render(CHAPTER, "server-queue-graph.pdf")


def main() -> None:
    plot_coffee_machine_lts()
    plot_microwave_lts()
    plot_server_queue_graph()


if __name__ == "__main__":
    main()
