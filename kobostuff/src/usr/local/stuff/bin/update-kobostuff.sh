#!/bin/sh
#
# Update KoboStuff components OTA
#
# $Id: update-kobostuff.sh 18668 2021-08-03 18:37:41Z NiLuJe $
#
##

# OTA utils
. "/usr/local/stuff/lib/libotautils"

# Various pre-update checks & cleanups
ota_enough_free_space() {
	if [ $# -ne 1 ] ; then
		echo "* ota_enough_free_space expects a component name!"
		return 1
	fi

	local COMP_NAME="${1}"

	case "${COMP_NAME}" in
		"Core" )
			# NOTE: Actual content currently requires slightly north of 50MB
			if ! enough_free_space "75" "/mnt/onboard" ; then
				echo "* Not enough free space available on /mnt/onboard! (~75MB required)"
				return 1
			fi
		;;
		"Python3" | "Python2" )
			# NOTE: Actual content currently requires slightly north of 150MB (w/ bytecode)
			if ! enough_free_space "200" "/mnt/onboard" ; then
				echo "* Not enough free space available on /mnt/onboard! (~200MB required)"
				return 1
			fi
		;;
		"Git" )
			# NOTE: Actual content currently requires ~6MB
			if ! enough_free_space "12" "/" ; then
				echo "* Not enough free space available on the rootfs (~12MB required)"
				return 1
			fi
		;;
		* )
			echo "Invalid component name!"
			return 1
		;;
	esac

	return 0
}

## Pilfered from KoboStuff/uninstall/usr/local/stuff/bin/self-destruct.sh
check_and_rm_link() {
	if [ ${#} -ne 2 ] ; then
		echo "* Not enough args passed to check_and_rm_link!"
		return 1
	fi

	# First arg is the symlink's full path (i.e., what's in $PATH)
	local cur_bin="${1}"
	# Second arg is the *folder* where the actual pointed-to binary lives
	local cur_dir="${2}"
	if [ -L "${cur_bin}" ] ; then
		echo "Symbolic link ${cur_bin} -> $( readlink "${cur_bin}" ) exists, deleting..."
		local sym_bin
		sym_bin="$( readlink "${cur_bin}" )"
		if [ "${sym_bin}" = "${cur_dir}/${cur_bin##*/}" ] ; then
			rm -f "${cur_bin}"
		else
			echo "Symbolic link is not ours, skipping..."
			return 1
		fi
	fi
}

ota_pkg_prepare() {
	if [ $# -ne 1 ] ; then
		echo "* check_pkg_prepare expects a component name!"
		return 1
	fi

	local COMP_NAME="${1}"
	local PKG_HOME

	case "${COMP_NAME}" in
		"Core" )
			PKG_HOME="/mnt/onboard/.niluje"
			do_msg "[KS] Clearing out previous ZSH setup . . ."
			rm -rf "${PKG_HOME}/usbnet/share/zsh"

			# Remove deprecated binaries
			for usbnet_lib in libbfd-2.34.0.so libbfd-2.35.0.so libbfd-2.35.1.so libbfd-2.36.0.so libbfd-2.36.1.so libcrypto.so.1.0.0 libebl_aarch64.so libebl_arm.so libevent-2.1.so.5 libevent-2.1.so.6 libevent_core-2.1.so.5 libevent_core-2.1.so.6 libevent_extra-2.1.so.5 libevent_extra-2.1.so.6 libevent_openssl-2.1.so.5 libevent_openssl-2.1.so.6 libevent_pthreads-2.1.so.5 libevent_pthreads-2.1.so.6 libopcodes-2.34.0.so libopcodes-2.35.0.so libopcodes-2.35.1.so libopcodes-2.36.0.so libopcodes-2.36.1.so libssl.so.1.0.0 libpcre2-posix.so.2 libz.so ; do
				rm -rf "${PKG_HOME}/usbnet/lib/${usbnet_lib}"
			done
			for linkfonts_lib in libz.so ; do
				rm -rf "${PKG_HOME}/linkfonts/lib/${linkfonts_lib}"
			done
			for linkss_lib in libMagickCore-6.Q8.so.6 libMagickWand-6.Q8.so.6 libz.so ; do
				rm -rf "${PKG_HOME}/linkss/lib/${linkss_lib}"
			done
		;;
		"Python3" )
			PKG_HOME="/mnt/onboard/.niluje/python3"
			do_msg "[KS] Clearing out previous ${COMP_NAME} setup . . ."
			rm -rf "${PKG_HOME}"

			# Take care of deprecated symlinks, too
			# Python 3.7
			check_and_rm_link "/usr/bin/python3.7" "${PKG_HOME}/bin"
			# Take care of the other Python symlinks if things went well..
			if [ $? -eq 0 ] ; then
				for my_py_sym in python3.7m python3 ; do
					[ -L "/usr/bin/${my_py_sym}" ] && rm -f "/usr/bin/${my_py_sym}"
				done
			fi

			# Python 3.8
			check_and_rm_link "/usr/bin/python3.8" "${PKG_HOME}/bin"
			# Take care of the other Python symlinks if things went well..
			if [ $? -eq 0 ] ; then
				for my_py_sym in python3 python ; do
					[ -L "/usr/bin/${my_py_sym}" ] && rm -f "/usr/bin/${my_py_sym}"
				done
			fi
		;;
		"Python2" )
			PKG_HOME="/mnt/onboard/.niluje/python"
			do_msg "[KS] Clearing out previous ${COMP_NAME} setup . . ."
			rm -rf "${PKG_HOME}"
		;;
		"Git" )
			# NOP
		;;
		* )
			echo "Invalid component name!"
			return 1
		;;
	esac
}

