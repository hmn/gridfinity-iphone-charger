// Create phone tray base with Gridfinity system

// ===== PARAMETERS ===== //

/* [Models] */

// Generate the full charging tray with phone cutout and charger cutout
charging_tray = true;
// Generate just the phone cutout so the dimensions can be tested
test_phone_cutout = true;
// Generate just the charger cutout so the dimensions can be tested
test_charger_cutout = true;

/* [Phone] */

// Preset of phone dimensions.
phone_preset = 3; // [0: Custom, 1:iPhone 17 Pro Max, 2:iPhone 17 Pro, 3:iPhone 17, 4:iPhone Air, 5:iPhone 16 Pro Max, 6:iPhone 16 Pro, 7:iPhone 16 Plus, 8:iPhone 16, 9:iPhone 15 Pro Max, 10:iPhone 15 Pro, 11:iPhone 15 Plus, 12:iPhone 15, 13:iPhone 14 Pro Max, 14:iPhone 14 Pro, 15:iPhone 14 Plus, 16:iPhone 14, 17:iPhone 13 Pro Max, 18:iPhone 13 Pro, 19:iPhone 13, 20:iPhone 13 Mini, 21:iPhone 12 Pro Max, 22:iPhone 12 Pro, 23:iPhone 12, 24:iPhone 12 Mini]

function phone_presets() =
  // Length
  // Width
  // Height
  // Corner Curve
  // Corner Smoothness
  phone_preset == 1 ? [163.4, 78, 8.75, 32.0, 6] : // iPhone 17 Pro Max
  phone_preset == 2 ? [150, 71.9, 8.75, 34.0, 6] : // iPhone 17 Pro
  phone_preset == 3 ? [149.6, 71.5, 7.95, 34.0, 6] : // iPhone 17
  phone_preset == 4 ? [156.2, 74.7, 5.64, 33.0, 6] : // iPhone Air
  phone_preset == 5 ? [163.0, 77.6, 8.25, 32.0, 6] : // iPhone 16 Pro Max
  phone_preset == 6 ? [149.6, 71.5, 8.25, 34.0, 6] : // iPhone 16 Pro
  phone_preset == 7 ? [160.9, 77.8, 7.8, 31.0, 6] : // iPhone 16 Plus
  phone_preset == 8 ? [147.6, 71.6, 7.8, 34.0, 6] : // iPhone 16
  phone_preset == 9 ? [159.9, 76.7, 8.25, 32.0, 6] : // iPhone 15 Pro Max
  phone_preset == 10 ? [146.6, 70.6, 8.25, 34.0, 6] : // iPhone 15 Pro
  phone_preset == 11 ? [160.9, 77.8, 7.8, 31.0, 6] : // iPhone 15 Plus
  phone_preset == 12 ? [147.6, 71.6, 7.8, 34.0, 6] : // iPhone 15
  phone_preset == 13 ? [160.7, 77.6, 7.85, 32.0, 6] : // iPhone 14 Pro Max
  phone_preset == 14 ? [147.5, 71.5, 7.85, 34.0, 6] : // iPhone 14 Pro
  phone_preset == 15 ? [160.8, 78.1, 7.8, 31.0, 6] : // iPhone 14 Plus
  phone_preset == 16 ? [146.7, 71.5, 7.8, 34.0, 6] : // iPhone 14
  phone_preset == 17 ? [160.8, 78.1, 7.65, 32.0, 6] : // iPhone 13 Pro Max
  phone_preset == 18 ? [146.7, 71.5, 7.65, 34.0, 6] : // iPhone 13 Pro
  phone_preset == 19 ? [146.7, 71.5, 7.65, 34.0, 6] : // iPhone 13
  phone_preset == 20 ? [131.5, 64.2, 7.65, 34.0, 6] : // iPhone 13 Mini
  phone_preset == 21 ? [160.8, 78.1, 7.4, 32.0, 6] : // iPhone 12 Pro Max
  phone_preset == 22 ? [146.7, 71.5, 7.4, 34.0, 6] : // iPhone 12 Pro
  phone_preset == 23 ? [146.7, 71.5, 7.4, 34.0, 6] : // iPhone 12
  phone_preset == 24 ? [131.5, 64.2, 7.4, 34.0, 6] : // iPhone 12 Mini
  [0, 0, 0, 0]; // Custom

// Phone length
custom_phone_length = 149.6;
// Phone width
custom_phone_width = 71.5;
// Phone height
custom_phone_height = 7.95;
// Phone corner curve
custom_phone_corner_curve = 34.0;
// Phone corner smoothness (Used to approximate the gentler curves of a phone)
custom_phone_corner_smoothness = 6;

// Cover thickness to add to phone dimensions for cutout
phone_cover_thickness = 0.0;
// Phone tolerance (per side)
phone_tolerance = 0.3;
// Phone insert offset. Reduce the phone cutout depth so the phone fits in the cutout. Could be used with some covers, or if buttons conflict with the tray
phone_insert_height = 0.0;
// A cutout area to allow for a camera bump on the back of the phone
phone_camera_cutout_height = 3.0;

