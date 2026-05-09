#!/usr/bin/env python3
"""Replace <text> elements in a splash SVG with hb-view-outlined glyph paths.

rsvg-convert + system pango won't drive variable-font axes, so when
splash-{light,dark}.svg references "Newsreader Italic" at weight 700 the
launch PNG ends up rendered in whatever Core Text resolves Newsreader to
(usually Charter at the default axis), not the bundled VF at axis 700.

This script side-steps the renderer entirely: it shells out to hb-view
with the bundled VF and an explicit wght variation, takes hb-view's SVG
output (which is glyph paths, no text), and splices it into the source
splash SVG in place of each <text>. The resulting SVG renders identically
under any tool — fontconfig, Core Text, headless servers — because it
contains no text at all.

Args: input.svg output.svg
"""

import re
import subprocess
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent.parent
NEWSREADER = ROOT / "assets/fonts/Newsreader-Italic-VF.ttf"
INTER = ROOT / "assets/fonts/Inter-VF.ttf"

SVG_NS = "http://www.w3.org/2000/svg"
XLINK_NS = "http://www.w3.org/1999/xlink"
ET.register_namespace("", SVG_NS)
ET.register_namespace("xlink", XLINK_NS)

# (text content) → (.ttf path, variations, hb-view font-size)
# font-size matches the splash SVG's font-size attribute on each <text>,
# so paths come back at the right glyph dimensions and we only need to
# translate them — no rescale.
OUTLINE_RULES = {
    "Readline":           (NEWSREADER, "wght=700", 80),
    "Focus. Read. Grow.": (INTER,      "wght=600", 24),
}


def hb_render(font: Path, variations: str, font_size: int, text: str, id_prefix: str) -> ET.Element:
    out = subprocess.check_output(
        [
            "hb-view",
            f"--font-file={font}",
            f"--variations={variations}",
            f"--font-size={font_size}",
            "--output-format=svg",
            f"--text={text}",
        ],
        text=True,
    )
    # Each hb-view call emits ids `glyph-0-0`, `glyph-0-1`, …. When two
    # outlined runs land in the same SVG, the second run's <use> elements
    # collide with the first run's <defs>. Prefix everything per call.
    out = re.sub(r'id="(glyph-[^"]+)"', rf'id="{id_prefix}\1"', out)
    out = re.sub(r'xlink:href="#(glyph-[^"]+)"', rf'xlink:href="#{id_prefix}\1"', out)
    return ET.fromstring(out)


def apply_letter_spacing(use_elements: list[ET.Element], spacing: float) -> None:
    """Add `spacing` SVG units of extra advance between consecutive glyphs.

    hb-view emits one <use x="…" y="…"/> per glyph at the natural advance
    position — no tracking. SVG `letter-spacing` is added between every
    pair of glyphs, so glyph N gets shifted by N * spacing.
    """
    if spacing == 0:
        return
    for i, use in enumerate(use_elements):
        use.set("x", f"{float(use.get('x')) + i * spacing}")


def find_text_elements(node: ET.Element):
    for i, child in enumerate(list(node)):
        if child.tag == f"{{{SVG_NS}}}text":
            yield node, i, child
        else:
            yield from find_text_elements(child)


def outline_svg(src_path: Path, dst_path: Path) -> None:
    tree = ET.parse(src_path)
    root = tree.getroot()

    # Collect targets first so we don't mutate while iterating.
    targets = [(p, i, t) for p, i, t in find_text_elements(root)]

    for run_idx, (parent, idx, text_el) in enumerate(targets):
        text_content = "".join(text_el.itertext()).strip()
        rule = OUTLINE_RULES.get(text_content)
        if rule is None:
            continue
        font, variations, font_size = rule

        anchor_x = float(text_el.get("x"))
        baseline_y = float(text_el.get("y"))
        fill = text_el.get("fill") or "#000000"
        text_anchor = text_el.get("text-anchor", "start")
        letter_spacing = float(text_el.get("letter-spacing", "0"))

        hb_root = hb_render(font, variations, font_size, text_content, f"r{run_idx}-")

        # Drop the white background rect hb-view emits for previewing.
        for rect in hb_root.findall(f"{{{SVG_NS}}}rect"):
            hb_root.remove(rect)

        # Apply letter-spacing by shifting each <use>'s x. hb-view uses a
        # local origin at (0, baseline_y_local); the first use's y is the
        # baseline so we read it for vertical alignment.
        uses = hb_root.findall(f".//{{{SVG_NS}}}use")
        if not uses:
            continue
        apply_letter_spacing(uses, letter_spacing)

        local_baseline = float(uses[0].get("y"))
        last_use = uses[-1]
        # Total visual width = last glyph's x + its glyph-0-N defs width.
        # Approximate by reading viewBox width + cumulative letter-spacing.
        vb_width = float(hb_root.get("viewBox").split()[2])
        total_width = vb_width + (len(uses) - 1) * letter_spacing

        if text_anchor == "middle":
            tx = anchor_x - total_width / 2
        elif text_anchor == "end":
            tx = anchor_x - total_width
        else:
            tx = anchor_x
        ty = baseline_y - local_baseline

        wrapper = ET.Element(
            f"{{{SVG_NS}}}g",
            {"transform": f"translate({tx:g},{ty:g})"},
        )
        for child in list(hb_root):
            tag = child.tag.split("}")[-1]
            if tag == "g":
                child.set("fill", fill)
                child.set("fill-opacity", "1")
            wrapper.append(child)

        parent.remove(text_el)
        parent.insert(idx, wrapper)

    dst_path.parent.mkdir(parents=True, exist_ok=True)
    tree.write(dst_path, encoding="utf-8", xml_declaration=True)


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print("usage: outline_splash.py <in.svg> <out.svg>", file=sys.stderr)
        return 2
    outline_svg(Path(argv[1]), Path(argv[2]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
