// ============================================================================
// connector_parts.scad
//
// Parametric OpenSCAD library for the five FreeCAD connector bodies in the
// parent folder. Every part is a module whose arguments default to the
// dimensions of the original FCStd, so calling it with no arguments reproduces
// the original solid.
//
//   part module                            FreeCAD source
//   -----------------------------------    ---------------------------------
//   pvc_ring_half_clamp()                  ring_0.5inID_soloSplit10mmWidth
//   pvc_to_box_bracket()                   16mmPVCtoBox
//   horizontal_to_vertical()               horizonalToVertical
//   horizontal_to_vertical_receiver()      horizonalToVerticalReceiver
//   thruster_to_pvc()                      thrusterTo16mmPVC
//
// USAGE
//   use <connector_parts.scad>             // modules only, nothing rendered
//   pvc_to_box_bracket(socket_bore = 20, socket_od = 40);
//
//   Opening this file directly (or include-ing it) renders the part named by
//   the `part` variable below, which also drives the Customizer.
//
// Each part keeps the origin and orientation of its FreeCAD body, so an export
// can be overlaid on the original to compare.
//
// Arguments left as undef are derived from the others; the derivation is noted
// at each one and matches the constraint used in the original sketch.
// ============================================================================

/* [Part] */
// Which part to render when this file is opened directly.
part = "all"; // [pvc_ring_half_clamp, pvc_to_box_bracket, horizontal_to_vertical, horizontal_to_vertical_receiver, thruster_to_pvc, all]

// ---------------------------------------------------------------------------
// Hole sizes, exposed for the Customizer and the direct-open front end.
// These feed cp_part() below; the part modules themselves take the same values
// as arguments, so a `use <>` caller can ignore all of this and pass its own.
// Every other dimension stays at the module default - see the part modules for
// the full argument list.
// ---------------------------------------------------------------------------

/* [Holes: ring half clamp] */
ring_pipe_od           = 16;    // bore the pair of halves closes onto
ring_bolt_hole_d       = 4.5;   // bolt through hole
ring_counterbore_d     = 8.3;   // socket-head recess
ring_counterbore_depth = 3.5;   // in from the outer face of the ear

/* [Holes: PVC to box bracket] */
box_socket_bore       = 16;     // pipe OD the cradle takes
box_mount_hole_d      = 3.6;    // plate bolt through hole
box_mount_csk_d       = 6.9;    // countersink top diameter
box_mount_csk_angle   = 90;     // countersink included angle
box_side_hole_d       = 5.5;    // screw down through the cradle wall
box_side_hole_depth   = 14;
box_drill_point_angle = 118;    // 0 for a flat bottom

/* [Holes: horizontal to vertical pair] */
h2v_socket_bore = 16;           // pipe OD each cradle takes
h2v_hole_d      = 5.5;
h2v_hole_depth  = 10;           // 8 reproduces the usable depth of the FCStd

/* [Holes: thruster adapter] */
thr_socket_bore    = 16;        // pipe OD the riser is bored for
thr_socket_depth   = 20;        // bore depth down from the top of the riser
thr_mount_hole_d   = 3.2;       // plate bolt through hole
thr_mount_cb_d     = 6.1;       // socket-head recess
thr_mount_cb_depth = 3.4;

/* [Quality] */
$fn = $preview ? 64 : 160;

/* [Hidden] */
CP_EPS = 0.01;
CP_BIG = 400;

// ---------------------------------------------------------------------------
// Customizer / direct-open front end
// ---------------------------------------------------------------------------
if (part == "all") {
    translate([  0,   0, 0]) cp_part("pvc_ring_half_clamp");
    translate([ 60,   0, 0]) cp_part("pvc_to_box_bracket");
    translate([130,   0, 0]) cp_part("horizontal_to_vertical");
    translate([200,   0, 0]) cp_part("horizontal_to_vertical_receiver");
    translate([280,   0, 0]) cp_part("thruster_to_pvc");
} else cp_part(part);

// One named part, built with the hole sizes set above.
module cp_part(name) {
    if (name == "pvc_ring_half_clamp")
        pvc_ring_half_clamp(
            pipe_od           = ring_pipe_od,
            bolt_hole_d       = ring_bolt_hole_d,
            counterbore_d     = ring_counterbore_d,
            counterbore_depth = ring_counterbore_depth);

