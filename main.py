#!/usr/bin/env python
import os
import re


def parse(scad_content: str, root_dir: str = '', already_included: set | None = None) -> str:
    """Parse the OpenSCAD content and return a flattened version.
    Resolves 'use <...>' and 'include <...>' statements recursively.

    Args:
        scad_content (str): The content of the OpenSCAD file.
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
    pattern = re.compile(r'^\s*(use|include)\s*<([^>]+\.scad)>', re.MULTILINE)
    matches = pattern.findall(scad_content)
    print(f"Found {len(matches)} use/include statements.")
    for match in matches:
        print(f"  Found statement: {match[0]} <{match[1]}>")
    # include <filename> acts as if the contents of the included file were written in the including file, and
    # use <filename> imports modules and functions, but does not execute any commands other than those definitions.
    # parser should follow the rules described in https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Include_Statement
    #  - if a file is included/used multiple times, it should only be included once
    #  - include should be processed before use and be inserted directly into the file
    #  - use should be processed after include and only import the module definitions
    for statement, filename in matches:
        filepath = os.path.join(root_dir, filename)
        if filepath in already_included:
            print(f"Skipping already included file: {filepath}")
            parsed_content = f"// --------\n// SKIPPING <{filename}>\n// --------\n"
            flattened = flattened.replace(f'{statement} <{filename}>', parsed_content)
            continue
        try:
            with open(filepath) as f:
                file_content = f.read()
            print(f"Processing {statement} file: {filepath}")
            already_included.add(filepath)
            # Recursively parse the included/used file
            parsed_content = parse(file_content, os.path.dirname(filepath), already_included)
            if statement == 'include':
                print(f"Including content from: {filepath}")
                # Insert the content directly
                parsed_content = f"// -----\n// BEGIN include <{filename}>\n// -----\n{parsed_content}\n// ---\n// END include <{filename}>\n// ---\n"
                flattened = flattened.replace(f'{statement} <{filename}>', parsed_content)
            elif statement == 'use':
                print(f"Using modules/functions from: {filepath}")
                # Insert the content directly
                # parsed_content = f"// -----\n// BEGIN use <{filename}>\n// -----\n{parsed_content}\n// ---\n// END use <{filename}>\n// ---\n"
                # flattened = flattened.replace(f'{statement} <{filename}>', parsed_content)

                modules_and_functions = extract_modules_and_functions(parsed_content)
                modules_content = '\n\n'.join(modules_and_functions)
                modules_content = f"// -----\n// BEGIN use <{filename}>\n// -----\n{modules_content}\n// ---\n// END use <{filename}>\n// ---\n"
                flattened = flattened.replace(f'{statement} <{filename}>', modules_content)
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
        module_match = re.match(r'^\s*module\s+(\w+)', line)
        if module_match:
            start = i
            # Track opening/closing braces to find the complete module definition
            brace_count = 0
            found_opening = False

            # Continue until we find a balanced closing brace
            while i < len(lines):
                current_line = lines[i]

                # Count braces only after we find the first opening brace
                if '{' in current_line and not found_opening:
                    found_opening = True
                    brace_count = 0  # Reset counter when we find the first opening brace

                if found_opening:
                    brace_count += current_line.count('{') - current_line.count('}')

                # If braces are balanced and we've found at least one, we're done with this module
                if found_opening and brace_count == 0:
                    i += 1
                    break

                i += 1

            if i <= len(lines):  # Make sure we didn't run past the end
                results.append('\n'.join(lines[start:i]))
            continue

        # Match internal variable definition (starting with underscore)
        var_match = re.match(r'^\s*(_[A-Za-z0-9_]+)\s*=', line)
        if var_match:
            start = i
            current_content = lines[i]

            # For simple variable assignment ending with semicolon on the same line
            if ';' in current_content:
                results.append(current_content)
                i += 1
                continue

            # For multi-line variable definitions
            depth = line.count('[') - line.count(']') + line.count('(') - line.count(')')

            # Continue until we find a balanced closing bracket/parenthesis and semicolon
            i += 1
            while i < len(lines) and (depth > 0 or ';' not in current_content):
                current_line = lines[i]
                current_content += "\n" + current_line
                depth += current_line.count('[') + current_line.count('(') - current_line.count(']') - current_line.count(')')

                if depth == 0 and ';' in current_line:
                    break

                i += 1

            i += 1  # Move past the last line of the variable definition
            results.append(current_content)
            continue

        # Match function definition - both regular and internal (with underscore)
        function_match = re.match(r'^\s*(?:function|(_[A-Za-z0-9_]+)\s*=\s*function)\s+(\w+)?', line)
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
                if '=' in current_line and not in_function_def:
                    in_function_def = True

                # Track nesting level for each character
                for char in current_line:
                    if char in '([{':
                        depth += 1
                    elif char in ')]}':
                        depth -= 1
                    # If we're at the root level and find a semicolon, we're done
                    elif char == ';' and depth == 0 and in_function_def:
                        i += 1  # Move past this line
                        results.append(current_content)
                        break
                else:  # No break in the for loop
                    i += 1
                    continue

                break  # If we broke out of the for loop, break out of the while loop too

            continue

            if i <= len(lines):  # Make sure we didn't run past the end
                results.append('\n'.join(lines[start:i]))
            continue

        # If we get here, the line is not a module, function, or internal variable definition
        i += 1

    return results


def generate_flat_file(input_file, output_file):
    """Generate a flat OpenSCAD file from the input file."""
    try:
        with open(input_file) as infile:
            content = infile.read()
        print(f"Processing {input_file}...")
        flattened_content = parse(content)
        os.makedirs(os.path.dirname(os.path.abspath(output_file)), exist_ok=True)
        with open(output_file, 'w') as outfile:
            outfile.write(flattened_content)
        print(f"Successfully generated {output_file} from {input_file}")
    except FileNotFoundError:
        print(f"Input file {input_file} not found.")
    except Exception as e:
        print(f"Error generating flat file: {e}")


def main():
    print("Generate OpenSCAD flat files...")
    input_file = "gridfinity-iphone-charger.scad"
    output_file = "flat/gridfinity-iphone-charger.scad"
    print(f"Input file: {input_file}")
    print(f"Output file: {output_file}")
    generate_flat_file(input_file, output_file)


if __name__ == "__main__":
    main()
