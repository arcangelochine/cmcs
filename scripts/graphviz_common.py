"""Shared Graphviz helpers for CMCS transition-system figures."""

from __future__ import annotations

import subprocess
from collections.abc import Callable
from pathlib import Path

from figure_common import out_dir

BLACK = "#000000"
DARK = "#333333"
MID = "#666666"
DEADLOCK_FILL = "#f5f5f5"


def _quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _attrs(items: dict[str, str | float | int | bool]) -> str:
    parts: list[str] = []
    for key, value in items.items():
        if isinstance(value, bool):
            rendered = "true" if value else "false"
        elif isinstance(value, (int, float)):
            rendered = str(value)
        else:
            rendered = _quote(str(value))
        parts.append(f"{key}={rendered}")
    return ", ".join(parts)


class DotGraph:
    """Minimal DOT builder for book figures."""

    def __init__(
        self,
        *,
        title: str = "",
        rankdir: str = "LR",
        compound: bool = False,
        bgcolor: str = "white",
        fontname: str = "Times-Roman",
        fontsize: float = 11,
        nodesep: float = 0.55,
        ranksep: float = 0.85,
        splines: str = "true",
    ) -> None:
        self.title = title
        self.rankdir = rankdir
        self.compound = compound
        self.bgcolor = bgcolor
        self.fontname = fontname
        self.fontsize = fontsize
        self.nodesep = nodesep
        self.ranksep = ranksep
        self.splines = splines
        self.body: list[str] = []

    def _graph_attrs(self, **overrides: str | float | int | bool) -> str:
        attrs = {
            "bgcolor": self.bgcolor,
            "fontname": self.fontname,
            "fontsize": self.fontsize,
            "rankdir": self.rankdir,
            "nodesep": self.nodesep,
            "ranksep": self.ranksep,
            "splines": self.splines,
            "pad": 0.35,
            "dpi": 300,
        }
        if self.title:
            attrs["label"] = self.title
            attrs["labelloc"] = "t"
            attrs["fontsize"] = self.fontsize + 1
        if self.compound:
            attrs["compound"] = True
        attrs.update(overrides)
        return _attrs(attrs)

    def _defaults_lines(self, indent: str = "  ") -> list[str]:
        return [
            indent
            + "node ["
            + _attrs(
                {
                    "shape": "box",
                    "style": "rounded,filled",
                    "fillcolor": "white",
                    "color": MID,
                    "fontname": self.fontname,
                    "fontsize": self.fontsize,
                    "margin": "0.20,0.12",
                    "penwidth": 1.1,
                }
            )
            + "];",
            indent
            + "edge ["
            + _attrs(
                {
                    "fontname": self.fontname,
                    "fontsize": self.fontsize - 1,
                    "color": BLACK,
                    "arrowsize": 0.75,
                    "penwidth": 1.1,
                }
            )
            + "];",
        ]

    def node(
        self,
        node_id: str,
        label: str,
        *,
        highlight: bool = False,
        deadlock: bool = False,
        width: float | None = None,
    ) -> None:
        attrs: dict[str, str | float | int | bool] = {"label": label}
        if highlight:
            attrs["color"] = DARK
            attrs["penwidth"] = 1.5
        if deadlock:
            attrs["fillcolor"] = DEADLOCK_FILL
            attrs["color"] = BLACK
            attrs["penwidth"] = 1.4
        if width is not None:
            attrs["width"] = width
            attrs["fixedsize"] = "true"
        self.body.append(f"  {node_id} [{_attrs(attrs)}];")

    def edge(
        self,
        start: str,
        end: str,
        label: str = "",
        *,
        style: str = "solid",
        constraint: bool = True,
        weight: float | None = None,
        minlen: int | None = None,
        tailport: str | None = None,
        headport: str | None = None,
        ltail: str | None = None,
        lhead: str | None = None,
    ) -> None:
        attrs: dict[str, str | float | int | bool] = {"constraint": constraint}
        if label:
            attrs["label"] = label
        if style != "solid":
            attrs["style"] = style
        if weight is not None:
            attrs["weight"] = weight
        if minlen is not None:
            attrs["minlen"] = minlen
        if tailport is not None:
            attrs["tailport"] = tailport
        if headport is not None:
            attrs["headport"] = headport
        if ltail is not None:
            attrs["ltail"] = ltail
        if lhead is not None:
            attrs["lhead"] = lhead
        self.body.append(f"  {start} -> {end} [{_attrs(attrs)}];")

    def raw(self, line: str) -> None:
        self.body.append(f"  {line}")

    def subgraph(
        self,
        cluster_id: str,
        title: str,
        *,
        rankdir: str | None = None,
        nodesep: float | None = None,
        ranksep: float | None = None,
        build: Callable[[DotGraph], None] | None = None,
    ) -> DotGraph:
        child = DotGraph(
            title="",
            rankdir=rankdir or self.rankdir,
            fontname=self.fontname,
            fontsize=self.fontsize,
            nodesep=nodesep if nodesep is not None else self.nodesep,
            ranksep=ranksep if ranksep is not None else self.ranksep,
        )
        if build is not None:
            build(child)
        cluster_attrs = _attrs(
            {
                "label": title,
                "style": "rounded",
                "color": "#cccccc",
                "fontname": self.fontname,
                "fontsize": self.fontsize,
                "labeljust": "l",
            }
        )
        graph_attrs = child._graph_attrs()
        lines = [
            f"  subgraph {cluster_id} {{",
            f"    graph [{cluster_attrs}];",
            f"    graph [{graph_attrs}];",
        ]
        lines.extend(child._defaults_lines(indent="    "))
        lines.extend("    " + line for line in child.body)
        lines.append("  }")
        self.body.extend(lines)
        return child

    def source(self) -> str:
        lines = ["digraph G {", f"  graph [{self._graph_attrs()}];"]
        lines.extend(self._defaults_lines())
        lines.extend(self.body)
        lines.append("}")
        return "\n".join(lines)

    def render(self, chapter: int | str, name: str) -> Path:
        directory = out_dir(chapter)
        directory.mkdir(parents=True, exist_ok=True)
        path = directory / name
        subprocess.run(
            ["dot", "-Tpdf", "-o", str(path)],
            input=self.source().encode(),
            check=True,
        )
        print(f"wrote {path}")
        return path
