/* CONFIG FUNCTIONS */

// make sure where is space below the phone camera/wedge cutout for the cable
// TODO: use gridfinity base height functionality
function auto_gridz() =
  let (
    bottom_space = 2, // space below the charger cutout to the bottom of the bin
    needed_height = charger_tray_height() + cable_diameter() + phone_height() + bottom_space
  ) ceil(needed_height / 7);
function bin_height() = gridz > 0 ? height(gridz, gridz_define, enable_zsnap) : height(auto_gridz(), gridz_define, enable_zsnap);
// TODO: use gridfinity base grid size functionality
function tray_length() = gridx * 42;
function y_shift_models() = charging_tray && (test_phone_cutout || test_charger_cutout) ? (.1 + gridy / 2) * 42 : 0;
