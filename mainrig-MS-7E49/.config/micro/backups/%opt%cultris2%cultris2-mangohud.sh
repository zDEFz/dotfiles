#!/bin/bash

# Set the directory and Java home environment variables
export DIR="/opt/cultris2/"
JAVA_HOME="/usr/lib/jvm/java-17-temurin"
SECURITY_POLICY="$DIR/cultris2.policy"

# Check if MangoHud is installed
if command -v mangohud &> /dev/null; then
    echo "MangoHud is installed."
else
    echo "MangoHud is not installed. Please install it using your package manager."
    exit 1
fi

# Check if the directory is accessible
if [ ! -d "$DIR" ]; then
    echo "Directory $DIR does not exist or is not accessible."
    exit 1
fi

# Change to the specified directory and run the Java application with MangoHud
cd "$DIR" && mangohud --dlsym "$DIR" "$JAVA_HOME/bin/java" \
    -Djava.library.path="$DIR/libs/" \
    -Djava.security.manager \
    -Djava.security.policy="$SECURITY_POLICY" \
    -jar "$DIR/cultris2.jar"
