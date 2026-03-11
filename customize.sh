#!/system/bin/sh

# Module and log directory paths
MODDIR="${0%/*}"
LOG_DIR="/data/adb/netblock"
INSTALL_LOG="$LOG_DIR/Installation.log"
MEOW="/data/adb/modules/netblock"
SRC="/data/adb/modules_update/netblock/module.prop"
DEST="$MEOW/module.prop"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR" || true
mkdir -p "$MEOW"

# Logger
debug() {
    echo "$1" | tee -a "$INSTALL_LOG"
}

# Module info variables
MODNAME=$(grep_prop name $TMPDIR/module.prop)
MODVER=$(grep_prop version $TMPDIR/module.prop)
AUTHOR=$(grep_prop author $TMPDIR/module.prop)
TIME=$(date "+%d, %b - %H:%M %Z")

# Gather system information
BRAND=$(getprop ro.product.brand)
MODEL=$(getprop ro.product.model)
DEVICE=$(getprop ro.product.device)
ANDROID=$(getprop ro.system.build.version.release)
SDK=$(getprop ro.system.build.version.sdk)
ARCH=$(getprop ro.product.cpu.abi)
BUILD_DATE=$(getprop ro.system.build.date)
ROM_TYPE=$(getprop ro.system.build.type)
SDK=$(getprop ro.build.version.sdk)
SE=$(getenforce)

# Display module details
display_header() {
    debug
    debug "========================================="
    debug "          Module Information     "
    debug "========================================="
    debug " ✦ Module Name   : $MODNAME"
    debug " ✦ Version       : $MODVER"
    debug " ✦ Author        : $AUTHOR"
    debug " ✦ Started at    : $TIME"
    debug "_________________________________________"
    debug
    debug
    debug
}

# Verify module integrity
check_integrity() {
    debug "========================================="
    debug "                Meow Installer    "
    debug "========================================="
    debug " ✦ Verifying Module Integrity    "
    
    if [ -n "$ZIPFILE" ] && [ -f "$ZIPFILE" ]; then
        if [ -f "$MODPATH/verify.sh" ]; then
            if sh "$MODPATH/verify.sh"; then
                debug " ✦ Module integrity verified." > /dev/null 2>&1
            else
                debug " ✘ Module integrity check failed!"
                exit 1
            fi
        else
            debug " ✘ Missing verification script!"
            exit 1
        fi
    fi
}

# Handle module prop file
handle_module_props() {
    debug " ✦ Handling Module Properties "
    touch "$MEOW/update"
    cp "$SRC" "$DEST"
}

# Gather additional system info
gather_system_info() {
    debug "========================================="
    debug "          Gathering System Info "
    debug "========================================="
    debug " ✦ Device Brand   : $BRAND"
    debug " ✦ Device Model   : $MODEL"
    debug " ✦ Android Version: $ANDROID (SDK $SDK)"
    debug " ✦ Architecture   : $ARCH"
    debug " ✦ SELinux Status : $SE"
    debug " ✦ ROM Type       : $ROM_TYPE"
    debug " ✦ Build Date     : $BUILD_DATE"
    debug "_________________________________________"
    debug
    debug
    debug
}

# Release the source
release_source() {
    [ -f "/sdcard/meow" ] && return 0
    nohup am start -a android.intent.action.VIEW -d "https://t.me/MeowDump" > /dev/null 2>&1 &
}

# Final footer message
display_footer() {
    debug "_________________________________________"
    debug
    debug "             Installation Completed "
    debug "   This module was released by 𝗠𝗘𝗢𝗪 𝗗𝗨𝗠𝗣"
    debug
    debug
}

# Main installation flow
install_module() {
    display_header
    gather_system_info
    check_integrity
    handle_module_props
    release_source
    display_footer
}

# Start the installation process
install_module
touch "/sdcard/meow"
exit 0
