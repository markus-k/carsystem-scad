#!/usr/bin/env python3

import os

export_dir = "gen"

header = """include <../CarSystem.scad>;
"""

turnRadii = [
    384,
    332,
    280,
    228,
    176,
    124,
]
turnKinds = ["entry", "extra", "exit"]

straights = [
    202,
    101,
    104,
    52
]

exports = [
    *[(f"turn-{r}-30-{kind}", f"turn(turnRadii()[{i}], 30, {kind}=true);") for i, r in enumerate(turnRadii) for kind in turnKinds],
    *[(f"straight-{l}", f"straight(straightLenghts[{i}]);") for i, l in enumerate(straights)],
    ("intersectionA", "intersectionA();"),
    ("intersectionB", "intersectionB();"),
    ("intersectionC", "intersectionC();"),
]

os.makedirs(export_dir, exist_ok=True)

for filename, code in exports:
    with open(os.path.join(export_dir, f"{filename}.scad"), "w") as fd:
        fd.write(header)
        fd.write(code)
