include <axiom_bracket.scad>;
include <fizik_ics.scad>;

axiom_x = 0;
axiom_y = 27.5;
axiom_z = -35;

union() {
	translate([axiom_x, axiom_y, axiom_z])
	axiom_bracket();

	hull() {
    	translate([-ics_width/2, 0, 0])
		intersection() {
			ics_stop(ics_stop_height + 0.001);
			translate([-50,0,ics_height - ics_stop_height - 0.001])
			cube([100, 100, 0.001]);
		}

		translate([axiom_x, axiom_y, axiom_z])
		ax_body_top();


	}
	fizik_ics();
}