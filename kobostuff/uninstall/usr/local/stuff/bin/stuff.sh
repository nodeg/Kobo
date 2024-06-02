#!/bin/sh
#
# $Id: stuff.sh 16525 2019-10-04 17:30:35Z NiLuJe $
#

# Start by renicing ourselves to a neutral value, to avoid any mishap...
renice 0 -p $$

# I run early at boot! Do fun stuff here!
# NOTE: onboard *should* be mounted by that point, but if you want to be safe, double-check.
# NOTE: Remember to keep things short & sweet, because we're blocking udev here...
#       Background your stuff if you need to run long-lasting tasks.

## Engage self-destruct procedure ;)
/usr/local/stuff/bin/self-destruct.sh &

# Done :)
exit 0