# Check if a component is up-to-date
check_pkg_for_update() {
	if [ $# -ne 1 ] ; then
		echo "* check_pkg_for_update expects a component name!"
		return 1
	fi

	local COMP_NAME="${1}"
	# Match that to the actual package filename...
	local PKG_NAME
	local PKG_HOME
	local PKG_TAG
	case "${COMP_NAME}" in
		"Core" )
			PKG_NAME="KoboStuff-Core"
			PKG_HOME="/mnt/onboard/.niluje"
			PKG_TAG="${PKG_HOME}/REVISION"
		;;
		"Python3" )
			PKG_NAME="KoboStuff-Python3"
			PKG_HOME="/mnt/onboard/.niluje/python3"
			PKG_TAG="${PKG_HOME}/REVISION"
		;;
		"Python2" )
			PKG_NAME="KoboStuff-Python2"
			PKG_HOME="/mnt/onboard/.niluje/python"
			PKG_TAG="${PKG_HOME}/REVISION"
		;;
		"Git" )
			PKG_NAME="Kobo-git"
			PKG_HOME="/mnt/onboard/.niluje/git"
			PKG_TAG="${PKG_HOME}/REVISION"
		;;
		* )
			echo "Invalid component name!"
			return 1
		;;
	esac

	local IS_UP_TO_DATE="true"
	do_msg "[KS] Checking for ${COMP_NAME} updates . . ."

	# If it's not installed, it's outdated
	if [ ! -f "${PKG_TAG}" ] ; then
		IS_UP_TO_DATE="false"
	fi

	# If there's a local package, use it without checking the index
	# NOTE: That's a shortcut to allow pushing the file over USBNet in case WiFi connectivity is not great...
	#       I usually do that in a tmpfs to spare the poor internal storage...
	#       i.e., mount -t tmpfs tmpfs /mnt/niluje -o defaults,size=128M,mode=1777,noatime
	for pkg_file in /mnt/niluje/"${PKG_NAME}"-r*.tar.zst ; do
		if [ -f "${pkg_file}" ] ; then
			# Check that we have enough free space left, first
			if ! ota_enough_free_space "${COMP_NAME}" ; then
				# Abort, the error has already been printed
				return 1
			fi

			# Do whatever we might need to before the install
			ota_pkg_prepare "${COMP_NAME}"

			do_msg "[KS] Found a local package! Installing it..."
			bsdtar -xvf "${pkg_file}" -C /
			local RET=$?

			if [ ${RET} -eq 0 ] ; then
				# Cleanup on success
				do_msg "[KS] Success! :)"
				rm -f "${pkg_file}"
			else
				do_msg "[KS] Uh oh! :("
				echo "* Something went wrong... ${COMP_NAME} functionality may be impaired!"
			fi

			return ${RET}
		fi
	done

	# Check the local version (if we have one) against the OTA index
	if [ "${IS_UP_TO_DATE}" = "true" ] ; then
		local LOCAL_REV
		LOCAL_REV="$(cat "${PKG_TAG}")"

		if ! is_integer "${LOCAL_REV}" ; then
			echo "* Failed to compute local revision for '${COMP_NAME}'!"
			return 1
		fi

		# Download the OTA index, we'll need it
		echo "* Downloading the OTA index . . ."
		if ! get_ota_index ; then
			# Abort, the error has already been printed
			return 1
		fi
		echo ""

		local TARGET_REV
		TARGET_REV="$(get_pkg_revision "${PKG_NAME}")"
		local RET=$?
		if [ "${RET}" -eq 1 ] ; then
			# Something went wrong, abort after printing the actual error
			echo "${TARGET_REV}"
			return 1
		fi

		if [ "${TARGET_REV}" -gt "${LOCAL_REV}" ] ; then
			IS_UP_TO_DATE="false"
			do_msg "[KS] Updating ${COMP_NAME} from r${LOCAL_REV} to r${TARGET_REV}"
			echo ""
		else
			echo "* ${COMP_NAME} is already up to date! (local: r${LOCAL_REV} vs. remote: r${TARGET_REV})"
		fi
	fi

	# If it's outdated, update
	if [ "${IS_UP_TO_DATE}" = "false" ] ; then
		echo "* Please be aware this might take a while!"
		echo "* I'd recommend having enabled ForceWifi to prevent Nickel from turning the Wifi off."
		echo "* Alternatively, keeping the Wifi tooltip open should do the job in a pinch ;)."
		echo ""
		echo "* You might also want to run this in a tmux session to avoid random SSH mishaps..."
		echo ""

		# If this is a fresh install, we haven't yet downloaded the OTA index...
		if [ ! -f "${OTA_INDEX}" ] ; then
			echo "* Downloading the OTA index . . ."
			if ! get_ota_index ; then
				# Abort, the error has already been printed
				return 1
			fi
			echo ""
		fi

		local TARGET_URL
		TARGET_URL="$(get_pkg_url "${PKG_NAME}")"
		local RET=$?
		if [ "${RET}" -eq 1 ] ; then
			# Something went wrong, abort after printing the actual error
			echo "${TARGET_URL}"
			return 1
		fi

		# If it's a fresh install, TARGET_REV is still unset...
		if [ -z "${TARGET_REV}" ] ; then
			local TARGET_REV
			TARGET_REV="$(get_pkg_revision "${PKG_NAME}")"
			local RET=$?
			if [ "${RET}" -eq 1 ] ; then
				# Something went wrong, abort after printing the actual error
				echo "${TARGET_REV}"
				return 1
			fi
		fi

		# Check if the target URL is available, first...
		if ! curl --location --output /dev/null --silent --head --fail "${TARGET_URL}" ; then
			echo "* Failed to download the OTA package for ${COMP_NAME} r${TARGET_REV}!"
			return 1
		fi

		# Check that we have enough free space left, first
		if ! ota_enough_free_space "${COMP_NAME}" ; then
			# Abort, the error has already been printed
			return 1
		fi

		# Compute the package's timestamp
		local TARGET_DATE
		TARGET_DATE="$(get_pkg_date "${PKG_NAME}")"
		local RET=$?
		if [ "${RET}" -eq 1 ] ; then
			# Something went wrong, abort after printing the actual error
			echo "${TARGET_DATE}"
			return 1
		fi
		# It's an Epoch, format it in the local timezone...
		TARGET_DATE="$(date -d "@${TARGET_DATE}" +"%F %T")"

		# Do whatever we might need to before the install
		ota_pkg_prepare "${COMP_NAME}"
		echo ""
		do_msg "[KS] Installing ${COMP_NAME} r${TARGET_REV} (${TARGET_DATE}) . . ."

		curl --location --fail "${TARGET_URL}" | bsdtar -xf - -C /
		local RET=$?
		echo ""

		# NOTE: Remember, we don't have pipefail, so, take this with a grain of salt, and check the output...
		if [ ${RET} -eq 0 ] ; then
			do_msg "[KS] Success! :)"
			case "${COMP_NAME}" in
				"Core" )
					echo "* You may now reboot if you wish to do so, but it is entirely optional, unless you *really* want to re-start the sshd"
				;;
				"Python3" | "Python2" )
					echo "* You can now run python-setup in order to generate optimized Python bytecode!"
				;;
				* )
					# NOP
				;;
			esac
		else
			do_msg "[KS] Uh oh! :("
			echo "* Something went wrong... ${COMP_NAME} functionality may be impaired!"
		fi

		return ${RET}
	fi
}

# Choose your poison
if [ $# -ne 1 ] ; then
	echo ""
	echo "* update-kobostuff expects to be passed the name of the component to update!"
	echo "* Available components: Core, Python3, Python2 or Git"

	exit 1
fi

COMPONENT_NAME="${1}"
RC=0

case "${COMPONENT_NAME}" in
	"Core" | "core" | "USBNet" | "usbnet" )
		# Update the Core tools
		check_pkg_for_update "Core"
		RC=$?
	;;
	"Python" | "python" | "Python3" | "python3" | "Py3" | "py3" )
		# Update Python 3
		check_pkg_for_update "Python3"
		RC=$?
	;;
	"Python2" | "python2" | "Py2" | "py2" )
		# Update Python 2
		check_pkg_for_update "Python2"
		RC=$?
	;;
	"Git" | "git" )
		# Update Git
		check_pkg_for_update "Git"
		RC=$?
	;;
	* )
		echo ""
		echo "Invalid component name!"
		exit 1
	;;
esac

# Clean the workdir
ota_cleanup

# Always finish with a flush to disk...
echo ""
do_msg "[KS] Flushing to storage device . . ."
sync
do_msg "[KS] Done!"

# Exit with the return code from check_pkg_for_update
return ${RC}
