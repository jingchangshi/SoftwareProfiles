#!/bin/bash

getwindowat() {
    # move mouse to coordinates provided, get window id beneath it, move mouse back
    eval `xdotool mousemove $1 $2 getmouselocation --shell mousemove restore`
    echo $WINDOW
}

# get active app
active=`xdotool getactivewindow`
# get coordinates of an active app
eval `xdotool getwindowgeometry --shell $active`

# if left border of an app is less than display width
# (e.g. one display is 1920px wide, app has x = 200 - means it's 200px to the right from the left border of left monitor
# if it has x = 1920 or more, it's on the right window), it's on screen 0, and we need to focus to screen 1, otherwise to screen 0
(( $X >= $WIDTH )) && focustoscreen=0 || focustoscreen=1;

# get coordinates of the middle of the screen we want to switch
searchx=$[ ($WIDTH / 2) + $focustoscreen * $WIDTH ]
searchy=$[ $HEIGHT / 2 ]

# get window in that position
window=`getwindowat $searchx $searchy`
# activate it
xdotool windowactivate $window
