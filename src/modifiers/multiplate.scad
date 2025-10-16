module mw_plate_1() {
  if (charging_tray) {
    phone_charger_tray_model(_debug);
  } else {
    if (test_phone_cutout) {
      test_phone_cutout_model(_debug, "#00AE42");
    }
    if (test_charger_cutout) {
        test_charger_cutout_model(_debug, "#00AE42");
    }
  }
}

module mw_plate_2() {
    if (test_phone_cutout && charging_tray) {
        test_phone_cutout_model(_debug, "#00AE42");
    }
    if (test_charger_cutout && charging_tray) {
        test_charger_cutout_model(_debug, "#00AE42");
    }
}