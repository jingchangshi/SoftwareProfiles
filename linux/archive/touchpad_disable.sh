xinput list | grep Touchpad | awk '{print $6}' | awk -F"=" '{print $2}' | xargs xinput --disable
echo "Touchpad disabled!"

