#!/usr/bin/env python3
"""
Validates Godot .tres (resource) files for common syntax errors.

Common mistakes this catches:
- Using preload() instead of ExtResource()
- Using GDScript syntax (var, const, func) in resource files
- Missing ExtResource declarations
- Incorrect array type syntax
"""

import sys
import re
from pathlib import Path


class TresValidator:
    def __init__(self, file_path):
        self.file_path = Path(file_path)
        self.errors = []
        self.warnings = []

    def validate(self):
        """Run all validation checks."""
        if not self.file_path.exists():
            self.errors.append(f"File not found: {self.file_path}")
            return False

        content = self.file_path.read_text()

        self._check_preload_usage(content)
        self._check_gdscript_keywords(content)
        self._check_array_syntax(content)
        self._check_resource_references(content)

        return len(self.errors) == 0

    def _check_preload_usage(self, content):
        """Check for illegal preload() usage."""
        preload_pattern = r'preload\s*\('
        matches = list(re.finditer(preload_pattern, content, re.IGNORECASE))

        for match in matches:
            line_num = content[:match.start()].count('\n') + 1
            self.errors.append(
                f"Line {line_num}: Found 'preload()' - use ExtResource() instead in .tres files"
            )

    def _check_gdscript_keywords(self, content):
        """Check for GDScript keywords that shouldn't be in .tres files."""
        # Split into lines and check each
        lines = content.split('\n')
        keywords = ['var ', 'const ', 'func ', 'class_name ', 'extends ']

        for i, line in enumerate(lines, 1):
            # Skip comments
            if line.strip().startswith('#'):
                continue

            for keyword in keywords:
                if keyword in line and not line.strip().startswith('['):
                    self.errors.append(
                        f"Line {i}: Found GDScript keyword '{keyword.strip()}' - "
                        f"not allowed in .tres files"
                    )

    def _check_array_syntax(self, content):
        """Check for proper typed array syntax."""
        # Look for array assignments without type
        untyped_array_pattern = r'=\s*\[[^\]]*\]'
        lines = content.split('\n')

        for i, line in enumerate(lines, 1):
            # Skip resource headers
            if line.strip().startswith('[') and line.strip().endswith(']'):
                continue

            if re.search(untyped_array_pattern, line):
                # Check if it's preceded by Array[Type]
                if 'Array[' not in line:
                    self.warnings.append(
                        f"Line {i}: Array may need type specification - "
                        f"use Array[Type]([...]) syntax"
                    )

    def _check_resource_references(self, content):
        """Check that ExtResource IDs are declared."""
        # Find all ExtResource usages
        usage_pattern = r'ExtResource\s*\(\s*"([^"]+)"\s*\)'
        usages = re.findall(usage_pattern, content)

        # Find all ExtResource declarations
        decl_pattern = r'\[ext_resource[^\]]*id\s*=\s*"([^"]+)"'
        declarations = re.findall(decl_pattern, content)

        # Check for undefined references
        for resource_id in set(usages):
            if resource_id not in declarations:
                self.errors.append(
                    f"ExtResource('{resource_id}') used but not declared - "
                    f"add [ext_resource ...] declaration"
                )

    def print_results(self):
        """Print validation results."""
        print(f"\n{'='*60}")
        print(f"Validating: {self.file_path}")
        print(f"{'='*60}\n")

        if self.errors:
            print("❌ ERRORS:")
            for error in self.errors:
                print(f"  • {error}")
            print()

        if self.warnings:
            print("⚠️  WARNINGS:")
            for warning in self.warnings:
                print(f"  • {warning}")
            print()

        if not self.errors and not self.warnings:
            print("✅ No issues found!\n")
        elif not self.errors:
            print("✅ No errors (only warnings)\n")
        else:
            print(f"❌ Found {len(self.errors)} error(s)\n")

        return len(self.errors) == 0


def main():
    if len(sys.argv) < 2:
        print("Usage: validate_tres.py <file.tres>")
        sys.exit(1)

    validator = TresValidator(sys.argv[1])
    validator.validate()
    success = validator.print_results()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
