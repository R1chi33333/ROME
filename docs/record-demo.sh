#!/bin/bash
#
# Records the demo walkthrough and produces docs/demo.mp4 and docs/demo.gif.
#
# The UI test drives the app; simctl records the screen from the host. The two
# run concurrently — the recording has to already be going when the app starts,
# which is why the test is launched in the background after a short lead-in.
#
# Usage: docs/record-demo.sh [simulator-name]

set -euo pipefail

DEVICE="${1:-iPhone 17 Pro}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCS="$ROOT/docs"
RAW="$DOCS/.demo-raw.mp4"

command -v ffmpeg >/dev/null || { echo "ffmpeg required: brew install ffmpeg"; exit 1; }

UDID=$(xcrun simctl list devices available \
  | grep -F "$DEVICE (" | head -1 | sed -E 's/.*\(([-A-F0-9]{36})\).*/\1/')
[ -n "$UDID" ] || { echo "no available simulator named '$DEVICE'"; exit 1; }

echo "==> Booting $DEVICE"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator
sleep 8

echo "==> Recording"
xcrun simctl io "$UDID" recordVideo --codec h264 --force "$RAW" &
RECORDER=$!
sleep 2

echo "==> Driving the app"
# Parallel testing must be off. With it on, Xcode spawns "Clone N of <device>"
# simulators and runs the app there — leaving the device being recorded empty,
# which yields a few seconds of an idle home screen instead of a walkthrough.
xcodebuild test \
  -project "$ROOT/ROME.xcodeproj" \
  -scheme ROME \
  -destination "platform=iOS Simulator,id=$UDID" \
  -parallel-testing-enabled NO \
  -only-testing:ROMEUITests/DemoRecordingTests \
  >"$DOCS/.demo-test.log" 2>&1 || true

sleep 1
kill -INT "$RECORDER" 2>/dev/null || true
wait "$RECORDER" 2>/dev/null || true

echo "==> Encoding"
# Find where the app actually takes the screen. Everything before that is the
# springboard while the runner installs and launches, and its length varies
# from run to run — so it is detected rather than hardcoded. The wallpaper is
# blue; the app's background is near-white.
LEAD=0
for t in $(seq 2 2 40); do
  rgb=$(ffmpeg -v error -ss "$t" -i "$RAW" -vframes 1 \
        -vf "crop=100:100:20:200,scale=1:1" -f rawvideo -pix_fmt rgb24 - 2>/dev/null \
        | xxd -p | head -c 6)
  [ -n "$rgb" ] || continue
  r=$((16#${rgb:0:2})); g=$((16#${rgb:2:2})); b=$((16#${rgb:4:2}))
  if [ "$r" -gt 200 ] && [ $((r - b)) -lt 12 ] && [ $((b - r)) -lt 12 ]; then
    LEAD=$t
    break
  fi
done
echo "    lead-in: ${LEAD}s"

# Trim the lead-in, halve the height, speed up slightly so the walkthrough
# stays watchable without feeling rushed.
ffmpeg -y -loglevel error -ss "$LEAD" -i "$RAW" \
  -vf "setpts=0.75*PTS,scale=-2:960" -an \
  "$DOCS/demo.mp4"

# GIF via a generated palette — the default 216-colour web palette bands badly
# on the app's soft gradients and shadows. Frame rate and width are pushed down
# further than the mp4's: this one has to load inline in a README.
PALETTE=$(mktemp -t palette).png
GIF_FILTER="fps=10,scale=360:-1:flags=lanczos"
ffmpeg -y -loglevel error -i "$DOCS/demo.mp4" \
  -vf "setpts=0.7*PTS,$GIF_FILTER,palettegen=stats_mode=diff" "$PALETTE"
ffmpeg -y -loglevel error -i "$DOCS/demo.mp4" -i "$PALETTE" \
  -lavfi "setpts=0.7*PTS,$GIF_FILTER[v];[v][1:v]paletteuse=dither=bayer:bayer_scale=3" \
  "$DOCS/demo.gif"

rm -f "$RAW" "$PALETTE" "$DOCS/.demo-test.log"
echo "==> Done"
ls -lh "$DOCS/demo.mp4" "$DOCS/demo.gif" | awk '{print "   ", $5, $NF}'
