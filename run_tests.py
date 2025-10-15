#!/usr/bin/env python
"""
Test runner script for gridfinity-iphone-charger.
"""
import importlib.util
import subprocess
import sys


def run_tests_with_coverage():
    """Run tests with coverage and report results."""
    print("Running tests with coverage...")

    # Check if pytest is installed
    if importlib.util.find_spec("pytest") is None:
        print("pytest is not installed. Please install it with:")
        print("uv pip install -e '.[dev]'")
        return 1

    # Check if pytest-cov is installed
    if importlib.util.find_spec("pytest_cov") is None:
        print("pytest-cov is not installed. Please install it with:")
        print("uv pip install -e '.[dev]'")
        return 1

    cmd = [
        "python",
        "-m",
        "pytest",
        "--cov=.",
        "--cov-report=term",
        "--cov-report=html",
        "--cov-config=pyproject.toml",
        "tests/"
    ]

    result = subprocess.run(cmd, capture_output=False)
    return result.returncode

if __name__ == "__main__":
    sys.exit(run_tests_with_coverage())
