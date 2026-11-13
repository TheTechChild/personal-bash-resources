#!/bin/bash
# Android helpers over adb: remove the ad and auto-install packages that
# Motorola and the carriers push onto the phone, and find new ones after an
# OS update. Removal is per user (pm uninstall --user 0), so no root is needed
# and android-restore can bring a package back.
#
# Rerun android-debloat after every OS update: an update can reinstall them.

# Packages that android-debloat removes. Packages that are not installed are skipped.
# Lock screen ads: Glance ("Smart Lock screen") and Taboola "Live lock screen"
PBR_ANDROID_DEBLOAT_PACKAGES=(com.glance.lockscreenM com.taboola.mip com.inmobi.weather)
# Silent app installers: Digital Turbine and ironSource Aura
PBR_ANDROID_DEBLOAT_PACKAGES+=(
  com.dti.motorola
  com.ironsrc.aura.tmo
  com.aura.oobe.motorola
  com.aura.oobe.solutions
  com.aura.oobe.dish
  com.aura.services.tmobile
  com.aura.appadvisor.att
  com.aura.appadvisor.cricket
  com.aura.jet.att
)
# Ad folders and apps that were installed without asking
PBR_ANDROID_DEBLOAT_PACKAGES+=(
  com.swish.gamesfolder
  com.swishme.moto
  com.mtshopping.folder
  com.mtentertainment.folder
  com.fun.lastwar.gp
  nicedigi.com
  com.mobisystems.msdict.embedded.wireless.oxford.dictionaryofenglish
)

# android-find-bloat matches package names against this pattern.
PBR_ANDROID_BLOAT_PATTERN='glance|taboola|inmobi|dti|ignite|appselector|mobileservices|aura|ironsrc|swish|mtshopping|mtentertainment'

# Print the serial of the device to use: $1, then $ANDROID_SERIAL, then the
# only connected device. Errors go to stderr.
_android_pick_device() {
  if ! command -v adb &>/dev/null; then
    echo "adb not found. Install it: sudo pacman -S android-tools" >&2
    return 1
  fi

  local serial="${1:-$ANDROID_SERIAL}"
  if [[ -n "$serial" ]]; then
    echo "$serial"
    return 0
  fi

  local devices count
  devices=$(adb devices | awk 'NR > 1 && $2 == "device" { print $1 }')
  count=$(printf '%s\n' "$devices" | grep -c .)

  if [[ "$count" -eq 0 ]]; then
    echo "No device connected. Plug in USB, or run: adb connect <ip>:<port>" >&2
    return 1
  fi
  if [[ "$count" -gt 1 ]]; then
    echo "More than one device. Pass a serial as the last argument:" >&2
    printf '%s\n' "$devices" | sed 's/^/  /' >&2
    echo "Wireless debugging can list the same phone twice. Use the <ip>:<port> entry." >&2
    return 1
  fi
  echo "$devices"
}

# Print the installed package names, one per line.
_android_packages() {
  adb -s "$1" shell pm list packages "${@:2}" | sed 's/^package://' | tr -d '\r' | sort
}

# android-debloat [serial] — remove every package in PBR_ANDROID_DEBLOAT_PACKAGES
android-debloat() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: android-debloat [serial]"
    echo "Removes the packages in PBR_ANDROID_DEBLOAT_PACKAGES for user 0."
    return 0
  fi

  local serial installed pkg result
  local removed=0 failed=0
  serial=$(_android_pick_device "$1") || return 1

  installed=$(_android_packages "$serial")
  if [[ -z "$installed" ]]; then
    echo "Could not read the package list from $serial." >&2
    return 1
  fi

  for pkg in "${PBR_ANDROID_DEBLOAT_PACKAGES[@]}"; do
    printf '%s\n' "$installed" | grep -qxF "$pkg" || continue
    result=$(adb -s "$serial" shell pm uninstall -k --user 0 "$pkg" | tr -d '\r')
    if [[ "$result" == Success* ]]; then
      echo "Removed  $pkg"
      removed=$((removed + 1))
    else
      echo "Failed   $pkg: $result" >&2
      failed=$((failed + 1))
    fi
  done

  echo "Done: $removed removed, $failed failed."
  [[ "$failed" -eq 0 ]]
}

# android-find-bloat [serial] — list installed packages that look like ad or installer bloat
android-find-bloat() {
  local serial matches
  serial=$(_android_pick_device "$1") || return 1
  matches=$(_android_packages "$serial" | grep -iE "$PBR_ANDROID_BLOAT_PATTERN")

  if [[ -z "$matches" ]]; then
    echo "No matches for: $PBR_ANDROID_BLOAT_PATTERN"
    return 0
  fi
  echo "$matches"
  echo
  echo "Check these before removing. Add the ones to remove to PBR_ANDROID_DEBLOAT_PACKAGES."
}

# android-list-user-apps [serial] — list third-party (user-installed) packages
android-list-user-apps() {
  local serial
  serial=$(_android_pick_device "$1") || return 1
  _android_packages "$serial" -3
}

# android-restore <package> [serial] — reinstall a package that android-debloat removed
android-restore() {
  if [[ -z "$1" ]]; then
    echo "Usage: android-restore <package> [serial]" >&2
    return 1
  fi
  local serial
  serial=$(_android_pick_device "$2") || return 1
  adb -s "$serial" shell pm install-existing "$1"
}
