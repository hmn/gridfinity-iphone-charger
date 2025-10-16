/*
 * @brief Cutout for magsafe compatible charger
 * @details Create a circular cutout for a magsafe compatible charger
 *          with a cable management cutout.
 * @param bin_height The total height of the bin, the top of the charger cutout will be flush with this
 * @param tray_length The length of the tray the charger sits in
 * @param charger_height The height of the charger cutout
 * @param charger_diameter The diameter of the charger cutout
 * @param plug_width The width of the plug cutout
 * @param cable_diameter The diameter of the cable cutout
 * @param cable_cutout_angle The angle of the cable cutout in degrees, 0 is to the right, 90 is up, 180 is left, 270 is down
 * @param debug If true, print debug information to the console
 */
module charger_cutout(
    bin_height,
    tray_length,
    charger_height, 
    charger_diameter, 
    plug_width,
    cable_diameter,
    cable_cutout_angle, // Angle in degrees
    debug = true
) {
    if (debug) {
        echo("=== Charger Cutout Parameters ===");
        echo("bin_height: ", bin_height);
        echo("tray_length: ", tray_length);
        echo("charger_height: ", charger_height);
        echo("charger_diameter: ", charger_diameter);
        echo("plug_width: ", plug_width);
        echo("cable_diameter: ", cable_diameter);
        echo("cable_cutout_angle: ", cable_cutout_angle);
        echo("=================================");
    }

    // The main charger cutout
    cylinder(h = charger_height + 0.02, d = charger_diameter, center = true, $fn=200);

    // Make a cutout for the cable at the right orientation

    // fix the angle of the charger so we can route the cable to the edge we want
    cable_cutout_height = bin_height;
    radius = charger_diameter / 2 - plug_width / 2 + cable_diameter;
    x_offset = radius * cos(cable_cutout_angle);
    y_offset = radius * sin(cable_cutout_angle);
    z_offset = -cable_cutout_height + cable_diameter / 2;
    // - make a cutout though the bottom of the tray for the cable to go through
    // - make notch where the cable should go through
    translate([x_offset, y_offset, z_offset])
        cylinder(h = cable_cutout_height, d = plug_width, center = false, $fn=200);

    // make a channel for the cable it should go though the tray in the right direction
    // figure out if we need to exit out the bottom of the tray or the top of the tray based on the angle
    if (cable_cutout_angle > 270 || cable_cutout_angle < 90) {
        // exit out the top of the tray
        if (debug) {
            echo("Creating cable channel out the top of the tray");
        }
        // create a cable channel from the cutout to the top of the tray
        cable_cutout_z_offset = - charger_height/2 + cable_diameter/2 - 0.4;
        hull() {
            translate([x_offset, y_offset, cable_cutout_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = tray_length/2, d = cable_diameter, $fn=50);
            
            translate([x_offset, y_offset, cable_cutout_z_offset-bin_height])
                rotate([0, 90, 0])
                    cylinder(h = tray_length/2, d = cable_diameter, $fn=50);
        }
    } else {
        // exit out the bottom of the tray
        if (debug) {
            echo("Creating cable channel out the bottom of the tray");
        }
        // create a cable channel from the cutout to the bottom of the tray
        cable_cutout_z_offset = - charger_height/2 - cable_diameter/2 + 0.4;
        hull() {
            translate([x_offset, y_offset, cable_cutout_z_offset])
                rotate([180, 90, 0])
                    // rotate downward
                    cylinder(h = tray_length/2, d = cable_diameter, $fn=50);

            translate([x_offset, y_offset, cable_cutout_z_offset-bin_height])
                rotate([180, 90, 0])
                    cylinder(h = tray_length/2, d = cable_diameter, $fn=50);
        }
    }
}
