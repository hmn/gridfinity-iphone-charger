#!/usr/bin/env python
"""Generate flat OpenSCAD files from the source files.
Resolves 'use <...>' and 'include <...>' statements recursively.
Also updates variable modifiers in the SETUP section if specified.
"""

import json
import os
import re
import sys


def update_modifiers_in_setup(scad_content: str, modifiers: dict) -> str:
    """Update modifiers in the OpenSCAD file.

    Args:
        scad_content (str): The content of the OpenSCAD file.
        modifiers (dict): A dictionary of modifiers to apply (modifier_name: filename).
            The filename should be a .scad file in the src/modifiers directory.

    Returns:
        str: The updated OpenSCAD content.
    """
    updated_content = scad_content

    # Process each modifier
    for modifier_name, modifier_file in modifiers.items():
        print(f"Processing modifier: {modifier_name} = {modifier_file}")

        # Create pattern to find the modifier section
        start_pattern = f"/* MODIFIER {modifier_name} */"

        # Find all occurrences of the modifier pattern
        start_indexes = [m.start() for m in re.finditer(re.escape(start_pattern), updated_content)]

        if not start_indexes:
            print(f"Modifier section {modifier_name} not found in file")
            continue

        if len(start_indexes) < 2:
            print(f"Found only one occurrence of {modifier_name} marker, need end marker")
            continue

        # Get the content to replace (between two occurrences of the marker)
        start_pos = start_indexes[0]
        end_pos = start_indexes[1] + len(start_pattern)

        # Extract the section to be replaced
        section_to_replace = updated_content[start_pos:end_pos]

        # Read the content from the modifier file
        try:
            modifier_filepath = os.path.join("src", "modifiers", modifier_file)
            with open(modifier_filepath, encoding="utf-8") as f:
                modifier_content = f.read()

            # Create the new section with the same markers but different content
            new_section = f"{start_pattern}\n{modifier_content}\n{start_pattern}"

            # Replace the section in the content
            updated_content = updated_content.replace(section_to_replace, new_section)
            print(f"Successfully replaced {modifier_name} with content from {modifier_file}")
        except FileNotFoundError:
            print(f"Modifier file {modifier_filepath} not found")
        except OSError as e:
            print(f"Error processing modifier {modifier_name}: {e}")

    return updated_content


