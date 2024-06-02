#!/bin/sh
# This script sets up python and pygame

echo "Installing python and pygame libraries . . ."
ln -s /mnt/onboard/.python/bin/python /usr/bin/python
for i in /mnt/onboard/.python/pygamelibs/*; do mv $i /usr/lib; done
rm -r /mnt/onboard/.python/pygamelibs
echo "Python successfully installed!"
