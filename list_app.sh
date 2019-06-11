#!/bin/bash

echo "apps of cootek:"
adb shell pm list packages | grep cootek
adb shell pm list packages | grep touchpal
sleep 2
echo "third-party software:"
adb shell pm list packages -3
