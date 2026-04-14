#!/bin/bash
# test_runner.sh

echo "--- 🔍 ARCHITECTURAL SYNTAX AUDIT ---"
echo "Checking all files in lib/ for structural integrity..."
echo "----------------------------------------------------"

FAILED=0

for file in ./lib/*.sh; do
    # 1. Bash native syntax check (Checks for missing 'fi', 'done', '}', etc.)
    if ! bash -n "$file" 2> /tmp/bash_err; then
        echo -e "❌ SYNTAX ERROR in $file:"
        sed 's/^/  /' /tmp/bash_err # Indent error for readability
        FAILED=1
    else
        # 2. Extract function count for verification
        func_count=$(grep -c "^[a-zA-Z0-9_]*()" "$file")
        echo -e "✅ $file ($func_count functions verified)"
    fi
done

echo "----------------------------------------------------"

if [ $FAILED -eq 1 ]; then
    echo "🛑 AUDIT FAILED: Fix the errors above."
    exit 1
else
    echo "💎 ALL SYSTEMS SYNTACTICALLY SOUND"
    exit 0
fi