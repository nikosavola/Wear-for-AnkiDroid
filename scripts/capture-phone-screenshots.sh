#!/usr/bin/env bash
# Capture the phone companion screenshots for the Play listing from a booted phone emulator.
#
# The taps use absolute coordinates for a Pixel 7 AVD (1080x2400, 420 dpi). On first run the script
# installs AnkiDroid, walks its onboarding, and imports docs/demo/wear-for-ankidroid-demo.apkg; later
# runs reuse the collection. Screenshots are cropped to 1080x2160 and saved as JPEG, because Play
# caps screenshots at a 2:1 aspect ratio and wants 24-bit images without an alpha channel.
set -euo pipefail

serial="${1:-emulator-5554}"
sdk="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
adb="$sdk/platform-tools/adb"
pkg=fi.nikosavola.wearforankidroid
anki=com.ichi2.anki
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/fastlane/metadata/android/en-US/images/phoneScreenshots"
apkg="$root/docs/demo/wear-for-ankidroid-demo.apkg"
phone_apk="${PHONE_APK:-$root/phone/build/outputs/apk/debug/phone-debug.apk}"
anki_apk="${ANKIDROID_APK:-$HOME/.cache/wear-for-ankidroid-review/AnkiDroid-2.25.3-arm64-v8a.apk}"

dump() {
  "$adb" -s "$serial" shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
  "$adb" -s "$serial" shell cat /sdcard/ui.xml
}

wait_text() {
  local text=$1 seconds=${2:-60}
  for _ in $(seq 1 "$seconds"); do
    if dump | grep -q "text=\"$text\""; then return 0; fi
    sleep 1
  done
  echo "error: '$text' did not appear on screen" >&2
  return 1
}

tap() {
  "$adb" -s "$serial" shell input tap "$1" "$2"
  sleep 2
}

shot() {
  local png
  png="$(mktemp -t ankiwearos-phone).png"
  "$adb" -s "$serial" exec-out screencap -p >"$png"
  sips -c 2160 1080 "$png" --out "$out/$1.png" >/dev/null
  sips -s format jpeg -s formatOptions 90 "$out/$1.png" --out "$out/$1.jpg" >/dev/null
  rm -f "$png" "$out/$1.png"
}

mkdir -p "$out"
"$adb" -s "$serial" wait-for-device
until [ "$("$adb" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
  sleep 2
done

if ! "$adb" -s "$serial" shell pm list packages | grep -q "package:$anki$"; then
  if [ ! -f "$anki_apk" ]; then
    mkdir -p "$(dirname "$anki_apk")"
    curl -fL -o "$anki_apk" \
      "https://github.com/ankidroid/Anki-Android/releases/download/v2.25.3/AnkiDroid-2.25.3-arm64-v8a.apk"
  fi
  "$adb" -s "$serial" install -r "$anki_apk" >/dev/null
fi
# The provider needs all-files access to read its collection; the notification grant keeps the
# first-run permission screen from blocking.
"$adb" -s "$serial" shell appops set "$anki" MANAGE_EXTERNAL_STORAGE allow
"$adb" -s "$serial" shell pm grant "$anki" android.permission.POST_NOTIFICATIONS 2>/dev/null || true
"$adb" -s "$serial" push "$apkg" "/sdcard/Download/wear-for-ankidroid-demo.apkg" >/dev/null
"$adb" -s "$serial" shell am start -n "$anki/.IntentHandler" >/dev/null

if dump | grep -q 'text="Get started"'; then
  tap 540 1932
fi
if dump | grep -q "AnkiDroid needs some permissions"; then
  tap 948 612
  # Continue stays disabled until the app observes the grant, and it only re-checks on resume.
  "$adb" -s "$serial" shell am force-stop "$anki"
  "$adb" -s "$serial" shell am start -n "$anki/.IntentHandler" >/dev/null
  wait_text "Continue"
  tap 540 2227
fi

if dump | grep -q "Collection is empty"; then
  # Overflow, Import, Deck package, then the system file picker's Downloads root.
  tap 1020 230
  wait_text "Import"
  tap 812 723
  wait_text "Deck package (.apkg)"
  tap 540 1187
  tap 73 199
  wait_text "Downloads"
  tap 441 650
  wait_text "wear-for-ankidroid-demo.apkg"
  tap 346 1195
  wait_text "Add"
  tap 842 1386
  wait_text "Import options"
  tap 984 361
  wait_text "Overview"
  tap 74 222
fi

"$adb" -s "$serial" install -r "$phone_apk" >/dev/null
"$adb" -s "$serial" shell pm grant "$pkg" com.ichi2.anki.permission.READ_WRITE_DATABASE
"$adb" -s "$serial" shell pm grant "$pkg" android.permission.POST_NOTIFICATIONS 2>/dev/null || true
"$adb" -s "$serial" shell am start -n "$pkg/.phone.MainActivity" >/dev/null
wait_text "Spanish"

shot 01-decks

# Search hides every other deck; the IME's hide chevron sits above the gesture bar at bottom left.
tap 540 1275
"$adb" -s "$serial" shell input text cap
sleep 2
tap 162 2330
sleep 2
shot 02-search

tap 1008 216
wait_text "About"
tap 660 997
wait_text "Source code"
shot 03-about