function phone_length() = (phone_preset == 0 ? custom_phone_length : phone_presets()[0]) + 2 * phone_tolerance + 2 * phone_cover_thickness;
function phone_width() = (phone_preset == 0 ? custom_phone_width : phone_presets()[1]) + 2 * phone_tolerance + 2 * phone_cover_thickness;
function phone_height() = (phone_preset == 0 ? custom_phone_height : phone_presets()[2]) / 2 - phone_insert_height;
function phone_corner_curve() = (phone_preset == 0 ? custom_phone_corner_curve : phone_presets()[3]);
function phone_corner_smoothness() = (phone_preset == 0 ? custom_phone_corner_smoothness : phone_presets()[4]);

/* [Charger] */

// MagSafe compatible charger dimensions.
charger_preset = 1; // [0: Custom, 1: Apple MagSafe Charger 25W, 2: Apple MagSafe Charger 15W]

function charger_presets() =
  // Diameter
  // Depth
  // Cable Diameter
  // Plug Width
  charger_preset == 1 ? [55.5, 4.37, 2.85, 12.5] : // Apple MagSafe Charger 25W
  charger_preset == 2 ? [55.92, 5.29, 2.85, 12.5] : // Apple MagSafe Charger 15W
  [0, 0, 0, 0]; // Custom, input generic size

// Diameter of the circular cutout in the charger tray
custom_charger_diameter = 55.5;
// Depth of the circular cutout in the charger tray
custom_charger_cutout_depth = 4.37;
// Cable Diameter
custom_cable_diameter = 3.0;
// Cable Plug Width
custom_cable_plug_width = 14.0;
// Charger cutout tolerance
charger_cutout_tolerance = 0.3;
// Charger cable tolerance
cable_cutout_tolerance = 0.0;
// Extra charger plug clearance
cable_plug_clearance = 0.5;
// Cable orientation angle (in degrees). Use < 90 or > 270 to route the cable out the top of the tray, otherwise it will go out the bottom
cable_cutout_angle = 315;

function charger_diameter() = (charger_preset == 0 ? custom_charger_diameter : charger_presets()[0]) + charger_cutout_tolerance;
function charger_height() = charger_preset == 0 ? custom_charger_cutout_depth : charger_presets()[1] + charger_cutout_tolerance;
function cable_diameter() = (charger_preset == 0 ? custom_cable_diameter : charger_presets()[2]) + cable_cutout_tolerance;
function cable_plug_width() = (charger_preset == 0 ? custom_cable_plug_width : charger_presets()[3]) + cable_plug_clearance;

/* [Charger tray] */

// Extra padding to the length of the charger tray above the charger cutout
charger_tray_top_padding = 1.0;
// Extra padding to the length of the charger tray below the charger cutout where the wedge starts
charger_tray_bottom_padding = 4.0;
// Height of the wedge at the bottom of the tray to support the phone at an angle when you need to get it out of the tray
charger_tray_wedge_height = 4.0;

// Figure out if camera bump, charger cutout or wedge is the tallest part so we can make space for it in the tray
//   and make sure the cable has enough space to go through the bottom of the tray
function charger_tray_height() = max(phone_camera_cutout_height, charger_height(), charger_tray_wedge_height);

/* [Gridfinity] */

// Number of bases along x-axis
gridx = 4; //.5
// Number of bases along y-axis
gridy = 2; //.5
// Bin height (leave as 0 to auto calculate based on charger size) - see bin height information and "gridz_define" below
gridz = 0; //.1
// Grid Z Definition
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// Snap gridz height to nearest 7mm increment
enable_zsnap = false;

/* [Gridfinity Base Options] */

// Enable or disable the base plate
base_plate_enabled = true;
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;
//Use gridfinity refined hole style. Not compatible with magnet_holes!
refined_holes = false;
// Base will have holes for 6mm Diameter x 2mm high magnets.
magnet_holes = false;
// Base will have holes for M3 screws.
screw_holes = false;
// Magnet holes will have crush ribs to hold the magnet.
crush_ribs = true;
// Magnet/Screw holes will have a phone_insert_height to ease insertion.
chamfer_height_holes = true;
// Magnet/Screw holes will be printed so supports are not needed.
printable_hole_top = true;

hole_options = bundle_hole_options(refined_holes, magnet_holes, screw_holes, crush_ribs, chamfer_height_holes, printable_hole_top);

/* [Hidden] */

include <gridfinity-rebuilt-openscad/src/core/standard.scad>
include <gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-utility.scad>
include <gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-holes.scad>

/* [Hidden] */

$fa = 8;
$fs = 0.25; // .01
$fn = 100;

include <std/config.scad>
include <std/debug.scad>
use <modules/tray.scad>
use <modules/charger.scad>
use <modules/phone.scad>

module phone_charger_tray_model(debug=true, color="white") {
    bin_obj = new_bin(
      [gridx, gridy],
      bin_height(),
      0, // fill_height
      false, // include_lip
      hole_options,
      only_corners,
      false // thumbscrew
    );

    if (debug) {
      echo("=== BIN INFO ===");
      echo("Height breakdown:");
      echo(bin_get_height_breakdown(bin_obj));
      echo("================");
    }