def parse(
    scad_content: str,
    modifiers: dict,
    root_dir: str = "src",
    already_included=None,
) -> str:
    """Parse the OpenSCAD content and return a flattened version.
    Resolves 'use <...>' and 'include <...>' statements recursively.

    Args:
        scad_content (str): The content of the OpenSCAD file.
        modifiers (dict): A dictionary of variable modifiers to apply.
        root_dir (str): The directory to search for .scad files.
        already_included (set): Tracks included files to avoid duplicates.

    Returns:
        str: The flattened OpenSCAD content.
    """
    if already_included is None:
        already_included = set()
    flattened = scad_content
    # Recursively find all of the use and include statements
    #  - must start a line not valid if indented
    #  - must have the scad extension
    pattern = re.compile(r"^\s*(use|include)\s*<([^>]+\.scad)>", re.MULTILINE)
    matches = pattern.findall(scad_content)
    print(f"Found {len(matches)} use/include statements.")
    for match in matches:
        print(f"  Found statement: {match[0]} <{match[1]}>")

    # include <filename> acts as if the contents of the included file
    # were written in the including file, and use <filename> imports modules and functions,
    # but does not execute any commands other than those definitions.
    # parser should follow the rules described in
    #   https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Include_Statement
    #
    #  - if a file is included/used multiple times, it should only be included once
    #  - include should be processed before use and be inserted directly into the file
    #  - use should be processed after include and only import the module definitions
    for statement, filename in matches:
        filepath = os.path.join(root_dir, filename)
        if filepath in already_included:
            print(f"Skipping already included file: {filepath}")
            parsed_content = f"// --------\n// SKIPPING <{filename}>\n// --------\n"
            flattened = flattened.replace(f"{statement} <{filename}>", parsed_content)
            continue
        try:
            with open(filepath, encoding="utf-8") as f:
                file_content = f.read()
            print(f"Processing {statement} file: {filepath}")
            already_included.add(filepath)
            # Recursively parse the included/used file
            parsed_content = parse(
                file_content, modifiers, os.path.dirname(filepath), already_included
            )
            if statement == "include":
                print(f"Including content from: {filepath}")
                # Insert the content directly
                parsed_content = f"// -----\n// BEGIN include <{filename}>\n// -----\n{parsed_content}\n// ---\n// END include <{filename}>\n// ---\n"
                flattened = flattened.replace(f"{statement} <{filename}>", parsed_content)
            elif statement == "use":
                print(f"Using modules/functions from: {filepath}")
                # Insert the content directly
                # parsed_content = f"// -----\n// BEGIN use <{filename}>\n// -----\n{parsed_content}\n// ---\n// END use <{filename}>\n// ---\n"
                # flattened = flattened.replace(f'{statement} <{filename}>', parsed_content)

                modules_and_functions = extract_modules_and_functions(parsed_content)
                modules_content = "\n\n".join(modules_and_functions)
                modules_content = f"// -----\n// BEGIN use <{filename}>\n// -----\n{modules_content}\n// ---\n// END use <{filename}>\n// ---\n"
                flattened = flattened.replace(f"{statement} <{filename}>", modules_content)
        except FileNotFoundError:
            print(f"File not found: {filepath}. Skipping.")
            raise
        except Exception as e:
            print(f"Error processing file {filepath}: {e}. Skipping.")
            raise

    return flattened


def extract_modules_and_functions(scad_code: str) -> list[str]:
    """
    Extract all module and function definitions from OpenSCAD code,
    handling multiline and nested brackets/parentheses.

    This function emulates the 'use' statement in OpenSCAD by extracting
    only the module and function definitions without any other executable code.
    Also extracts internal variables that start with underscore.
    """
    results = []
    lines = scad_code.splitlines()
    i = 0

    # Add dummy line at the end to ensure we process the last function/module if it's at EOF
    lines.append("")  # Empty line to ensure proper termination

    while i < len(lines):
        line = lines[i].strip()

        # Skip comments and empty lines
        if line.startswith("//") or not line:
            i += 1
            continue

        # Slkip block comments
        if line.startswith("/*"):
            while i < len(lines) and "*/" not in lines[i]:
                i += 1
            i += 1  # Move past the closing */
            continue

        # Match module definition
        module_match = re.match(r"^\s*module\s+(\w+)", line)
        if module_match:
            start = i
            # Track opening/closing braces to find the complete module definition
            brace_count = 0
            found_opening = False

            # Continue until we find a balanced closing brace
            while i < len(lines):
                current_line = lines[i]

                # Count braces only after we find the first opening brace
                if "{" in current_line and not found_opening:
                    found_opening = True
                    brace_count = 0  # Reset counter when we find the first opening brace

                if found_opening:
                    brace_count += current_line.count("{") - current_line.count("}")

                # If braces are balanced and we've found at least one, we're done with this module
                if found_opening and brace_count == 0:
                    i += 1
                    break

                i += 1

            if i <= len(lines):  # Make sure we didn't run past the end
                results.append("\n".join(lines[start:i]))
            continue

        # Match internal variable definition (starting with underscore)
        var_match = re.match(r"^\s*(_[A-Za-z0-9_]+)\s*=", line)
        if var_match:
            start = i
            current_content = lines[i]

            # For simple variable assignment ending with semicolon on the same line
            if ";" in current_content:
                results.append(current_content)
                i += 1
                continue

            # For multi-line variable definitions
            depth = line.count("[") - line.count("]") + line.count("(") - line.count(")")

            # Continue until we find a balanced closing bracket/parenthesis and semicolon
            i += 1
            while i < len(lines) and (depth > 0 or ";" not in current_content):
                current_line = lines[i]
                current_content += "\n" + current_line
                depth += (
                    current_line.count("[")
                    + current_line.count("(")
                    - current_line.count("]")
                    - current_line.count(")")
                )

                if depth == 0 and ";" in current_line:
                    break

                i += 1

            i += 1  # Move past the last line of the variable definition
            results.append(current_content)
            continue

        # Match function definition - both regular and internal (with underscore)
        function_match = re.match(
            r"^\s*(?:function|(_[A-Za-z0-9_]+)\s*=\s*function)\s+(\w+)?", line
        )
        if function_match:
            start = i

            # Use a more sophisticated approach that properly handles nested expressions
            current_content = ""
            depth = 0  # Track nesting of parentheses, brackets, and braces
            in_function_def = False

            # For functions, we'll read character by character to properly detect the end
            while i < len(lines):
                current_line = lines[i]
                current_content += current_line + "\n"

                # Check if we've started the function definition (after the '=' sign)
                if "=" in current_line and not in_function_def:
                    in_function_def = True

                # Track nesting level for each character
                for char in current_line:
                    if char in "([{":
                        depth += 1
                    elif char in ")]}":
                        depth -= 1
                    # If we're at the root level and find a semicolon, we're done
                    elif char == ";" and depth == 0 and in_function_def:
                        i += 1  # Move past this line
                        results.append(current_content)
                        break
                else:  # No break in the for loop
                    i += 1
                    continue

                break  # If we broke out of the for loop, break out of the while loop too

            continue

        # If we get here, the line is not a module, function, or internal variable definition
        i += 1

    return results


