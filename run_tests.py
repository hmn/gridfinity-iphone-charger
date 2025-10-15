#!/usr/bin/env python
"""
Test runner script for gridfinity-iphone-charger.
"""
import subprocess
import sys

def run_tests_with_coverage():
    """Run tests with coverage and report results."""
    print("Running tests with coverage...")
    
    cmd = [
        "pytest",
        "--cov=.",
        "--cov-report=term",
        "--cov-report=html",
        "tests/"
    ]
    
    result = subprocess.run(cmd, capture_output=False)
    return result.returncode

if __name__ == "__main__":
    sys.exit(run_tests_with_coverage())