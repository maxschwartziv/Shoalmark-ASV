<img width="1920" height="1080" alt="shoalmark3" src="https://github.com/user-attachments/assets/b478760f-34fb-40d9-9cb1-7db07793a65c" />

<img width="3922" height="2618" alt="shoalmark" src="https://github.com/user-attachments/assets/e2857f25-7339-43c5-a384-8ebd381c1a73" />
<img width="1920" height="1080" alt="shoalmark_thruster2" src="https://github.com/user-attachments/assets/ddd59800-55cd-44cc-80b6-5ef5d5668888" />


[3d print Instructions.pdf](https://github.com/user-attachments/files/32030344/3d.print.Instructions.pdf)
# connector_parts.scad

One parametric OpenSCAD library covering the five FreeCAD bodies in the parent folder.
Each part is a module whose arguments default to the dimensions of the original, so
calling it with no arguments reproduces the original solid.

| Module | FreeCAD source |
|---|---|
| `pvc_ring_half_clamp()` | `ring_0.5inID_soloSplit10mmWidth.FCStd` |
| `pvc_to_box_bracket()` | `16mmPVCtoBox.FCStd` |
| `horizontal_to_vertical()` | `horizonalToVertical.FCStd` |
| `horizontal_to_vertical_receiver()` | `horizonalToVerticalReceiver.FCStd` |
| `thruster_to_pvc()` | `thrusterTo16mmPVC.FCStd` |

Every part keeps the origin and orientation of its FreeCAD body, so an export can be
overlaid on the original to compare.

## Two ways to use it

**As a library** — nothing is rendered by `use`, so you get just the modules:

```openscad
use <connector_parts.scad>
pvc_to_box_bracket(socket_bore = 20, socket_od = 44, plate_len = 45);
thruster_to_pvc(riser_size = 28, riser_corner_r = 8, socket_bore = 20);
```

**Directly** — open the file and pick a part from the Customizer, or from the command
line. `part = "all"` (the default) lays out all five side by side.

```bash
openscad -o bracket.stl -D '$fn=192' -D 'part="pvc_to_box_bracket"' connector_parts.scad
```

## Hole sizes in the Customizer

Every hole dimension of every part is a top-level variable, grouped by part, so you can
change them from the Customizer or with `-D` without touching a module call:

| Group | Variables |
|---|---|
| Holes: ring half clamp | `ring_pipe_od` `ring_bolt_hole_d` `ring_counterbore_d` `ring_counterbore_depth` |
| Holes: PVC to box bracket | `box_socket_bore` `box_mount_hole_d` `box_mount_csk_d` `box_mount_csk_angle` `box_side_hole_d` `box_side_hole_depth` `box_drill_point_angle` |
| Holes: horizontal to vertical pair | `h2v_socket_bore` `h2v_hole_d` `h2v_hole_depth` |
| Holes: thruster adapter | `thr_socket_bore` `thr_socket_depth` `thr_mount_hole_d` `thr_mount_cb_d` `thr_mount_cb_depth` |

The horizontal-to-vertical bracket and its receiver share one group — they bolt to each
other, so their screw holes have to match.

```bash
openscad -o clamp.stl -D 'part="pvc_ring_half_clamp"' \
         -D ring_pipe_od=20 -D ring_bolt_hole_d=5.5 -D ring_counterbore_d=10 \
         connector_parts.scad
```

These feed `cp_part()`, which is the direct-open front end. Everything else stays at the
module default; a `use <>` caller bypasses the whole block and passes its own arguments.

## Parameters

Major dimensions — plate sizes, cradle ODs, riser, gussets, hole positions and spacings —
are module arguments rather than Customizer variables. Pass them when you call the module,
or add them to the block at the top of the file the same way the hole sizes are wired.

All hole sizes and major dimensions are independent module arguments. A handful default
to `undef` and are then derived from the others, reproducing the constraint the original
sketch used — pass a number to override:

| Argument | Derived as | Original |
|---|---|---|
| `pvc_ring_half_clamp(ear_inner_y)` | where the bore meets the cut plane, `sqrt(r_bore² − split_gap²)` | 7.937 |
| `pvc_ring_half_clamp(bolt_z)` | mid-height, `ring_width/2` | 5 |
| `pvc_to_box_bracket(socket_axis_z)` | `socket_od/2`, putting the cradle's outer surface flush with the underside of the plate | 18 |
| `pvc_to_box_bracket(side_hole_y)` | mid-wall, `(socket_bore + socket_od)/4` | 13 |
| `horizontal_to_vertical(socket_axis_x)` | `socket_od/2`, making the cradle tangent to the back face | 18 |
| `horizontal_to_vertical(hole_y)` | centred on the cradle, `plate_len/2 − socket_len/2` | 25 |
| `horizontal_to_vertical(hole_z)` | mid-wall, `(socket_bore + socket_od)/4` | 13 |

`drill_point_angle = 0` gives a flat-bottomed hole instead of a 118° drill point.
`horizontal_to_vertical()` also accepts `recess_depth`/`recess_width`; the receiver is
the same module with those defaulted to 5 and 30.1.

Shared internals are prefixed `cp_`: `cp_countersunk_hole`, `cp_counterbored_hole`,
`cp_drilled_hole`, `cp_cradle`, `cp_xz_prism`, `cp_gusset`. They are reusable if you
want them, but the part modules are the intended interface.

## Fidelity

Volumes and bounding boxes were compared against the FreeCAD solids (mesh at
`$fn = 192`; the residual is polygonal-cylinder discretisation error). Consolidating the
five standalone files into this library produced byte-identical meshes — same triangle
counts, same volumes.

| Part | FreeCAD mm³ | OpenSCAD mm³ | Δ |
|---|---|---|---|
| `pvc_ring_half_clamp` | 1387.147 | 1387.205 | +0.06 |
| `pvc_to_box_bracket` | 9216.581 | 9216.522 | −0.06 |
| `horizontal_to_vertical` | 20827.966 | 20653.336 | −174.63 (see below) |
| `horizontal_to_vertical_receiver` | 16312.966 | 16138.336 | −174.63 (see below) |
| `thruster_to_pvc` | 13675.922 | 13676.283 | +0.36 |

Bounding boxes match exactly in every case.

### The one deliberate difference

In both `horizonalToVertical*.FCStd` files, the two `PartDesign::Mirrored` features leave
a 2 mm plug of material across the bottom of each of the four screw holes, where the hole
crosses from the cradle wall into the back plate (x = 8…10). It is an artifact of how
`Mirrored` recombines a subtractive feature, not a design intent — it blocks the last 2 mm
of a hole modelled as 10 mm deep, on the face a mating part bolts to. These models drill
the holes to their full modelled depth, which accounts for the whole 174.63 mm³ difference
(4 × 43.63, exactly). Pass `hole_depth = 8` to get the original's usable depth back. Worth
fixing in the FreeCAD files too.

## A note on resizing

Resizing was checked across all five parts — bore, plate, riser, hole, gusset and fillet
sizes — and each still renders as a single manifold solid. Each of the 19 hole variables
above was individually verified to change the rendered volume, so none of them are
declared-but-ignored.

The one thing to watch for is the usual OpenSCAD/CGAL sensitivity to *exact tangency*:
values that make a subtracted cylinder land precisely on a face give a non-manifold
warning. Three that came up while testing:

```openscad
pvc_ring_half_clamp(bolt_y = 13, counterbore_d = 10, ear_reach = 18)  // 13 + 5  == 18
thruster_to_pvc(mount_spacing_x = 30, mount_cb_d = 7, plate_len = 37) // 15 + 3.5 == 18.5
thruster_to_pvc(riser_size = 22, socket_bore = 22)                    // zero wall
```

The first two put a recess exactly tangent to an outside face; the third inscribes the
bore exactly in the riser. Nudging any one value by a fraction of a millimetre clears it.
This is geometry, not a bug — the same input is a zero-thickness wall in any kernel.

## Rendering

```bash
openscad -o part.stl -D '$fn=192' -D 'part="thruster_to_pvc"' connector_parts.scad
```

`$fn` defaults to 64 in preview and 160 on render.