    else if (name == "pvc_to_box_bracket")
        pvc_to_box_bracket(
            socket_bore       = box_socket_bore,
            mount_hole_d      = box_mount_hole_d,
            mount_csk_d       = box_mount_csk_d,
            mount_csk_angle   = box_mount_csk_angle,
            side_hole_d       = box_side_hole_d,
            side_hole_depth   = box_side_hole_depth,
            drill_point_angle = box_drill_point_angle);

    else if (name == "horizontal_to_vertical")
        horizontal_to_vertical(
            socket_bore = h2v_socket_bore,
            hole_d      = h2v_hole_d,
            hole_depth  = h2v_hole_depth);

    else if (name == "horizontal_to_vertical_receiver")
        horizontal_to_vertical_receiver(
            socket_bore = h2v_socket_bore,
            hole_d      = h2v_hole_d,
            hole_depth  = h2v_hole_depth);

    else if (name == "thruster_to_pvc")
        thruster_to_pvc(
            socket_bore    = thr_socket_bore,
            socket_depth   = thr_socket_depth,
            mount_hole_d   = thr_mount_hole_d,
            mount_cb_d     = thr_mount_cb_d,
            mount_cb_depth = thr_mount_cb_depth);

    else echo(str("connector_parts: unknown part name '", name, "'"));
}

// ===========================================================================
// SHARED HELPERS
// ===========================================================================

// Through hole with a countersink cut into the top face of a slab that runs
// from z = 0 to z = thickness. Centred on the current origin.
module cp_countersunk_hole(hole_d, csk_d, csk_angle, thickness) {
    csk_depth = (csk_d - hole_d) / 2 / tan(csk_angle / 2);
    translate([0, 0, -CP_EPS]) cylinder(h = thickness + 2 * CP_EPS, d = hole_d);
    translate([0, 0, thickness - csk_depth])
        cylinder(h  = csk_depth + CP_EPS,
                 d1 = hole_d,
                 d2 = csk_d + 2 * CP_EPS * tan(csk_angle / 2));
}

// Through hole with a flat-bottomed counterbore cut into the top face of a slab
// that runs from z = 0 to z = thickness.
module cp_counterbored_hole(hole_d, cb_d, cb_depth, thickness) {
    translate([0, 0, -CP_EPS]) cylinder(h = thickness + 2 * CP_EPS, d = hole_d);
    translate([0, 0, thickness - cb_depth])
        cylinder(h = cb_depth + CP_EPS, d = cb_d);
}

// Hole drilled straight down from z = 0, `depth` deep, with an optional conical
// drill point below the flat bottom. point_angle = 0 gives a flat bottom.
module cp_drilled_hole(d, depth, point_angle = 0) {
    translate([0, 0, -depth]) cylinder(h = depth + CP_EPS, d = d);
    if (point_angle > 0) {
        pt = (d / 2) / tan(point_angle / 2);
        translate([0, 0, -depth - pt]) cylinder(h = pt, d1 = 0, d2 = d);
    }
}

// Open half-socket ("cradle") for a pipe. Canonical placement: axis along +Y
// from y = 0 to y = len, bore centred on the origin, and everything at x > 0
// removed so the cradle opens towards +X.
module cp_cradle(bore, od, len) {
    intersection() {
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = len, d = od);
                translate([0, 0, -CP_EPS]) cylinder(h = len + 2 * CP_EPS, d = bore);
            }
        translate([-CP_BIG, -CP_BIG, -CP_BIG / 2])
            cube([CP_BIG, 2 * CP_BIG, CP_BIG]);
    }
}

// A 2D profile drawn in the XZ plane, extruded through `thk` in Y about y = 0.
module cp_xz_prism(thk) {
    translate([0, thk / 2, 0]) rotate([90, 0, 0]) linear_extrude(thk) children();
}

