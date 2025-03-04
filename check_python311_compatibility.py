#!/usr/bin/env python
"""
Script to check for Python 3.11 compatibility issues in the codebase.
"""

import os
import sys
import ast
import re
from pathlib import Path

def check_python_version():
    """Check if running on Python 3.11"""
    if sys.version_info.major != 3 or sys.version_info.minor != 11:
        print(f"Warning: Running on Python {sys.version_info.major}.{sys.version_info.minor}, not Python 3.11")
        print("Some compatibility issues may not be detected.")
    else:
        print(f"Running on Python {sys.version_info.major}.{sys.version_info.minor}")

def find_python_files(base_dir):
    """Find all Python files in the project"""
    python_files = []
    for root, dirs, files in os.walk(base_dir):
        # Skip virtual environment directories
        if '.venv' in dirs:
            dirs.remove('.venv')
        if 'venv' in dirs:
            dirs.remove('venv')
        if '__pycache__' in dirs:
            dirs.remove('__pycache__')
            
        for file in files:
            if file.endswith('.py'):
                python_files.append(os.path.join(root, file))
    return python_files

def check_file_for_issues(file_path):
    """Check a Python file for potential compatibility issues"""
    issues = []
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for deprecated imports
    deprecated_imports = [
        ('collections', ['Mapping', 'MutableMapping']),
        ('typing', ['Callable', 'Dict', 'List', 'Set', 'FrozenSet', 'Tuple']),
    ]
    
    for module, names in deprecated_imports:
        for name in names:
            pattern = rf'from\s+{module}\s+import\s+.*{name}'
            if re.search(pattern, content):
                issues.append(f"Deprecated import: '{name}' from '{module}'. Use built-in types instead.")
    
    # Check for removed functions
    removed_functions = [
        ('time', ['clock']),
        ('asyncio', ['coroutine']),
    ]
    
    for module, funcs in removed_functions:
        for func in funcs:
            pattern = rf'{module}\.{func}\('
            if re.search(pattern, content):
                issues.append(f"Removed function: '{module}.{func}()' is no longer available in Python 3.11")
    
    # Check for syntax issues using ast
    try:
        ast.parse(content)
    except SyntaxError as e:
        issues.append(f"Syntax error: {str(e)}")
    
    return issues

def main():
    """Main function to check Python 3.11 compatibility"""
    check_python_version()
    
    base_dir = Path(__file__).resolve().parent
    python_files = find_python_files(base_dir)
    
    print(f"Found {len(python_files)} Python files to check")
    
    all_issues = {}
    for file_path in python_files:
        rel_path = os.path.relpath(file_path, base_dir)
        issues = check_file_for_issues(file_path)
        if issues:
            all_issues[rel_path] = issues
    
    if all_issues:
        print("\nPotential compatibility issues found:")
        for file_path, issues in all_issues.items():
            print(f"\n{file_path}:")
            for issue in issues:
                print(f"  - {issue}")
        print("\nTotal files with issues:", len(all_issues))
    else:
        print("\nNo compatibility issues found!")
    
    print("\nRecommendations:")
    print("1. Update imports from 'collections' to use built-in types")
    print("2. Update imports from 'typing' to use built-in types (Python 3.9+)")
    print("3. Test thoroughly with Python 3.11")
    print("4. Check for third-party library compatibility")

if __name__ == "__main__":
    main() 