/* fizik ics clip */

use <parabolic_cylinder.scad>;

module fizik_ics() {
    width = 30.0;
    min_depth = 18.0;
    max_depth = min_depth * 2;
    height = 6.0;

    wall_thickness = 1.5;

    clip_width = 22;
    clip_thickness = 1.0;

    /*
     *             b
     *            ___
     *         a /   \ c
     *          /     \
     *  -------/       \
     *  -----------------
     */

    clip_protrusion = 2.0;
    clip_length_a = 1.0;
    clip_length_b = 2.0;
    clip_length_c = 2.5;

    // distance from the clip to the inside of the frame wall
    clip_separation = 2.5;

    module frame() {
        // outer frame
        difference() {
            cube([width, max_depth, height]);
            translate([wall_thickness, wall_thickness, 0]) {
                cube([width - 2 * wall_thickness, max_depth - 2 * wall_thickness, height * 2]);
            }
        }
    }

    module clip() {
        width_space = (width - clip_width - 2 * wall_thickness) / 2;

        x_shift = wall_thickness + width_space;
        y_shift = wall_thickness + clip_separation;
        translate([x_shift, y_shift, 0]) {
            union() {
                // Remove the part that conflicts with the ramp
                difference() {
                    cube([clip_width, max_depth - y_shift, clip_thickness]);
                    cube([clip_width, clip_length_a + clip_length_b + clip_length_c, clip_thickness]);
                };

                rotate([90, 0, 0])
                rotate([0, 90, 0])
                linear_extrude(clip_width) {
                    polygon([
                        [0, clip_thickness],
                        [clip_length_c, -clip_protrusion],
                        [clip_length_c + clip_length_b, -clip_protrusion],
                        [clip_length_c + clip_length_b + clip_length_a, 0 ],
                        [clip_length_c + clip_length_b + clip_length_a, clip_thickness],
                    ]);
                };
            }
        }
    }

    // width/depth are post-rotate, height is pre-rotate
    stop_angle = 25.0;
    stop_width = 43.0;
    stop_depth = 12.0;
    stop_height = 14.0;

    module stop() {
        // Model the end as a tilted paraboloid
        translate([width / 2, min_depth - height * tan(stop_angle), -height])
        rotate([-stop_angle, 0, 0]) {
            parabolic_cylinder(stop_width, stop_depth, stop_height * 2);
        }
    }

    module mask() {
        // FIXME: Make this an extrude of the actual shape
        translate([(width - stop_width) / 2, 0, -cos(stop_angle) * stop_height + height]) {
            cube([stop_width, max_depth * 2, cos(stop_angle) * stop_height]);
        }
    }

    translate([-width/2, 0, 0])
    intersection() {
        union() {
            difference() {
                union() {
                    frame();
                    clip();
                }

                // mask off the end
                hull() {
                    stop();
                    translate([0, max_depth, 0]) {
                        cube([width, 1, height]);
                    }
                }
            }

            difference() {
                stop();
                translate([0, cos(stop_angle) * wall_thickness, -sin(stop_angle) * wall_thickness]) {
                    stop(stop_height * 2);
                }
            }
        }
        mask();
    }

}

fizik_ics();