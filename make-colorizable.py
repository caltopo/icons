#!/usr/bin/env python3
import sys
from pathlib import Path
from xml.etree import ElementTree as ET

SVG_NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG_NS)

SHAPES = {"path", "circle", "rect", "ellipse", "polygon", "polyline", "line"}

def parse_style(style_str: str):
    d = {}
    for item in (style_str or "").split(";"):
        if not item.strip() or ":" not in item:
            continue
        k, v = item.split(":", 1)
        d[k.strip().lower()] = v.strip()
    return d

def style_to_string(d: dict):
    return ";".join(f"{k}:{v}" for k, v in d.items())

def recolor(tree: ET.ElementTree) -> ET.ElementTree:
    root = tree.getroot()

    # Fallback: set root default fill to currentColor so any untouched shapes inherit it.
    # (Shapes with explicit fill="none" or a stroke remain respected.)
    if root.get("fill") is None:
        root.set("fill", "currentColor")

    for el in root.iter():
        local = el.tag.split("}", 1)[1] if "}" in el.tag else el.tag
        if local not in SHAPES:
            continue

        style_map = parse_style(el.get("style"))
        cur_fill   = el.get("fill")   if el.get("fill")   is not None else style_map.get("fill")
        cur_stroke = el.get("stroke") if el.get("stroke") is not None else style_map.get("stroke")

        stroke_only = (cur_fill == "none") or (cur_fill is None and cur_stroke not in (None, "none"))

        if stroke_only:
            # Stroke-only icon: let fill be none and color the stroke
            el.set("fill", "none")
            el.set("stroke", "currentColor")
            if "fill" in style_map:   style_map.pop("fill")
            if "stroke" in style_map and cur_stroke != "none":
                style_map["stroke"] = "currentColor"
        else:
            # Filled icon: color the fill; if a stroke was present, color it too
            el.set("fill", "currentColor")
            if cur_stroke not in (None, "none"):
                el.set("stroke", "currentColor")
            if "fill" in style_map:   style_map["fill"] = "currentColor"
            if "stroke" in style_map and cur_stroke not in (None, "none"):
                style_map["stroke"] = "currentColor"

        # Clean up style attribute
        if el.get("style") is not None:
            if style_map:
                el.set("style", style_to_string(style_map))
            else:
                el.attrib.pop("style", None)

    return tree

def main():
    if len(sys.argv) != 2:
        print("Usage: python recolor_svg.py <file.svg>")
        sys.exit(1)

    in_path = Path(sys.argv[1])
    if not in_path.exists() or in_path.suffix.lower() != ".svg":
        print("Error: input must be an existing .svg file")
        sys.exit(1)

    out_path = in_path.with_name(in_path.name + ".NEW")  # e.g., water.svg.NEW

    tree = ET.parse(str(in_path))
    recolor(tree).write(str(out_path), encoding="utf-8", xml_declaration=True)
    print(f"Converted: {out_path}")

if __name__ == "__main__":
    main()

