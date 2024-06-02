#!/bin/sh
#
# Build/Rebuild Python bytecode for the stdlib & third-party modules
#
# $Id: python-setup.sh 18405 2021-04-07 17:05:49Z NiLuJe $
#
##

# OTA utils
. "/usr/local/stuff/lib/libotautils"

# Where the wild things are
PY2HOME="/mnt/onboard/.niluje/python"
PY2VER="2.7"
PY3HOME="/mnt/onboard/.niluje/python3"
PY3VER="3.9"

# Make sure we have enough free space left on the userstore (>250MB)
# That's exactly the amount of space it will take *after* compilation.
# Some of that is currently already in use by the minimal distribution straight out of the installer,
# so this should leave us with some breathing room ;).
if [ "$(df -k /mnt/onboard | awk '$3 ~ /[0-9]+/ { print $4 }')" -lt "256000" ] ; then
	do_msg "[Py] Not enough free space! :("

	return 1
fi

# Check if we actually need to do anything (i.e., when source is newer than bytecode)
# Python 2
COMPILE_PY2="true"
if [ -d "${PY2HOME}" ] ; then
	my_python_iolib="${PY2HOME}/lib/python${PY2VER}/io"
	if [ -e "${my_python_iolib}.pyc" ] ; then
		if [ "${my_python_iolib}.pyc" -nt "${my_python_iolib}.py" ] ; then
			do_msg "[Py2] Bytecode is already up to date! :)"

			COMPILE_PY2="false"
		fi
	fi
else
	do_msg "[Py2] Not installed, skipping!"
	COMPILE_PY2="false"
fi

# Fudge the progress steps if we don't do Python 2...
if [ "${COMPILE_PY2}" = "false" ] ; then
	STEPCOUNT=$((STEPCOUNT - 4))
fi

# Python 3
COMPILE_PY3="true"
if [ -d "${PY3HOME}" ] ; then
	my_python_iolib="${PY3HOME}/lib/python${PY3VER}/io"
	if [ -e "${my_python_iolib}.pyc" ] ; then
		if [ "${my_python_iolib}.pyc" -nt "${my_python_iolib}.py" ] ; then
			do_msg "[Py3] Bytecode is already up to date! :)"

			COMPILE_PY3="false"
		fi
	fi
else
	do_msg "[Py3] Not installed, skipping!"
	COMPILE_PY3="false"
fi

# Fudge the progress steps if we don't do Python 3...
if [ "${COMPILE_PY3}" = "false" ] ; then
	STEPCOUNT=$((STEPCOUNT - 4))
fi

# If no Python is installed, point to the install script...
if [ "${COMPILE_PY3}" = "false" ] && [ "${COMPILE_PY2}" = "false" ] ; then
	do_msg "[Py] Python is not installed, run update-kobostuff to do so!"

	return 0
fi

# Most people will never call python w/ -O or -OO set (and/or set the PYTHONOPTIMIZE env var), so skip optimized bytecode compilation by default to save time and I/O.
if [ "${COMPILE_PY2}" = "true" ] ; then
	if [ -z "${PYTHONOPTIMIZE}" ] ; then
		STEPCOUNT=$((STEPCOUNT - 2))
	fi
fi
if [ "${COMPILE_PY3}" = "true" ] ; then
	if [ -z "${PYTHONOPTIMIZE}" ] ; then
		STEPCOUNT=$((STEPCOUNT - 2))
	fi
fi

# Here we go...
if [ "${COMPILE_PY2}" = "true" ] ; then
	# Python 2
	do_msg "[Py2] Compiling bytecode (std)"
	do_progress
	${PY2HOME}/bin/python${PY2VER} -m compileall -f -x 'bad_coding|badsyntax|site-packages|lib2to3/tests/data|test|tests' ${PY2HOME}/lib/python${PY2VER}
	if [ -n "${PYTHONOPTIMIZE}" ] ; then
		do_msg "[Py2] Compiling bytecode (std:opt)"
		do_progress
		${PY2HOME}/bin/python${PY2VER} -OO -m compileall -f -x 'bad_coding|badsyntax|site-packages|lib2to3/tests/data|test|tests' ${PY2HOME}/lib/python${PY2VER}
	fi
	do_msg "[Py2] Compiling bytecode (ext)"
	do_progress
	${PY2HOME}/bin/python${PY2VER} -m compileall -f -x badsyntax ${PY2HOME}/lib/python${PY2VER}/site-packages
	if [ -n "${PYTHONOPTIMIZE}" ] ; then
		do_msg "[Py2] Compiling bytecode (ext:opt)"
		do_progress
		${PY2HOME}/bin/python${PY2VER} -OO -m compileall -f -x badsyntax ${PY2HOME}/lib/python${PY2VER}/site-packages
	fi
fi

if [ "${COMPILE_PY3}" = "true" ] ; then
	do_msg "[Py3] Compiling bytecode (std)"
	do_progress
	${PY3HOME}/bin/python${PY3VER} -m compileall -f -x 'bad_coding|badsyntax|site-packages|lib2to3/tests/data|test|tests' ${PY3HOME}/lib/python${PY3VER}
	if [ -n "${PYTHONOPTIMIZE}" ] ; then
		do_msg "[Py3] Compiling bytecode (std:opt)"
		do_progress
		${PY3HOME}/bin/python${PY3VER} -OO -m compileall -o 1 -o 2 -f -x 'bad_coding|badsyntax|site-packages|lib2to3/tests/data|test|tests' ${PY3HOME}/lib/python${PY3VER}
	fi
	do_msg "[Py3] Compiling bytecode (ext)"
	do_progress
	${PY3HOME}/bin/python${PY3VER} -m compileall -f -x badsyntax ${PY3HOME}/lib/python${PY3VER}/site-packages
	if [ -n "${PYTHONOPTIMIZE}" ] ; then
		do_msg "[Py3] Compiling bytecode (ext:opt)"
		do_progress
		${PY3HOME}/bin/python${PY3VER} -OO -m compileall -o 1 -o 2 -f -x badsyntax ${PY3HOME}/lib/python${PY3VER}/site-packages
	fi
fi

# Flush to disk
do_msg "[Py] Flushing to storage device"
do_progress
sync

# Bye now!
do_msg "[Py] All done :)"
do_progress

# NOTE: Document pip usage... (*NOT* recommended!)
if [ "${COMPILE_PY3}" = "true" ] ; then
	# NOTE: Technically available on Python 2.7, too, but let's not encourage that...
	echo ""
	echo "If you *absolutely* need to, pip can be bootstrapped and updated."
	echo "This is *NOT* recommended, as it will only be able to install pure-python modules (as there is no available C/C++ compiler)."
	echo "In addition to that, any extra third-party modules will be *lost* during a Python update!"
	echo "As for the user site-packages, remember that by default HOME is either in a tmpfs, or, worse, the rootfs..."
	echo "TL;DR: Don't do this unless you *know* what you're doing!"
	echo ""
	echo "That said..."
	echo "Boostrapping pip:"
	echo "python${PY3VER} -m ensurepip"
	echo "Updating pip:"
	echo "${PY3HOME}/bin/pip${PY3VER} install -U setuptools pip"
	echo "Symlinking pip into PATH"
	echo "ln -sf ${PY3HOME}/bin/pip /usr/bin/pip"
	echo ""
fi

return 0
