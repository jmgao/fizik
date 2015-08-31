// mounting bracket for axiom pulse 60
ax_body_height = 19.5;
ax_body_width = 21;
ax_body_depth = 5;

ax_back_thickness = 1.75;
ax_side_thickness = 1.25;
ax_rail_thickness = 1.25;
ax_rail_width = 3.75;

ax_latch_length = 1.75;
ax_latch_width = 4.0;
ax_latch_height = 1.25;

ax_release_cutout_width = 1.0;
ax_release_cutout_length = 4.5;
ax_release_angle = 30;
ax_release_width = 6.0;
ax_release_flat_length = 3.0;
ax_release_angled_length = 8.0;

module ax_body() {
    difference() {
        cube([ax_body_width, ax_body_height, ax_body_depth]);
        translate([ax_side_thickness, 0, ax_back_thickness])
            cube([ax_body_width - 2 * ax_side_thickness, ax_body_height, ax_body_depth - ax_back_thickness - ax_rail_thickness]);
        translate([ax_rail_width, 0, ax_body_depth - ax_rail_thickness])
            cube([ax_body_width - 2 * ax_rail_width, ax_body_height, ax_rail_thickness]);
    }
}

module ax_release() {
    union() {
        hull() {
            translate([(ax_body_width - ax_release_width) / 2, ax_body_height, 0])
            cube([ax_release_width, ax_release_flat_length, ax_back_thickness]);

            // Use hull() with a short length version of the angled part to fill in the gap
            translate([(ax_body_width - ax_release_width) / 2, ax_body_height + ax_release_flat_length, 0])
            rotate([-ax_release_angle, 0, 0])
            cube([ax_release_width, 0.0001, ax_back_thickness]);
        }

        translate([(ax_body_width - ax_release_width) / 2, ax_body_height + ax_release_flat_length, 0])
        rotate([-ax_release_angle, 0, 0])
        cube([ax_release_width, ax_release_angled_length, ax_back_thickness]);
    }
}

module ax_release_cutout() {
    union() {
        translate([(ax_body_width - ax_release_width) / 2 - ax_release_cutout_width, ax_body_height - ax_release_cutout_length, 0])
        cube([ax_release_cutout_width, ax_release_cutout_length, ax_back_thickness]);

        translate([(ax_body_width + ax_release_width) / 2, ax_body_height - ax_release_cutout_length, 0])
        cube([ax_release_cutout_width, ax_release_cutout_length, ax_back_thickness]);
    }
}

module ax_latch() {
    translate([(ax_body_width - ax_latch_width) / 2, ax_body_height, ax_back_thickness])
    rotate([90,0,90])
    linear_extrude(ax_latch_width) {
        polygon([
            [0, 0],
            [ax_latch_length, ax_latch_height],
            [ax_latch_length, 0]
        ]);
    }
}

translate([-ax_body_width / 2, 0, ax_body_width / 2])
rotate([-90, 0, 0])
union() {
    difference() {
        union() {
            ax_body();
            ax_release();
            ax_latch();
        }
        ax_release_cutout();
    }
    ax_latch();
}
