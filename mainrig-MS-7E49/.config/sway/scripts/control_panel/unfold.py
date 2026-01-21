import re
import os
import sys

def slugify(text):
    text = text.lower().strip()
    return re.sub(r'[^a-z0-9]+', '_', text).strip('_')

def unfold_from_master(input_file):
    lib_dir = "lib"
    if not os.path.exists(lib_dir):
        os.makedirs(lib_dir)

    categories = {}
    
    # Regex patterns
    menu_re = re.compile(r"^#\s*menu:\s*([^|]+)\|")
    func_start_re = re.compile(r"^([a-zA-Z0-9_]+)\(\)\s*\{")

    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found.")
        return

    with open(input_file, "r") as f:
        lines = f.readlines()

    i = 0
    current_comments = []
    
    while i < len(lines):
        line = lines[i]

        # 1. Capture comments but ignore specific markers and repetitive headers
        if line.strip().startswith("#") and not line.strip().startswith("#!"):
            # Added logic to skip the "FROM FILE" and "MERGED LIBRARY" noise
            if "--- FROM FILE:" not in line and "MERGED LIBRARY" not in line and "===" not in line:
                current_comments.append(line)
            i += 1
            continue

        # 2. Match function start
        match = func_start_re.match(line)
        if match:
            func_name = match.group(1)
            
            # Determine Category
            category_name = "general"
            for c in current_comments:
                menu_match = menu_re.search(c)
                if menu_match:
                    category_name = menu_match.group(1).strip()
                    break
            
            # Routing: Start with underscore -> helpers, else use category slug
            if func_name.startswith("_"):
                cat_slug = "helpers"
            else:
                cat_slug = slugify(category_name)

            if cat_slug not in categories:
                categories[cat_slug] = ["#!/bin/bash\n\n"]

            # Add comments and function start line
            categories[cat_slug].extend(current_comments)
            categories[cat_slug].append(line)

            # --- DEPTH TRACKING LOGIC ---
            brace_depth = line.count("{") - line.count("}")
            
            i += 1
            while i < len(lines) and brace_depth > 0:
                inner_line = lines[i]
                categories[cat_slug].append(inner_line)
                
                brace_depth += inner_line.count("{")
                brace_depth -= inner_line.count("}")
                i += 1
            
            categories[cat_slug].append("\n")
            current_comments = [] # Reset after assignment
            continue # Skip the i += 1 at the bottom because the while loop advanced it
        
        else:
            # If line is not a comment and not a function, reset the comment buffer
            # This prevents comments from one section "leaking" into the next 
            # if there is empty space or non-function code in between.
            if line.strip() != "":
                current_comments = []
        
        i += 1

    # 3. Write output files
    for cat, content in categories.items():
        file_path = os.path.join(lib_dir, f"{cat}.sh")
        with open(file_path, "w") as f_out:
            f_out.writelines(content)
            # Add dispatcher to all except helpers
            if cat != "helpers":
                f_out.write('\n"$@"\n')
        
        os.chmod(file_path, 0o755)
        print(f"Successfully unfolded: {file_path}")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "master.sh"
    unfold_from_master(target)