import os
import pytest
import tempfile
from unittest.mock import patch, mock_open
import main


@pytest.fixture
def sample_scad_content():
    """Sample OpenSCAD content with includes and uses."""
    return """
// Simple test OpenSCAD file
include <some_library.scad>
use <some_module.scad>

module test_module() {
    cube([10, 10, 10]);
}

function test_function(x) = x * 2;

test_module();
"""


@pytest.fixture
def sample_module_content():
    """Sample content with module definitions."""
    return """
// Sample module
module test_module() {
    cube([10, 10, 10]);
}

// Function definition
function test_function(x) = x * 2;

// Internal variable
_internal_var = 42;

// Complex module with nested braces
module complex_module() {
    if (true) {
        cube([5, 5, 5]);
    } else {
        sphere(5);
    }
}

// Multi-line function
function complex_function(a, b, c) = 
    let(
        x = a * 2,
        y = b * 3
    )
    x + y + c;

// Call modules - should not be extracted
test_module();
"""


@pytest.fixture
def nested_scad_structure(tmpdir):
    """Creates a nested structure of OpenSCAD files for testing."""
    # Create root file
    root_file = tmpdir.join("root.scad")
    root_file.write("""
// Root file
include <lib/utility.scad>
use <lib/modules.scad>

module root_module() {
    cube([10, 10, 10]);
}
""")
    
    # Create lib directory
    lib_dir = tmpdir.mkdir("lib")
    
    # Create utility.scad with an include
    utility_file = lib_dir.join("utility.scad")
    utility_file.write("""
// Utility library
include <common/constants.scad>

function utility_function(x) = x * 2;
""")
    
    # Create modules.scad with a use
    modules_file = lib_dir.join("modules.scad")
    modules_file.write("""
// Modules library
use <common/shapes.scad>

module test_module() {
    cube([5, 5, 5]);
}
""")
    
    # Create common directory
    common_dir = lib_dir.mkdir("common")
    
    # Create constants.scad
    constants_file = common_dir.join("constants.scad")
    constants_file.write("""
// Constants
_PI = 3.14159;
""")
    
    # Create shapes.scad
    shapes_file = common_dir.join("shapes.scad")
    shapes_file.write("""
// Shapes
module cube_centered(size) {
    cube(size, center=true);
}
""")
    
    return {
        'root': str(root_file),
        'utility': str(utility_file),
        'modules': str(modules_file),
        'constants': str(constants_file),
        'shapes': str(shapes_file),
        'root_dir': str(tmpdir)
    }


def test_extract_modules_and_functions_basic():
    """Test basic extraction of modules and functions."""
    code = """
module test_module() {
    cube([10, 10, 10]);
}

function test_function(x) = x * 2;
"""
    results = main.extract_modules_and_functions(code)
    assert len(results) == 2
    assert "module test_module()" in results[0]
    assert "function test_function" in results[1]


def test_extract_modules_and_functions_complex(sample_module_content):
    """Test extraction of complex modules and functions."""
    results = main.extract_modules_and_functions(sample_module_content)
    
    # Should extract 4 items: test_module, _internal_var, complex_module, complex_function
    assert len(results) == 5
    
    # Check for module definitions
    module_count = 0
    internal_var_count = 0
    function_count = 0
    
    for item in results:
        if "module test_module()" in item:
            module_count += 1
        if "module complex_module()" in item:
            module_count += 1
        if "_internal_var = 42" in item:
            internal_var_count += 1
        if "function test_function" in item:
            function_count += 1
        if "function complex_function" in item:
            function_count += 1
    
    assert module_count == 2
    assert internal_var_count == 1
    assert function_count == 2
    
    # Should not contain the module call
    for item in results:
        assert "test_module();" not in item


def test_parse_basic(sample_scad_content):
    """Test basic parsing with mocked file opens."""
    with patch('builtins.open', mock_open(read_data="// Included content")) as mock_file:
        result = main.parse(sample_scad_content)
        
        # Check that the file was opened for each include/use
        assert mock_file.call_count == 2
        
        # Check that original module and function are preserved
        assert "module test_module()" in result
        assert "function test_function" in result
        
        # Check that includes and uses are properly wrapped with comments
        assert "BEGIN include <some_library.scad>" in result
        assert "BEGIN use <some_module.scad>" in result
        
        # Check that comments are added
        assert "BEGIN include <some_library.scad>" in result
        assert "BEGIN use <some_module.scad>" in result