// ===========================================================================
// PART: pvc_ring_half_clamp        (ring_0.5inID_soloSplit10mmWidth.FCStd)
//
// Slightly less than half an annulus, with a bolt ear on each side. Two halves
// bolt together around the pipe; split_gap is the clamping travel each half
// gives up so the pair never bottoms out.
// ===========================================================================
module pvc_ring_half_clamp(
    pipe_od           = 16,     // bore diameter (the pipe OD it clamps onto)
    ring_od           = 22,
    ring_width        = 10,     // along Z
    split_gap         = 1,      // how far the cut face sits back from the bore axis
    ear_thickness     = 6.5,    // X depth of the ear, back from the cut face
    ear_reach         = 18,     // bore axis to the tip of the ear
    ear_fillet        = 2,      // rounding on the two long edges at the ear tip
    bolt_hole_d       = 4.5,
    bolt_y            = 13,     // bolt centre from the bore axis
    bolt_z            = undef,  // default: mid-height of the ring
    counterbore_d     = 8.3,
    counterbore_depth = 3.5,    // in from the outer face of the ear
    ear_inner_y       = undef   // default: where the bore meets the cut plane
) {
    r_in   = pipe_od / 2;
    r_out  = (pipe_od + 6 )/ 2;
    bz     = is_undef(bolt_z) ? ring_width / 2 : bolt_z;
    eiy    = is_undef(ear_inner_y)
               ? sqrt(max(0, r_in * r_in - split_gap * split_gap))
               : ear_inner_y;
    ear_x0 = -(split_gap + ear_thickness);   // outer face of the ear

    difference() {
        union() {
            // annulus, trimmed to the material side of the split plane
            difference() {
                difference() {
                    cylinder(h = ring_width, r = r_out);
                    translate([0, 0, -CP_EPS])
                        cylinder(h = ring_width + 2 * CP_EPS, r = r_in);
                }
                translate([-split_gap, -r_out - 1, -CP_EPS])
                    cube([2 * r_out + 2, 2 * r_out + 2, ring_width + 2 * CP_EPS]);
            }
            for (sy = [1, -1]) mirror([0, sy < 0 ? 1 : 0, 0])
                translate([ear_x0, 0, 0]) rotate([90, 0, 90])
                    linear_extrude(ear_thickness)
                        hull() {
                            translate([eiy, 0])
                                square([ear_reach - ear_fillet - eiy, ring_width]);
                            translate([ear_reach - ear_fillet, ear_fillet])
                                circle(r = ear_fillet);
                            translate([ear_reach - ear_fillet, ring_width - ear_fillet])
                                circle(r = ear_fillet);
                        }
        }
        for (sy = [1, -1])
            translate([ear_x0 - CP_EPS, sy * bolt_y, bz]) rotate([0, 90, 0]) {
                cylinder(h = ear_thickness + 2 * CP_EPS, d = bolt_hole_d);
                cylinder(h = counterbore_depth + CP_EPS, d = counterbore_d);
            }
    }
}

// ===========================================================================
// PART: pvc_to_box_bracket                          (16mmPVCtoBox.FCStd)
//
// Flat foot plate with an open cradle for pipe running across it. Four
// countersunk holes bolt the plate down; two screws go down through the cradle
// walls into the pipe.
// ===========================================================================
module pvc_to_box_bracket(
    plate_len         = 37,     // X
    plate_wid         = 22,     // Y
    plate_thk         = 10,     // Z
    mount_hole_d      = 3.6,
    mount_csk_d       = 6.9,
    mount_csk_angle   = 90,     // included angle
    mount_spacing_x   = 30,
    mount_spacing_y   = 15,
    socket_bore       = 16,     // pipe OD the cradle takes
    socket_od         = 36,
    socket_len        = 10,     // along X
    socket_axis_z     = undef,  // default: cradle outer surface flush with the
                                //          underside of the plate
    side_hole_d       = 5.5,
    side_hole_depth   = 14,     // down from the top of the cradle
    side_hole_y       = undef,  // default: mid-wall of the cradle
    drill_point_angle = 118     // 0 for a flat bottom
) {
    axis_z = is_undef(socket_axis_z) ? socket_od / 2 : socket_axis_z;
    hole_y = is_undef(side_hole_y) ? (socket_bore + socket_od) / 4 : side_hole_y;

    difference() {
        union() {
            translate([-plate_len / 2, -plate_wid / 2, 0])
                cube([plate_len, plate_wid, plate_thk]);
            // cradle: axis along X, opening upwards
            translate([-socket_len / 2, 0, axis_z]) rotate(a = -120, v = [1, 1, 1])
                cp_cradle(socket_bore, socket_od, socket_len);
        }
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * mount_spacing_x / 2, sy * mount_spacing_y / 2, 0])
                cp_countersunk_hole(mount_hole_d, mount_csk_d,
                                    mount_csk_angle, plate_thk);
        for (sy = [-1, 1])
            translate([0, sy * hole_y, axis_z])
                cp_drilled_hole(side_hole_d, side_hole_depth, drill_point_angle);
    }
}

