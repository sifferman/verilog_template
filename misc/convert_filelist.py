#!/usr/bin/env python3

import sys
import re
import os

def process_verilog_file_list(target, file_list):
    # Check input
    if target not in ['Makefile', 'sv2v']:
        print(f'Unknown target {target}')
        return ''

    # List of allowed file extensions
    rtl_extensions = ['.sv', '.v', '.svh', '.vh']

    # Read the Verilog file list
    with open(file_list, 'r') as f:
        lines = f.readlines()

    processed_lines = []

    for line in lines:
        # Remove comments from each line
        line = re.sub(r'//.*', '', line)

        # Replace "+incdir+" with "-I"
        line = line.replace('+incdir+', '-I')

        # Remove extra whitespace
        line = ' '.join(line.split())

        # Substitute environment variables
        line = os.path.expandvars(line)

        # Check if the line ends with an allowed extension or is -I
        if target=='Makefile':
            if any(line.endswith(ext) for ext in rtl_extensions):
                processed_lines.append(line)
        elif target=='sv2v':
            if any(line.endswith(ext) for ext in rtl_extensions) or line.startswith('-I'):
                processed_lines.append(line)

    # Reorder lines: -I first, then others
    processed_lines.sort(key=lambda x: '-I' in x or '+incdir+' in x, reverse=True)

    # Print the processed content
    print(' '.join(processed_lines))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <target> <verilog_file_list>")
        sys.exit(1)

    target = sys.argv[1]
    verilog_file_list = sys.argv[2]
    process_verilog_file_list(target, verilog_file_list)
