import re
import subprocess
import os

def run_analysis():
    print("Running flutter analyze...")
    result = subprocess.run(["flutter", "analyze"], capture_output=True, text=True, shell=True)
    return result.stdout

def fix_errors(analysis_output):
    # Regex to find: error - Invalid constant value - lib\dashboard_page.dart:136:26 - invalid_constant
    pattern = re.compile(r"error - Invalid constant value - (lib\\[a-zA-Z0-9_\-\.]+):(\d+):\d+ - invalid_constant")
    
    matches = pattern.findall(analysis_output)
    if not matches:
        print("No dynamic const errors found.")
        return False
        
    print(f"Found {len(matches)} invalid constant errors. Resolving...")
    
    # Group matches by file to avoid opening/writing multiple times
    files_to_fix = {}
    for filepath, line_str in matches:
        line_num = int(line_str)
        if filepath not in files_to_fix:
            files_to_fix[filepath] = set()
        files_to_fix[filepath].add(line_num)
        
    for filepath, line_nums in files_to_fix.items():
        abs_path = os.path.abspath(filepath)
        if not os.path.exists(abs_path):
            print(f"File not found: {abs_path}")
            continue
            
        print(f"Fixing errors in {filepath} at lines: {sorted(list(line_nums))}")
        with open(abs_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for line_num in line_nums:
            idx = line_num - 1
            if idx >= len(lines):
                continue
                
            fixed = False
            for offset in range(0, 10):  # Expanded lookback to 10 lines
                check_idx = idx - offset
                if check_idx < 0:
                    break
                check_line = lines[check_idx]
                if 'const ' in check_line:
                    lines[check_idx] = check_line.replace('const ', '')
                    print(f"  Stripped 'const ' from line {check_idx + 1}: {lines[check_idx].strip()}")
                    fixed = True
                    break
                elif 'const [' in check_line:
                    lines[check_idx] = check_line.replace('const [', '[')
                    print(f"  Stripped 'const [' from line {check_idx + 1}: {lines[check_idx].strip()}")
                    fixed = True
                    break
            
            if not fixed:
                print(f"  WARNING: Could not find 'const' keyword near line {line_num}")
                
        with open(abs_path, 'w', encoding='utf-8', newline='') as f:
            f.writelines(lines)
            
    return True

if __name__ == "__main__":
    output = run_analysis()
    if fix_errors(output):
        output2 = run_analysis()
        fix_errors(output2)
    print("Done!")
