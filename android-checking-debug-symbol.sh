#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <decompiled_apk_folder>"
    exit 1
fi

DECOMPILED_APK_FOLDER=$1

# Validate that the provided path exists and is a directory
if [ ! -d "$DECOMPILED_APK_FOLDER" ]; then
    echo "Error: Decompiled APK folder '$DECOMPILED_APK_FOLDER' does not exist."
    exit 1
fi

# Check for required tools
REQUIRED_TOOLS=("find" "grep" "nm" "objdump" "strings" "readelf" "awk")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "Error: Required tool '$tool' is not installed."
        exit 1
    fi
done

echo "===== [$(date)] Start APK Debugging Symbols Analysis ====="

# Step 1: Scan for debugging-related files
echo -e "\n====== Scanning for debugging-related files ======"
DEBUG_FILES=$(find "$DECOMPILED_APK_FOLDER" -type f \( -name "*.debug" -o -name "*.map" -o -name "mapping.txt" \))
if [ -n "$DEBUG_FILES" ]; then
    echo "⚠️ Found debugging-related files:"
    echo "$DEBUG_FILES"
else
    echo "✅ No debugging-related files found."
fi
echo "====== Completed debugging-related file scan ======"

# Step 2: Check AndroidManifest.xml for `android:debuggable`
echo -e "\n====== Checking AndroidManifest.xml for android:debuggable attribute ======"
MANIFEST_FILE="$DECOMPILED_APK_FOLDER/AndroidManifest.xml"
if [ -f "$MANIFEST_FILE" ]; then
    if grep -q 'android:debuggable="true"' "$MANIFEST_FILE"; then
        echo "⚠️ Warning: android:debuggable is set to true in AndroidManifest.xml!"
    else
        echo "✅ No 'android:debuggable=\"true\"' found in AndroidManifest.xml."
    fi
else
    echo "⚠️ Warning: AndroidManifest.xml not found!"
fi
echo "====== Completed AndroidManifest.xml check ======"

# Step 3: Check .so files for debug symbols
echo -e "\n====== Scanning .so files for debugging symbols ======"
find "$DECOMPILED_APK_FOLDER" -type f -name "*.so" | while read -r SO_FILE; do
    echo -e "\n===== [+] Analyzing: $SO_FILE ====="

    # Check using nm
    echo "[+] Checking with nm..."
    if nm "$SO_FILE" 2>/dev/null | grep -q " T "; then
        echo "⚠️ Debug symbols detected using nm."
    else
        echo "✅ No debug symbols detected using nm."
    fi

    # Check using objdump
    echo "[+] Checking with objdump..."
    if objdump --syms "$SO_FILE" 2>/dev/null | grep -q " F "; then
        echo "⚠️ Debug symbols detected using objdump."
    else
        echo "✅ No debug symbols detected using objdump."
    fi

    # Check using readelf
    echo "[+] Checking with readelf..."
    if readelf -S "$SO_FILE" 2>/dev/null | grep -q "\.debug"; then
        echo "⚠️ Debugging sections detected in ELF headers."
    else
        echo "✅ No debugging sections found in ELF headers."
    fi

    # Check using strings
    echo "[+] Checking for debug-related strings..."
    if strings "$SO_FILE" 2>/dev/null | grep -Eiq "Debug|debug|NDK_DEBUG"; then
        echo "⚠️ Debug-related strings detected."
    else
        echo "✅ No debug-related strings found."
    fi

    echo "===== [!!] Completed analysis for: $SO_FILE ====="
done
echo "====== Completed .so file scan ======"

# Step 4: Scan Java, Kotlin, and Smali files for debugging-related code
echo -e "\n====== Checking Java/Kotlin/Smali files for debugging-related code ======"
DEBUG_CODE=$(find "$DECOMPILED_APK_FOLDER" -type f \( -name "*.java" -o -name "*.kt" -o -name "*.smali" \) -exec grep -Ei "android:debuggable|Log.d|Log.v|System.out.println|Debug.isDebuggerConnected|smali/debug" {} +)
if [ -n "$DEBUG_CODE" ]; then
    echo "⚠️ Warning: Debugging code detected in Java/Kotlin/Smali files:"
    echo "$DEBUG_CODE"
else
    echo "✅ No debugging code found in Java/Kotlin/Smali files."
fi
echo "====== Completed source code debug check ======"

# Step 5: Scan for debugging-related words in all files
echo -e "\n====== Performing Full Debugging Keyword Search Across All Files ======"
find "$DECOMPILED_APK_FOLDER" -type f | while read -r FILE; do
    if strings "$FILE" 2>/dev/null | grep -Eiq "Debug|debug|NDK_DEBUG|debuggable|trace|log"; then
        echo "⚠️ Debug-related keywords found in: $FILE"
    fi
done
echo "====== Completed Full Debugging Keyword Search ======"

echo "===== [$(date)] APK Debugging Symbols Analysis Completed ====="
