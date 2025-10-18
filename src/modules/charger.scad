/*
 * @brief Cutout for magsafe compatible charger
 * @details Create a circular cutout for a magsafe compatible charger
 *          with a cable management cutout.
 * @param bin_height The total height of the bin
 * @param internal_bin_height The total height of the internal bin
 * @param tray_length The length of the tray the charger sits in
 * @param charger_height The height of the charger cutout
 * @param charger_diameter The diameter of the charger cutout
 * @param camera_height The height of the camera bump cutout
 * @param wedge_height The height of the wedge cutout to support the phone at an angle
 * @param middle_top_padding The padding above the middle section
 * @param middle_bottom_padding The padding below the middle section
 * @param phone_length The length of the phone
 * @param phone_height The height of the phone
 * @param plug_width The width of the plug cutout
 * @param cable_diameter The diameter of the cable cutout
 * @param cable_cutout_angle The angle of the cable cutout in degrees, 0 is to the right, 90 is up, 180 is left, 270 is down
 * @param debug If true, print debug information to the console
 */
module charger_cutout(
    bin_height,
    internal_bin_height,
    tray_length,
    charger_height,
    charger_diameter,
    camera_height,
    wedge_height,
    middle_top_padding,
    middle_bottom_padding,
    phone_length,
    phone_height,
    plug_width,
    cable_diameter,
    cable_cutout_angle,
    debug = true
) {
    hole_offset = 1.0;
    // fix the angle of the charger so we can route the cable to the edge we want
    radius = charger_diameter / 2;
    x_offset = radius * cos(cable_cutout_angle);
    y_offset = radius * sin(cable_cutout_angle);

    if (debug) {
        echo("==== charger_cutout : parameters ====");
        echo("bin_height: ", bin_height);
        echo("internal_bin_height: ", internal_bin_height);
        echo("tray_length: ", tray_length);
        echo("charger_height: ", charger_height);
        echo("charger_diameter: ", charger_diameter);
        echo("camera_height: ", camera_height);
        echo("wedge_height: ", wedge_height);
        echo("middle_top_padding: ", middle_top_padding);
        echo("middle_bottom_padding: ", middle_bottom_padding);
        echo("phone_length: ", phone_length);
        echo("phone_height: ", phone_height);
        echo("plug_width: ", plug_width);
        echo("cable_diameter: ", cable_diameter);
        echo("cable_cutout_angle: ", cable_cutout_angle);
        echo("hole_offset: ", hole_offset);
        echo("x_offset: ", x_offset);
        echo("y_offset: ", y_offset);
    }

    // The main charger cutout
    cylinder(h = charger_height + 0.02, d = charger_diameter, center = true, $fn=200);

    // Cutout throught the bottom of the tray for maintenance if you need to access the charger
    hull() {
        // Make a cutout for the cable at the right orientation

        // z_offset = cable_diameter / 2 - bin_height;
        // move offset because the rest of the cutout's are not centered
        z_offset = charger_height/2 - bin_height - hole_offset;
        // - make a cutout though the bottom of the tray for the cable to go through
        // - make notch where the cable should go through
        translate([x_offset, y_offset, z_offset])
            cylinder(h = bin_height, d = plug_width + 0.4, center = false, $fn=200);

        translate([0, 0, z_offset])
            cylinder(h = bin_height, d = plug_width + 0.4, center = false, $fn=200);
    }

    // make a channel for the cable it should go though the tray in the right direction
    // figure out if we need to exit out the bottom of the tray or the top of the tray based on the angle
    if (cable_cutout_angle > 270 || cable_cutout_angle < 90) {
        // Create channel for the cable that exit out the top of the tray
        // Base length is from the edge of the charger to the edge of the tray plus top padding
        base_length = tray_length/2 - charger_diameter/2 + middle_top_padding - plug_width/2 + cable_diameter*2;
        local_angle = min(90, max(0, (cable_cutout_angle < 90 ? cable_cutout_angle : (360 - cable_cutout_angle))));
        vertical_projection = (charger_diameter)/2 * (1 - cos(local_angle));
        camera_length = base_length + vertical_projection;

        if (debug) {
            echo("===== charger_cutout : top cable channel =====");
            echo("Cable cutout angle: ", cable_cutout_angle);
            echo("Charger dimension: ", charger_diameter);
            echo("Base camera_length: ", base_length);
            echo("Local angle: ", local_angle);
            echo("Vertical projection: ", vertical_projection);
            echo("Final camera length: ", camera_length);
        }

        cable_cutout_z_start_offset = 0 - camera_height/2;
        cable_cutout_z_end_offset = 0 - camera_height;
        hull() {
            translate([x_offset, y_offset, cable_cutout_z_start_offset])
                rotate([0, 90, 0])
                    cylinder(h = middle_top_padding, d = cable_diameter, $fn=50);
            translate([x_offset, y_offset, cable_cutout_z_end_offset - hole_offset])
                rotate([0, 90, 0])
                    cylinder(h = camera_length, d = cable_diameter, $fn=50);
            translate([x_offset, y_offset, cable_cutout_z_start_offset - bin_height])
                rotate([0, 90, 0])
                    cylinder(h = camera_length, d = cable_diameter, $fn=50);
        }
    } else {
        // Create channel for the cable that exit out the bottom of the tray
        // Base length is from the edge of the charger to the edge of the tray plus bottom padding
        base_length = tray_length/2 - charger_diameter/2 + middle_bottom_padding - plug_width/2 + cable_diameter;
        angle_offset = abs(cable_cutout_angle - 180);
        clamped_offset = angle_offset > 90 ? 90 : angle_offset;
        angle_factor = 1 - cos(clamped_offset);
        vertical_projection = (charger_diameter)/2 * angle_factor;
        wedge_length = base_length + vertical_projection;

        if (debug) {
            echo("===== charger_cutout : bottom cable channel =====");
            echo("Cable cutout angle: ", cable_cutout_angle);
            echo("Charger dimension: ", charger_diameter);
            echo("Base wedge_length: ", base_length);
            echo("Cable cutout angle:", cable_cutout_angle);
            echo("Angle offset from 180: ", angle_offset);
            echo("Clamped offset (<=90): ", clamped_offset);
            echo("Angle factor (1-cos): ", angle_factor);
            echo("Vertical projection: ", vertical_projection);
            echo("Final wedge_length: ", wedge_length);
        }

        cable_cutout_z_start_offset = 0;
        cable_cutout_z_end_offset = 0 - wedge_height;
        hull() {
            translate([x_offset, y_offset, cable_cutout_z_start_offset])
                rotate([180, 90, 0])
                    cylinder(h = middle_bottom_padding, d = cable_diameter, $fn=50);

            translate([x_offset, y_offset, cable_cutout_z_end_offset - hole_offset])
                rotate([180, 90, 0])
                    cylinder(h = wedge_length, d = cable_diameter, $fn=50);

            translate([x_offset, y_offset, cable_cutout_z_start_offset - bin_height])
                rotate([180, 90, 0])
                    cylinder(h = wedge_length, d = cable_diameter, $fn=50);
        }
    }
}