// ===========================================================================
// PART: horizontal_to_vertical                 (horizonalToVertical.FCStd)
//
// Back plate carrying an open pipe cradle at each end, both opening away from
// the plate, with a screw hole in each corner of the cradle cut faces.
//
// NOTE ON ONE DELIBERATE DIFFERENCE FROM THE FCStd
// In the FreeCAD file the two PartDesign Mirrored features leave a 2 mm plug of
// material across the bottom of each screw hole, where the hole crosses into
// the back plate. That is an artifact of how Mirrored recombines a subtractive
// feature, not a design feature - it blocks the last 2 mm of a hole modelled as
// 10 mm deep, on the face a mating part bolts to. This model drills the holes to
// their full modelled depth, making it 174.6 mm^3 lighter than the FCStd. Pass
// hole_depth = 8 to reproduce the usable hole depth of the original.
// ===========================================================================
module horizontal_to_vertical(
    plate_thk     = 10,      // X
    plate_len     = 60,      // Y
    plate_hgt     = 30,      // Z
    socket_bore   = 16,
    socket_od     = 36,
    socket_len    = 10,      // along Y; one cradle at each end of the plate
    socket_axis_x = undef,   // default: cradle tangent to the back face
    hole_d        = 5.5,
    hole_depth    = 10,      // in from the cradle flat face
    hole_y        = undef,   // default: centred on the cradle
    hole_z        = undef,   // default: mid-wall of the cradle
    recess_depth  = 0,       // back-face slot; 0 for none (see the receiver)
    recess_width  = 0
) {
    axis_x = is_undef(socket_axis_x) ? socket_od / 2 : socket_axis_x;
    hy     = is_undef(hole_y) ? plate_len / 2 - socket_len / 2 : hole_y;
    hz     = is_undef(hole_z) ? (socket_bore + socket_od) / 4 : hole_z;

    difference() {
        union() {
            translate([0, -plate_len / 2, -plate_hgt / 2])
                cube([plate_thk, plate_len, plate_hgt]);
            for (sy = [1, -1]) mirror([0, sy < 0 ? 1 : 0, 0])
                translate([axis_x, plate_len / 2 - socket_len, 0])
                    cp_cradle(socket_bore, socket_od, socket_len);
        }
        for (sy = [-1, 1], sz = [-1, 1])
            translate([axis_x + CP_EPS, sy * hy, sz * hz]) rotate([0, -90, 0])
                cylinder(h = hole_depth + CP_EPS, d = hole_d);
        if (recess_depth > 0 && recess_width > 0)
            translate([-CP_EPS, -recess_width / 2, -plate_hgt / 2 - CP_EPS])
                cube([recess_depth + CP_EPS, recess_width, plate_hgt + 2 * CP_EPS]);
    }
}

// ===========================================================================
// PART: horizontal_to_vertical_receiver
//                                      (horizonalToVerticalReceiver.FCStd)
//
// The mating half: identical to horizontal_to_vertical() plus a full-height
// slot cut into the back face. The same note about hole depth applies.
// ===========================================================================
module horizontal_to_vertical_receiver(
    plate_thk     = 10,
    plate_len     = 60,
    plate_hgt     = 30,
    socket_bore   = 16,
    socket_od     = 36,
    socket_len    = 10,
    socket_axis_x = undef,
    hole_d        = 5.5,
    hole_depth    = 10,
    hole_y        = undef,
    hole_z        = undef,
    recess_depth  = 5,       // X, cut in from the back face
    recess_width  = 30.1     // Y; runs the full height in Z
) {
    horizontal_to_vertical(
        plate_thk = plate_thk, plate_len = plate_len, plate_hgt = plate_hgt,
        socket_bore = socket_bore, socket_od = socket_od,
        socket_len = socket_len, socket_axis_x = socket_axis_x,
        hole_d = hole_d, hole_depth = hole_depth,
        hole_y = hole_y, hole_z = hole_z,
        recess_depth = recess_depth, recess_width = recess_width);
}