    color(color)
        difference() {
          union() {
            difference() {
              // create bin
              bin_render(bin_obj) {
                // Create solid bin
                //bin_subdivide(bin_obj, [1, 1]) {

                //}
              }
              // cutout for phone
              phone_cutout_total_height = phone_height() + charger_tray_height();
              phone_cutout_z_shift = 0.01 + bin_height() - phone_cutout_total_height;
              if (debug) {
                echo(str("Phone Cutout Total Height: ", phone_cutout_total_height));
                echo(str("Phone Cutout Z Shift: ", phone_cutout_z_shift));
              }
              translate([0, 0, phone_cutout_z_shift])
                linear_extrude(height=phone_cutout_total_height)
                  phone_2d_shape(
                    phone_length(),
                    phone_width(),
                    phone_corner_curve(),
                    phone_corner_smoothness()
                  );
            }

            // charger tray
            charger_tray_total_height = charger_tray_height() + 0.02;
            charger_tray_z_shift = bin_height() - charger_tray_total_height / 2 - phone_height() - 0.01;
            if (debug) {
              echo(str("Charger Tray Total Height: ", charger_tray_total_height));
              echo(str("Charger Tray Z Shift: ", charger_tray_z_shift));
            }
            translate([0, 0, charger_tray_z_shift])
              color("lightblue")
                charger_tray(
                  phone_length(), // phone_length
                  phone_width(), // phone_width
                  charger_diameter(), // charger diameter
                  charger_tray_top_padding,
                  charger_tray_bottom_padding,
                  phone_camera_cutout_height, // phone_camera_cutout_height
                  charger_height(), // charger_height
                  charger_tray_wedge_height, // wedge_height
                  debug
                );
          }

          // charger cutout
          charger_cutout_z_shift = bin_height() - phone_height() - charger_height() / 2 - 0.01;
          if (debug) {
            echo(str("Charger Cutout Z Shift: ", charger_cutout_z_shift));
          }
          translate([0, 0, charger_cutout_z_shift])
            charger_cutout(
              bin_height=bin_height(),
              tray_length=tray_length(),
              charger_height=charger_height(),
              charger_diameter=charger_diameter(),
              plug_width=cable_plug_width(),
              cable_diameter=cable_diameter(),
              cable_cutout_angle=cable_cutout_angle,
              debug=debug
            );
        }
}

module test_charger_cutout_model(debug=true, color="#00AE42") {
    if (debug) {
      echo("=== TEST CHARGER CUTOUT ===");
    }
    test_bin_height = charger_height() + 1.0;
    color(color)
        difference() {
        translate([0, 0, test_bin_height / 2])
            cylinder(h=test_bin_height, d=charger_diameter() + 2, center=true, $fn=100);

        test_charger_cutout_z_shift = (charger_height() + 0.02) / 2 + 1.00;
        if (debug) {
            echo(str("Test bin height: ", test_bin_height));
            echo(str("Test charger cutout Z shift: ", test_charger_cutout_z_shift));
        }
        translate([0, 0, test_charger_cutout_z_shift])
            charger_cutout(
            bin_height=test_bin_height,
            tray_length=tray_length(),
            charger_height=charger_height(),
            charger_diameter=charger_diameter(),
            plug_width=cable_plug_width(),
            cable_diameter=cable_diameter(),
            cable_cutout_angle=cable_cutout_angle,
            debug=debug
            );
        }
}

module test_phone_cutout_model(debug=true, color="#00AE42") {
    if (debug) {
      echo("=== TEST PHONE CUTOUT ===");
    }
    test_phone_frame_width = 3.0;
    if (debug) {
      echo(str("Test phone frame width: ", test_phone_frame_width));
      echo(str("Phone Cutout Height: ", phone_height()));
    }
    color(color)
      difference() {
        resize([phone_length() + test_phone_frame_width, phone_width() + test_phone_frame_width, phone_height()])
          linear_extrude(height=phone_height())
            phone_2d_shape(
              phone_length(),
              phone_width(),
              phone_corner_curve(),
              phone_corner_smoothness()
            );
        translate([0, 0, -1.0])
          linear_extrude(height=phone_height() * 2)
            phone_2d_shape(
              phone_length(),
              phone_width(),
              phone_corner_curve(),
              phone_corner_smoothness()
            );
      }
}

/* MODIFIER DEBUG */
_debug = true;
/* MODIFIER DEBUG */

/* MODIFIER COLOR */
_color = "white";
/* MODIFIER COLOR */

/* MODIFIER MULTIPLATE */
/* MODIFIER MULTIPLATE */

/* MODIFIER DRAW */
if (charging_tray) {
  translate([0, -y_shift_models(), 0])
    phone_charger_tray_model(_debug, _color);
}
if (test_phone_cutout) {
  translate([0, y_shift_models(), 0])
    test_phone_cutout_model(_debug, _color);
}
if (test_charger_cutout) {
  translate([0, y_shift_models(), 0])
    test_charger_cutout_model(_debug, _color);
}
/* MODIFIER DRAW */
