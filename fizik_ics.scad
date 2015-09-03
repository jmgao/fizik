/* fizik ics clip */

use <parabolic_cylinder.scad>;

ics_width = 30.0;
ics_min_depth = 18.0;
ics_max_depth = ics_min_depth * 1.8;
ics_height = 6.0;

ics_wall_thickness = 1.5;

ics_clip_width = 22;
ics_clip_thickness = 1.0;

/*
 *             b
 *            ___
 *         a /   \ c
 *          /     \
 *  -------/       \
 *  -----------------
 */

ics_clip_protrusion = 2.0;
ics_clip_length_a = 1.0;
ics_clip_length_b = 2.0;
ics_clip_length_c = 2.5;

// distance from the clip to the inside of the frame wall
ics_clip_separation = 2.5;

// width/depth are post-rotate, height is pre-rotate
ics_stop_angle = 25.0;
ics_stop_width = 43.0;
ics_stop_depth = 12.0;
ics_stop_length = 14.0;
ics_stop_height = cos(ics_stop_angle) * ics_stop_length;

module ics_frame() {
    // outer frame
    difference() {
        cube([ics_width, ics_max_depth, ics_height]);
        translate([ics_wall_thickness, ics_wall_thickness, 0]) {
            cube([ics_width - 2 * ics_wall_thickness, ics_max_depth - 2 * ics_wall_thickness, ics_height * 2]);
        }
    }
}

module ics_clip() {
    width_space = (ics_width - ics_clip_width - 2 * ics_wall_thickness) / 2;

    x_shift = ics_wall_thickness + width_space;
    y_shift = ics_wall_thickness + ics_clip_separation;
    translate([x_shift, y_shift, 0]) {
        union() {
            // Remove the part that conflicts with the ramp
            difference() {
                cube([ics_clip_width, ics_max_depth - y_shift, ics_clip_thickness]);
                cube([ics_clip_width, ics_clip_length_a + ics_clip_length_b + ics_clip_length_c, ics_clip_thickness]);
            };

            rotate([90, 0, 0])
            rotate([0, 90, 0])
            linear_extrude(ics_clip_width) {
                polygon([
                    [0, ics_clip_thickness],
                    [ics_clip_length_c, -ics_clip_protrusion],
                    [ics_clip_length_c + ics_clip_length_b, -ics_clip_protrusion],
                    [ics_clip_length_c + ics_clip_length_b + ics_clip_length_a, 0 ],
                    [ics_clip_length_c + ics_clip_length_b + ics_clip_length_a, ics_clip_thickness],
                ]);
            };
        }
    }
}

module ics_stop_mask(sh) {
    // FIXME: Make this an extrude of the actual shape
    translate([(ics_width - ics_stop_width) / 2, 0, ics_height-sh]) {
        cube([ics_stop_width, ics_max_depth * 2, sh]);
    }
}

module ics_stop_solid(sh) {
    // Model the end as a tilted paraboloid
    intersection() {
        translate([ics_width / 2, ics_min_depth - ics_height * tan(ics_stop_angle), -ics_height])
        rotate([-ics_stop_angle, 0, 0])
        translate([0,0,sh/2])
        parabolic_cylinder(ics_stop_width, ics_stop_depth, sh);
        ics_stop_mask(sh);
    }
}

module ics_stop(sh, wt = ics_wall_thickness, hollow = false) {
    difference() {
        ics_stop_solid(sh);
        if (hollow) {
            translate([0, wt / cos(ics_stop_angle) , 0]) {
                ics_stop_solid(sh);
            }
        }
    }
}

module fizik_ics() {
    translate([-ics_width/2, 0, 0])
    union() {
        difference() {
            union() {
                ics_frame();
                ics_clip();
            }

            // mask off the end
            hull() {
                ics_stop_solid(ics_stop_height);
                translate([0, ics_max_depth, 0]) {
                    cube([ics_width, 1, ics_height]);
                }
            }
        }

        ics_stop(ics_stop_height, ics_wall_thickness);
    }
}