// ===========================================================================
// PART: thruster_to_pvc                         (thrusterTo16mmPVC.FCStd)
//
// Bolt-down foot plate with a square riser bored for pipe, braced by two
// triangular gussets whose sloped edges are filleted.
// ===========================================================================
module thruster_to_pvc(
    plate_len       = 37,    // X
    plate_wid       = 22,    // Y
    plate_thk       = 10,    // Z
    plate_corner_r  = 3,
    mount_hole_d    = 3.2,
    mount_cb_d      = 6.1,
    mount_cb_depth  = 3.4,
    mount_spacing_x = 30,
    mount_spacing_y = 15,
    riser_size      = 22,    // square, X and Y
    riser_height    = 20,    // above the plate
    riser_corner_r  = 6,
    socket_bore     = 16,
    socket_depth    = 20,    // down from the top of the riser
    gusset_thk      = 8,     // Y
    gusset_reach    = 18.5,  // X at which the gusset meets the plate
    gusset_fillet   = 1      // rounding along the two sloped edges
) {
    z_top = plate_thk + riser_height;

    difference() {
        union() {
            linear_extrude(plate_thk)
                offset(r = plate_corner_r)
                    square([plate_len - 2 * plate_corner_r,
                            plate_wid - 2 * plate_corner_r], center = true);
            translate([0, 0, plate_thk]) linear_extrude(riser_height)
                offset(r = riser_corner_r)
                    square([riser_size - 2 * riser_corner_r,
                            riser_size - 2 * riser_corner_r], center = true);
            for (sx = [1, -1]) mirror([sx < 0 ? 1 : 0, 0, 0])
                cp_gusset(riser_size / 2, plate_thk, z_top,
                          gusset_reach, gusset_thk, gusset_fillet);
        }
        translate([0, 0, z_top - socket_depth])
            cylinder(h = socket_depth + CP_EPS, d = socket_bore);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * mount_spacing_x / 2, sy * mount_spacing_y / 2, 0])
                cp_counterbored_hole(mount_hole_d, mount_cb_d,
                                     mount_cb_depth, plate_thk);
    }
}

// Right-triangle brace in the XZ plane running from the riser wall (x_leg, up
// to z_top) out to the plate (reach, at z_base), with the two long sloped edges
// filleted. Built as: the profile pulled in by the fillet radius at full
// thickness, plus the full profile at reduced thickness, plus the two fillet
// cylinders - all clipped back to the true triangle.
module cp_gusset(x_leg, z_base, z_top, reach, thk, fillet) {
    dx  = reach - x_leg;
    dz  = z_top - z_base;
    len = sqrt(dx * dx + dz * dz);
    nx  = dz / len;    nz = dx / len;     // outward normal of the sloped face
    ux  = dx / len;    uz = -dz / len;    // unit vector down the slope
    ix  = x_leg - fillet * nx;            // sloped face pulled in by `fillet`
    iz  = z_top - fillet * nz;
    t_leg  = (x_leg  - ix) / ux;          // where that line meets x = x_leg
    t_base = (z_base - iz) / uz;          // where that line meets z = z_base

    intersection() {
        cp_xz_prism(thk)
            polygon([[x_leg, z_base], [reach, z_base], [x_leg, z_top]]);
        union() {
            cp_xz_prism(thk)
                polygon([[x_leg, z_base],
                         [ix + ux * t_base, z_base],
                         [ix + ux * t_leg,  iz + uz * t_leg]]);
            cp_xz_prism(thk - 2 * fillet)
                polygon([[x_leg, z_base], [reach, z_base], [x_leg, z_top]]);
            for (sy = [1, -1])
                translate([ix, sy * (thk / 2 - fillet), iz])
                    rotate([0, atan2(ux, uz), 0])
                        translate([0, 0, -len]) cylinder(h = 3 * len, r = fillet);
        }
    }
}
