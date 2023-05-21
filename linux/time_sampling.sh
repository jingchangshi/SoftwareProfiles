#!/bin/bash
user_time=0
for i in $(seq 1 $2)
do
  u=$( { /usr/bin/time -f "%U" $1 ; } 2>&1 )
  user_time=$(echo "scale=4;$user_time+$u" | bc)
  echo "No.$i run, the user time is ${u}s."
done
user_time=$(echo "scale=4;$user_time/$2" | bc)
echo "Time sampling $2 times, with the averaged user time ${user_time}s."