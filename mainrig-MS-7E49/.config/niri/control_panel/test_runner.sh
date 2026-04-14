#!/bin/bash
# test_runner.sh

echo "--- 🛠️ SYNTAX CHECK ---"
FAILED=0

for file in ./lib/*.sh; do
    if ! bash -n "$file" 2> /tmp/bash_err; then
        echo -e "❌ Error in $file:"
        cat /tmp/bash_err
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo -e "\n🛑 STOPPING: Fix syntax errors before running logic tests."
    exit 1
fi

echo -e "✅ All files syntactically sound.\n"

# Only run this if syntax passed
bash ./tests/suite_mocked_logic.sh