def test_parse_with_real_files(nested_scad_structure):
    """Test parsing with real nested file structure."""
    with open(nested_scad_structure['root'], 'r') as f:
        root_content = f.read()
    
    result = main.parse(root_content, os.path.dirname(nested_scad_structure['root']))
    
    # Check that constants from deeply nested include are present
    assert "_PI = 3.14159" in result
    
    # Check that utility function from direct include is present
    assert "utility_function(x)" in result
    
    # Check that module from use statement is present
    assert "module test_module()" in result
    
    # Check that module from root file is preserved
    assert "module root_module()" in result
    
    # Check that module from deeply nested use is present
    assert "module cube_centered" in result


def test_parse_with_already_included(nested_scad_structure):
    """Test parsing with already included files."""
    with open(nested_scad_structure['root'], 'r') as f:
        root_content = f.read()
    
    # Mock the utility file being already included
    already_included = {nested_scad_structure['utility']}
    
    result = main.parse(root_content, os.path.dirname(nested_scad_structure['root']), already_included)
    
    # Check that utility file was skipped
    assert "SKIPPING <lib/utility.scad>" in result
    
    # Utility function should not be present
    assert "utility_function(x)" not in result
    
    # But module from use statement should still be present
    assert "module test_module()" in result


def test_parse_file_not_found():
    """Test parse function with file not found."""
    content = "include <nonexistent.scad>\n\nmodule test() {}"
    
    with pytest.raises(FileNotFoundError):
        main.parse(content)


@pytest.mark.parametrize("statement,filename,content", [
    ("include", "test.scad", "module test() {}"),
    ("use", "test.scad", "module test() {}"),
])
def test_parse_different_statements(statement, filename, content):
    """Test parsing with different statements."""
    scad_content = f"{statement} <{filename}>\n\nmodule main() {{}}"
    
    with patch('builtins.open', mock_open(read_data=content)):
        result = main.parse(scad_content)
        
        # Check that statement is properly wrapped with comments
        assert f"BEGIN {statement} <{filename}>" in result
        assert f"END {statement} <{filename}>" in result
        assert f"BEGIN {statement} <{filename}>" in result
        assert f"END {statement} <{filename}>" in result


def test_generate_flat_file():
    """Test generate_flat_file function."""
    input_content = "include <lib.scad>\n\nmodule test() {}"
    
    with tempfile.TemporaryDirectory() as tmpdir:
        input_file = os.path.join(tmpdir, "input.scad")
        output_file = os.path.join(tmpdir, "output", "output.scad")
        
        # Create input file
        with open(input_file, 'w') as f:
            f.write(input_content)
        
        # Create mock for parse function
        with patch('main.parse', return_value="// Flattened content"):
            main.generate_flat_file(input_file, output_file)
            
            # Check that output directory was created
            assert os.path.exists(os.path.dirname(output_file))
            
            # Check that output file was created with correct content
            with open(output_file, 'r') as f:
                assert f.read() == "// Flattened content"


def test_generate_flat_file_input_not_found():
    """Test generate_flat_file with input file not found."""
    with patch('builtins.print') as mock_print:
        main.generate_flat_file("nonexistent.scad", "output.scad")
        
        # Check that error message was printed
        mock_print.assert_any_call("Input file nonexistent.scad not found.")


def test_generate_flat_file_exception():
    """Test generate_flat_file with exception."""
    with patch('builtins.open', mock_open(read_data="test")):
        with patch('main.parse', side_effect=Exception("Test error")):
            with patch('builtins.print') as mock_print:
                main.generate_flat_file("input.scad", "output.scad")
                
                # Check that error message was printed
                mock_print.assert_any_call("Error generating flat file: Test error")


def test_main_function():
    """Test main function."""
    with patch('main.generate_flat_file') as mock_generate:
        with patch('builtins.print') as mock_print:
            main.main()
            
            # Check that generate_flat_file was called with correct arguments
            mock_generate.assert_called_once_with(
                "gridfinity-iphone-charger.scad", 
                "flat/gridfinity-iphone-charger.scad"
            )
            
            # Check that print statements were called
            mock_print.assert_any_call("Generate OpenSCAD flat files...")