#!/bin/bash
# Define the path to the decompiled APK folder
DECOMPILED_APK_FOLDER=$1

# Check if the specified folder exists
if [ ! -d "$DECOMPILED_APK_FOLDER" ]; then
    echo "Error: Decompiled APK folder does not exist."
    exit 1
fi

# Check for .debug files in the folder
echo "====== Start Checking for .debug file extensions: ======\n"
find "$DECOMPILED_APK_FOLDER" -type f -name "*.debug" -print
echo "\n====== Finish Checking for .debug file extensions: ======\n"

# Check AndroidManifest.xml for the android:debuggable attribute
echo "====== Start Checking AndroidManifest.xml for android:debuggable attribute: ======\n"
manifest="$DECOMPILED_APK_FOLDER/AndroidManifest.xml"
if [ -f "$manifest" ]; then
    grep 'android:debuggable="true"' "$manifest" && echo "Debuggable attribute is set to true." || echo "No debuggable attribute set to true found."
else
    echo "AndroidManifest.xml not found."
fi
echo "\n====== Finish Checking AndroidManifest.xml for android:debuggable attribute: ======\n"

# Find all .so files in the decompiled APK folder and check for debug symbols using nm, objdump, and strings
find "$DECOMPILED_APK_FOLDER" -type f -name "*.so" | while read -r so_file; do
    
    echo "====== [+] Checking file: $so_file ======\n"
    echo "\n[+] Checking $so_file for debug symbols using nm:"
    nm "$so_file" | grep " T " && echo "Debug symbols found using nm." || echo "No debug symbols found using nm."
    echo "\n[+] Checking $so_file for debug symbols using objdump:"
    objdump --syms "$so_file" | grep " F " && echo "Debug symbols found using objdump." || echo "No debug symbols found using objdump."
    echo "\n[+] Checking $so_file for debug symbols using strings:"
    strings "$so_file" | grep -E "Debug|debug" && echo "Debug-related strings found." || echo "No debug-related strings found."
    echo "\n====== [!!] Finish Checking file: $so_file ======\n\n"

done
echo "Scan complete."
