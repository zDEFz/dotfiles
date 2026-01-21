import os

def collect_for_review():
    lib_dir = "lib"
    output_file = "master.sh"
    
    if not os.path.exists(lib_dir):
        print(f"Error: {lib_dir} folder not found.")
        return

    # Sort files: helpers first, then alphabetical
    files = sorted(os.listdir(lib_dir), key=lambda x: (x != "helpers.sh", x))
    
    with open(output_file, "w") as f_out:
        f_out.write("#!/bin/bash\n\n")
        f_out.write("# ==================================================\n")
        f_out.write("# MERGED LIBRARY FOR ARCHITECTURAL REVIEW\n")
        f_out.write("# ==================================================\n\n")

        for filename in files:
            # Skip non-shell files and the master script itself
            if not filename.endswith(".sh") or filename == output_file:
                continue
            
            filepath = os.path.join(lib_dir, filename)
            
            # Write a clean separator for the review file
            f_out.write(f"\n# --- FROM FILE: {filename} ---\n")
            
            with open(filepath, "r") as f_in:
                for line in f_in:
                    # 1. Skip shebangs
                    if line.startswith("#!/bin/bash"):
                        continue
                    
                    # 2. Skip the CLI dispatcher
                    if line.strip() == '"$@"':
                        continue
                        
                    # 3. CRITICAL: Skip previous review markers to prevent duplication
                    if "--- FROM FILE:" in line or "MERGED LIBRARY" in line or "====" in line:
                        continue
                        
                    f_out.write(line)
            
            f_out.write("\n")

    print(f"Success! All methods merged into {output_file}")

if __name__ == "__main__":
    collect_for_review()