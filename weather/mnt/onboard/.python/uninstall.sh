#!/bin/sh
read -p "Are you sure you want to remove python? (y/n): " sure
if [ $sure == "y" ]
then
    echo "Removing libs . . ."
    for i in `cat /mnt/onboard/.python/pygamelibs.txt`;
    do
        rm /usr/lib/$i
    done
    echo "Removing python . . ."
    rm -r /mnt/onboard/.python
    rm /usr/bin/python

    echo "Python successfully uninstalled!"
else
    echo "Python was not removed."
fi
