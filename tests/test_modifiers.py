"""Tests for the modifier updating functionality."""

import os
from unittest.mock import mock_open, patch

from run import update_modifiers_in_setup


def test_update_modifiers():
    """Test updating modifiers in OpenSCAD content."""
    # Create sample OpenSCAD content with modifiers
    scad_content = """
// Test OpenSCAD file

/* MODIFIER DEBUG */
// Default debug setting
$debug = false;
/* MODIFIER DEBUG */

// Some content in between

/* MODIFIER MULTIPLATE */
// Default multiplate setting
$multiplate = false;
/* MODIFIER MULTIPLATE */

module test() {
    cube([10, 10, 10]);
}
"""

    # Mock file content for modifiers
    debug_on_content = "// Debug ON content"
    debug_off_content = "// Debug OFF content"
    multiplate_on_content = "// Multiplate ON content"

    # Create a dictionary mapping file paths to content
    mock_files = {
        os.path.join("src", "modifiers", "debug_on.scad"): debug_on_content,
        os.path.join("src", "modifiers", "debug_off.scad"): debug_off_content,
        os.path.join("src", "modifiers", "multiplate_on.scad"): multiplate_on_content,
    }

    # Create a mock open function that returns file content based on path
    def mock_file_open(path, *args, **kwargs):
        if path in mock_files:
            return mock_open(read_data=mock_files[path])(*args, **kwargs)
        return mock_open()(*args, **kwargs)

    # Test updating a single modifier
    with patch("builtins.open", side_effect=mock_file_open):
        # Test updating single modifier
        modifiers = {"DEBUG": "debug_on.scad"}
        result = update_modifiers_in_setup(scad_content, modifiers)

        # Check that DEBUG was updated but MULTIPLATE wasn't
        assert debug_on_content in result
        assert "// Default debug setting" not in result
        assert "$debug = false" not in result
        assert "// Default multiplate setting" in result
        assert "$multiplate = false" in result

        # Test updating multiple modifiers
        modifiers = {"DEBUG": "debug_off.scad", "MULTIPLATE": "multiplate_on.scad"}
        result = update_modifiers_in_setup(scad_content, modifiers)

        # Check that both were updated
        assert debug_off_content in result
        assert multiplate_on_content in result
        assert "// Default debug setting" not in result
        assert "// Default multiplate setting" not in result
