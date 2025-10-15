/*
 * @brief Charger tray module
 * @details Create a charger tray for an iPhone with space for a magsafe charger in the middle,
 *          a cutout for the camera bump on the back of the phone,
 *          and a wedge to support the phone at an angle for getting the phone in and out easily.
 * @param phone_length The total length of the phone including any case
 * @param phone_width The total width of the phone including any case
 * @param charger_diameter The diameter of the charger
 * @param middle_top_padding The padding between the top of the charger base for the cutout and the camera bump cutout
 * @param middle_bottom_padding The padding between the bottom of the charger base for where the wedge starts
 * @param camera_height The height of the camera bump on the back of the phone
 * @param charger_height The height of the charger cutout
 * @param wedge_height The height of the wedge at the back of the tray
 * @param debug If true, print debug information to the console
 */
module charger_tray(phone_length, phone_width, charger_diameter, middle_top_padding, middle_bottom_padding, camera_height, charger_height, wedge_height, debug=true) {
    // Calculate derived dimensions
    wedge_length = (phone_length - charger_diameter)/2 - middle_bottom_padding;
    tray_length = charger_diameter + middle_top_padding + middle_bottom_padding;
    camera_length = (phone_length - charger_diameter)/2 - middle_top_padding;
    charger_tray_total_height = max(charger_height, wedge_height, camera_height);
    if (debug) {
        echo("=== Charger Tray Parameters ===");
        echo("phone_length: ", phone_length);
        echo("phone_width: ", phone_width);
        echo("charger_diameter: ", charger_diameter);
        echo("middle_top_padding: ", middle_top_padding);
        echo("middle_bottom_padding: ", middle_bottom_padding);
        echo("camera_height: ", camera_height);
        echo("charger_height: ", charger_height);
        echo("wedge_height: ", wedge_height);
        echo("wedge_length: ", wedge_length);
        echo("tray_length: ", tray_length);
        echo("camera_length: ", camera_length);
        echo("calculated length: ", (tray_length + wedge_length + camera_length));
        echo("charger_tray_total_height: ", charger_tray_total_height);
        echo("=================================");
    }

    union() {
        // Draw the middle cube where the charger lives
        cube([charger_diameter, phone_width, charger_tray_total_height + 0.02], center=true);
        // Draw the padding on top of the charger for the camera bump
        translate([(charger_diameter/2), 0, 0])
            cube([middle_top_padding + 0.02, phone_width, charger_tray_total_height], center=true);
        // Draw the padding below the charger for the wedge
        translate([-(charger_diameter/2 + middle_bottom_padding/2), 0, 0])
            cube([middle_bottom_padding + 0.02, phone_width, charger_tray_total_height], center=true);
        // Draw the camera bump
        // - remove half of the charger tray height to get to the bottom
        // - add half of the camera height to get to the center of the camera cutout
        camera_cutout_z_shift = -charger_tray_total_height/2 + camera_height/2;
        if (debug) {
            echo("camera_cutout_z_shift: ", camera_cutout_z_shift);
        }
        translate([(charger_diameter/2 + middle_top_padding/2 + camera_length/2), 0, camera_cutout_z_shift])
            cube([camera_length + 0.02, phone_width, camera_height + 0.02], center=true);
        
        // Draw the wedge to support the phone at an angle
        wedge_x_shift = -(charger_diameter/2 + middle_bottom_padding);
        wedge_z_shift = -charger_tray_total_height/2 - 0.01 + charger_tray_total_height - wedge_height;
        if (debug) {
            echo("wedge_x_shift: ", wedge_x_shift);
            echo("wedge_z_shift: ", wedge_z_shift);
        }
        translate([wedge_x_shift, 0, wedge_z_shift])
            rotate([90, 0, 180])
                wedge(wedge_length + 0.02, phone_width, wedge_height, debug);
    }
}

/*
 * @brief Create a wedge shape
 * @details Create a wedge shape with the given length, width, and height
 * @param length The length of the wedge (along the x axis)
 * @param width The width of the wedge (along the y axis)
 * @param height The height of the wedge (along the z axis)
 * @param debug If true, print debug information to the console
 */
module wedge(length, width, height, debug=true) {
    // Calculate the long edge of the wedge
    hypotenuse = sqrt(length*length + height*height);
    if (debug) {
        echo("wedge length: ", length);
        echo("wedge width: ", width);
        echo("wedge height: ", height);
        echo("wedge hypotenuse: ", hypotenuse);
    }
    // Create a right triangle and extrude it to create the wedge
    linear_extrude(height = width, center = true)
        polygon([
            [0, height],
            [hypotenuse, 0],
            [0, 0],
        ]);
}
