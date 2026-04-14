import os
import re

def fold():
    lib_dir = "lib"
    output_file = "master.sh"
    
    if not os.path.exists(lib_dir):
        print(f"Error: {lib_dir} folder not found.")
        return

    # Sort files: helpers.sh first, then the rest alphabetically
    files = sorted(os.listdir(lib_dir), key=lambda x: (x != "helpers.sh", x))
    
    # Regex to catch "$@" regardless of trailing whitespace
    dispatcher_re = re.compile(r'^\s*"\$@"\s*$')
    smart_dispatcher_start = 'if [[ "${BASH_SOURCE[0]}" == "${0}" ]]'

    with open(output_file, "w") as f_out:
        f_out.write("#!/bin/bash\n\n")
        f_out.write("# ==================================================\n")
        f_out.write("# MERGED LIBRARY FOR ARCHITECTURAL REVIEW\n")
        f_out.write("# ==================================================\n\n")

        for filename in files:
            if not filename.endswith(".sh") or filename == output_file:
                continue
            
            filepath = os.path.join(lib_dir, filename)
            f_out.write(f"\n# --- FROM FILE: {filename} ---\n")
            
            with open(filepath, "r") as f_in:
                skipping_dispatcher = False
                for line in f_in:
                    # 1. Skip Shebang
                    if line.startswith("#!/bin/bash"):
                        continue
                    
                    # 2. Filter internal automation comments and duplicate descriptions
                    automation_noise = [
                        "--- FROM FILE:", 
                        "MERGED LIBRARY", 
                        "====", 
                        "Execute only if run directly",
                        "Only run dispatcher if executed directly" # The fix
                    ]
                    if any(marker in line for marker in automation_noise):
                        continue
                    
                    # 3. Detect start of dispatcher blocks
                    if smart_dispatcher_start in line or dispatcher_re.match(line):
                        skipping_dispatcher = True
                        continue
                    
                    # 4. Detect end of dispatcher block
                    if skipping_dispatcher and line.strip() == "fi":
                        skipping_dispatcher = False
                        continue
                    
                    # 5. Write line if not in a skip zone
                    if not skipping_dispatcher:
                        f_out.write(line)
            
            f_out.write("\n")

    print(f"Success! Merged into {output_file}. Dispatchers and extra comments removed.")

if __name__ == "__main__":
    fold()