def generate_flat_file(input_file: str, output_file: str, modifiers: dict):
    """Generate a flat OpenSCAD file from the input file."""
    try:
        with open(input_file, encoding="utf-8") as infile:
            content = infile.read()
        print(f"Processing {input_file}...")

        print("Updating modifiers ...")
        updated_content = update_modifiers_in_setup(content, modifiers)

        print("Flattening the file with includes/uses ...")
        flattened_content = parse(updated_content, modifiers)

        os.makedirs(os.path.dirname(os.path.abspath(output_file)), exist_ok=True)
        with open(output_file, "w", encoding="utf-8") as outfile:
            outfile.write(flattened_content)
        print(f"Successfully generated {output_file} from {input_file}")
    except FileNotFoundError:
        print(f"Input file {input_file} not found.")
        raise
    except Exception as e:
        print(f"Error generating flat file: {e}")
        raise


def load_config(config_file: str) -> dict:
    """Load the JSON configuration file."""
    try:
        with open(config_file, encoding="utf-8") as f:
            config = json.load(f)
        return config
    except FileNotFoundError:
        print(f"Configuration file {config_file} not found.")
        raise
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON in {config_file}: {e}")
        raise


def usage():
    """Print usage information."""
    print("Usage: python run.py <config.json>")
    print("Generates flat OpenSCAD files from the source files.")
    print("Example: python run.py config/makerworld.json")
    sys.exit(1)


def main():
    """Main function to generate flat OpenSCAD files."""
    if len(sys.argv) != 2:
        usage()
    try:
        config_file = sys.argv[1]
        print("Loading config file :", config_file)
        config = load_config(config_file)
        input_file: str = str(config.get("input_file", ""))
        output_file: str = str(config.get("output_file", ""))
        modifiers: dict = config.get("modifiers", {})
        if not input_file or not output_file:
            print("Config file must specify 'input_file' and 'output_file'.")
            usage()
        if not isinstance(modifiers, dict):
            print("'modifiers' in config file must be a dictionary.")
            usage()
        print(f"Generating flat file {output_file} from {input_file} with modifiers {modifiers}")
        generate_flat_file(input_file, output_file, modifiers)
    except Exception as e:  # pylint: disable=broad-except
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
