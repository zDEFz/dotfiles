import os

def collect_for_review():
    lib_dir = "lib"
    output_file = "master.sh"
    
    if not os.path.exists(lib_dir):
        print(f"Error: {lib_dir} folder not found.")
        return

    # Sort files to keep the output predictable (helpers first is usually best)
    files = sorted(os.listdir(lib_dir))
    
    with open(output_file, "w") as f_out:
        f_out.write("#!/bin/bash\n\n")
        f_out.write("# ==================================================\n")
        f_out.write("# MERGED LIBRARY FOR ARCHITECTURAL REVIEW\n")
        f_out.write("# ==================================================\n\n")

        for filename in files:
            if not filename.endswith(".sh") or filename == "review_me.sh":
                continue
            
            filepath = os.path.join(lib_dir, filename)
            
            f_out.write(f"\n# --- FROM FILE: {filename} ---\n")
            
            with open(filepath, "r") as f_in:
                lines = f_in.readlines()
                for line in lines:
                    # Skip the shebang and the dispatcher in the merged file
                    if line.startswith("#!/bin/bash") or line.strip() == '"$@"':
                        continue
                    f_out.write(line)
            
            f_out.write("\n")

    print(f"Success! All methods merged into {output_file}")

if __name__ == "__main__":
    collect_for_review()