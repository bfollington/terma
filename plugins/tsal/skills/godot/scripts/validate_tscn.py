#!/usr/bin/env python3
"""
Validates Godot .tscn (scene) files for common structural errors.

Common mistakes this catches:
- Missing ExtResource declarations for used resources
- Invalid parent references
- Malformed node entries
- UID format issues
"""

import sys
import re
from pathlib import Path


class TscnValidator:
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

        self._check_header(content)
        self._check_resource_references(content)
        self._check_node_structure(content)
        self._check_parent_references(content)

        return len(self.errors) == 0

    def _check_header(self, content):
        """Check for valid scene file header."""
        lines = content.split('\n')
        if not lines:
            self.errors.append("Empty file")
            return

        first_line = lines[0].strip()
        if not first_line.startswith('[gd_scene'):
            self.errors.append(
                "Invalid header - should start with [gd_scene load_steps=N format=3 ...]"
            )

        # Check for UID
        if 'uid=' not in first_line:
            self.warnings.append("Missing UID in header - may cause reference issues")

    def _check_resource_references(self, content):
        """Check that all ExtResource and SubResource references are declared."""
        # Find all ExtResource usages
        ext_usage_pattern = r'ExtResource\s*\(\s*"([^"]+)"\s*\)'
        ext_usages = re.findall(ext_usage_pattern, content)

        # Find all ExtResource declarations
        ext_decl_pattern = r'\[ext_resource[^\]]*id\s*=\s*"([^"]+)"'
        ext_declarations = re.findall(ext_decl_pattern, content)

        # Check for undefined ExtResource references
        for resource_id in set(ext_usages):
            if resource_id not in ext_declarations:
                self.errors.append(
                    f"ExtResource('{resource_id}') used but not declared"
                )

        # Find all SubResource usages
        sub_usage_pattern = r'SubResource\s*\(\s*"([^"]+)"\s*\)'
        sub_usages = re.findall(sub_usage_pattern, content)

        # Find all SubResource declarations
        sub_decl_pattern = r'\[sub_resource[^\]]*id\s*=\s*"([^"]+)"'
        sub_declarations = re.findall(sub_decl_pattern, content)

        # Check for undefined SubResource references
        for resource_id in set(sub_usages):
            if resource_id not in sub_declarations:
                self.errors.append(
                    f"SubResource('{resource_id}') used but not declared"
                )

    def _check_node_structure(self, content):
        """Check for valid node entries."""
        lines = content.split('\n')
        node_pattern = r'^\[node\s+name="([^"]+)"'

        for i, line in enumerate(lines, 1):
            match = re.match(node_pattern, line)
            if match:
                # Check if node has required attributes
                if 'type=' not in line and 'instance=' not in line and 'parent=' in line:
                    # Child nodes without type or instance might be invalid
                    self.warnings.append(
                        f"Line {i}: Node '{match.group(1)}' has parent but no type or instance"
                    )

    def _check_parent_references(self, content):
        """Check that parent references are valid."""
        lines = content.split('\n')

        # Collect all node names
        node_pattern = r'\[node\s+name="([^"]+)"'
        nodes = []

        for line in lines:
            match = re.match(node_pattern, line)
            if match:
                nodes.append(match.group(1))

        # Check parent references
        parent_pattern = r'parent="([^"]+)"'
        for i, line in enumerate(lines, 1):
            match = re.search(parent_pattern, line)
            if match:
                parent = match.group(1)
                # "." is valid (root), others should exist
                if parent != "." and '/' not in parent:
                    # Simple parent reference
                    if parent not in nodes:
                        self.warnings.append(
                            f"Line {i}: Parent '{parent}' not found in scene"
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
        print("Usage: validate_tscn.py <file.tscn>")
        sys.exit(1)

    validator = TscnValidator(sys.argv[1])
    validator.validate()
    success = validator.print_results()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
