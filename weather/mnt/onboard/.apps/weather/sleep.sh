#!/bin/sh

h=`date +%H`
timestp=$((`date +%s`/3600))
if [ "$h" -ge 20 ]; then 
		multi=24-$h 
		let timestp+=7 
		let timestp+=$multi 
elif [ "$h" -lt 7 ]; then 
		multi=7-$h 
		let timestp+=$multi 
else let timestp+=1 
fi 
timestp=$((timestp * 3600 - 3600 + 10*60)) 
/bin/busybox rtcwake -a -m mem -t $timestp
