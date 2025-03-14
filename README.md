# APK Debugging Symbols Analysis Script

## Overview
This script analyzes a **decompiled Android APK folder** to detect debugging symbols, unstripped native libraries, and debug-related code that could pose security risks.

## Features
✔ **Scans all files in the APK folder**  
✔ **Checks `AndroidManifest.xml` for `android:debuggable="true"`**  
✔ **Finds `.debug`, `.map`, and `mapping.txt` files**  
✔ **Analyzes `.so` native libraries for debug symbols** using `nm`, `objdump`, and `readelf`  
✔ **Scans `.java`, `.kt`, and `.smali` files for debug logs and debug-related functions**  
✔ **Performs a full debug keyword search in all files**  

## Prerequisites
Before running the script, ensure that the following tools are installed on your system:
- `find`
- `grep`
- `nm`
- `objdump`
- `strings`
- `readelf`
- `awk`

### Installation
To install missing dependencies, run:
```sh
sudo apt-get install binutils grep findutils awk -y  # Debian/Ubuntu
sudo yum install binutils grep findutils gawk -y  # RHEL/CentOS
```

## Usage
### Step 1: Decompile the APK
Use **apktool** to decompile an APK file:
```sh
apktool d target.apk -o decompiled_apk
```

### Step 2: Run the Script
```sh
chmod +x android-checking-debug-symbol.sh
./android-checking-debug-symbol.sh /path/to/decompiled_apk
```

## Example Output
```
===== [2025-03-14 15:00:12] Start APK Debugging Symbols Analysis =====

====== Scanning for debugging-related files ======
⚠️ Found debugging-related files:
- /res/debug.log
- /lib/arm64-v8a/libnative-debug.so
====== Completed debugging-related file scan ======

====== Checking AndroidManifest.xml for android:debuggable attribute ======
⚠️ Warning: android:debuggable is set to true in AndroidManifest.xml!
====== Completed AndroidManifest.xml check ======

====== Scanning .so files for debugging symbols ======
[+] Checking with nm...
⚠️ Debug symbols detected using nm.
[+] Checking with objdump...
✅ No debug symbols detected using objdump.
[+] Checking with readelf...
⚠️ Debugging sections detected in ELF headers.
[+] Checking for debug-related strings...
⚠️ Debug-related strings detected.
====== Completed .so file scan ======

====== Checking Java/Kotlin/Smali files for debugging-related code ======
⚠️ Warning: Debugging code detected in Java/Kotlin/Smali files:
File: MainActivity.java → Log.d("DEBUG", "This is a debug message.");
File: MyService.smali → debug.trace("Debugger attached");
====== Completed source code debug check ======

====== Performing Full Debugging Keyword Search Across All Files ======
⚠️ Debug-related keywords found in: /assets/config.properties
====== Completed Full Debugging Keyword Search ======

===== [2025-03-14 15:01:30] APK Debugging Symbols Analysis Completed =====
```

---

## Understanding the Output
- ✅ **Green Checkmark** → No debugging symbols found ✅  
- ⚠️ **Warning** → Debugging traces detected! ⚠️  
- ❌ **Error** → Missing file or dependency ❌  

---


## Troubleshooting
| **Issue** | **Solution** |
|-----------|-------------|
| `Error: Decompiled APK folder does not exist.` | Ensure the correct path to the decompiled APK is provided. |
| `Required tool not installed` | Install missing tools using `apt-get install binutils grep findutils awk -y` |
| `No output generated` | Run with `bash -x android-checking-debug-symbol.sh /path/to/decompiled_apk` to debug. |

---

## Conclusion
This script is an essential tool for **security researchers and developers** to ensure that Android apps are **stripped of debugging symbols** before release. 🚀
