#!/bin/sh
#
# Uninstall KoboStuff
#
# $Id: self-destruct.sh 18638 2021-07-04 23:59:30Z NiLuJe $
#

## Where do we log?
KOBOSTUFF_LOG="/mnt/onboard/kobostuff.log"
echo "* Starting KoboStuff uninstall @ $(date +'%Y-%m-%d @ %H:%M:%S') . . ." >> "${KOBOSTUFF_LOG}"

## Start with symlinks, making sure they're actually *our* symlinks ;).
check_and_rm_link() {
	if [ ${#} -ne 2 ] ; then
		echo "Not enough args passed to check_and_rm_link!" >> "${KOBOSTUFF_LOG}"
		return 1
	fi

	# First arg is the symlink's full path (i.e., what's in $PATH)
	local cur_bin="${1}"
	# Second arg is the *folder* where the actual pointed-to binary lives
	local cur_dir="${2}"
	if [ -L "${cur_bin}" ] ; then
		echo "Symbolic link ${cur_bin} -> $( readlink "${cur_bin}" ) exists, deleting..." >> "${KOBOSTUFF_LOG}"
		local sym_bin
		sym_bin="$( readlink "${cur_bin}" )"
		if [ "${sym_bin}" = "${cur_dir}/${cur_bin##*/}" ] ; then
			rm -f "${cur_bin}" >> "${KOBOSTUFF_LOG}" 2>&1
		else
			echo "Symbolic link is not ours, skipping..." >> "${KOBOSTUFF_LOG}"
			return 1
		fi
	fi
}

# ScreenSavers stuff
for my_bin in convert inotifywait ; do
	check_and_rm_link "/usr/bin/${my_bin}" "/mnt/onboard/.niluje/linkss/bin"
done

# Python 2
for my_bin in python2.7 sqlite3 ; do
	check_and_rm_link "/usr/bin/${my_bin}" "/mnt/onboard/.niluje/python/bin"
	# Take care of the other Python symlinks if things went well..
	if [ "${my_bin}" = "python2.7" ] && [ $? -eq 0 ] ; then
		for my_py_sym in python2 python ; do
			[ -L "/usr/bin/${my_py_sym}" ] && rm -f "/usr/bin/${my_py_sym}" >> "${KOBOSTUFF_LOG}" 2>&1
		done
	fi
done

# Python 3.7
check_and_rm_link "/usr/bin/python3.7" "/mnt/onboard/.niluje/python3/bin"
# Take care of the other Python symlinks if things went well..
if [ $? -eq 0 ] ; then
	for my_py_sym in python3.7m python3 ; do
		[ -L "/usr/bin/${my_py_sym}" ] && rm -f "/usr/bin/${my_py_sym}" >> "${KOBOSTUFF_LOG}" 2>&1
	done
fi

# Python 3.8
check_and_rm_link "/usr/bin/python3.8" "/mnt/onboard/.niluje/python3/bin"
# Take care of the other Python symlinks if things went well..
if [ $? -eq 0 ] ; then
	for my_py_sym in python3 python ; do
		[ -L "/usr/bin/${my_py_sym}" ] && rm -f "/usr/bin/${my_py_sym}" >> "${KOBOSTUFF_LOG}" 2>&1
	done
fi

# Python 3.9
check_and_rm_link "/usr/bin/python3.9" "/mnt/onboard/.niluje/python3/bin"
# Take care of the other Python symlinks if things went well..
if [ $? -eq 0 ] ; then
	for my_py_sym in python3 python ; do
		[ -L "/usr/bin/${my_py_sym}" ] && rm -f "/usr/bin/${my_py_sym}" >> "${KOBOSTUFF_LOG}" 2>&1
	done
fi

# HTTPie
for my_bin in http https ; do
	check_and_rm_link "/usr/bin/${my_bin}" "/mnt/onboard/.niluje/python3/bin"
done

# USBNet stuff
for my_bin in eu-nm eu-objdump eu-readelf eu-strings fbgrab htop kindletool kindle_usbnet_addr ltrace mosh-client mosh-server rsync rsync-ssl sftp ssh ssh-add ssh-agent sshfs ssh-keygen ssh-keyscan strace nano zsh ag tmux gdb gcore gdb-add-index gdbserver objdump gprof fbink fbdepth curl evemu-describe evemu-device evemu-event evemu-play evemu-record xzdec zstd-decompress lz4 fusermount3 scanelf lddtree symtree trace perf lsblk choom lsipc lslocks jq bsdtar lftp lftpget tree dircolors b2sum file dtc ; do
	check_and_rm_link "/usr/bin/${my_bin}" "/mnt/onboard/.niluje/usbnet/bin"
done

for my_bin in zsh ; do
	check_and_rm_link "/bin/${my_bin}" "/mnt/onboard/.niluje/usbnet/bin"
done

# DropBear
for my_db_symlinks in /usr/sbin/dropbearmulti /usr/bin/dropbearmulti ; do
	check_and_rm_link "${my_db_symlinks}" "/usr/local/niluje/usbnet/bin"
	# Take care of the other dropbear symlinks if things went well...
	if [ "${my_db_symlinks}" = "/usr/bin/dropbearmulti" ] && [ $? -eq 0 ] ; then
		for my_bin in /usr/bin/dropbear /usr/bin/dbclient /usr/bin/dropbearkey /usr/bin/dropbearconvert /usr/bin/dbscp ; do
			[ -L "${my_bin}" ] && rm -f "${my_bin}" >> "${KOBOSTUFF_LOG}" 2>&1
		done
	fi
done

# BusyBox
for my_bin in /sbin/nologin ; do
	[ -L "${my_bin}" ] && [ "$(readlink "${my_bin}")" = "/usr/local/niluje/usbnet/bin/busybox" ] && rm -f "${my_bin}" >> "${KOBOSTUFF_LOG}" 2>&1
done

# OpenSSH in the rootfs
for my_bin in scp sftp ssh ssh-add ssh-agent ssh-keygen ssh-keyscan ; do
	check_and_rm_link "/usr/bin/${my_bin}" "/usr/local/niluje/usbnet/bin"
done
for my_bin in sftp-server ssh-keysign ssh-pkcs11-helper ssh-sk-helper ; do
	check_and_rm_link "/usr/libexec/${my_bin}" "/usr/local/niluje/usbnet/libexec"
done
for my_bin in sshd ; do
	check_and_rm_link "/usr/sbin/${my_bin}" "/usr/local/niluje/usbnet/sbin"
done

# fuse & old OpenSSH
for my_sbin in sshd mount.fuse3 ; do
	check_and_rm_link "/usr/sbin/${my_sbin}" "/mnt/onboard/.niluje/usbnet/sbin"
done

# gawk
check_and_rm_link "/usr/bin/gawk" "/mnt/onboard/.niluje/extensions/gawk/bin"

# OTA scripts
for my_bin in update-kobostuff python-setup usbnet-toggle ; do
	[ -L "/usr/bin/${my_bin}" ] && [ "$(readlink "/usr/bin/${my_bin}")" = "/usr/local/stuff/bin/${my_bin}.sh" ] && rm -f "/usr/bin/${my_bin}" >> "${KOBOSTUFF_LOG}" 2>&1
done

## Now we just have to remove the actual files ;).
for my_dir in /mnt/onboard/.niluje /usr/local/niluje /usr/local/stuff ; do
	[ -d "${my_dir}" ] && rm -rf "${my_dir}" >> "${KOBOSTUFF_LOG}" 2>&1
done

## Without forgetting the udev rules...
[ -f "/etc/udev/rules.d/99-stuff.rules" ] && rm -rf "/etc/udev/rules.d/99-stuff.rules" >> "${KOBOSTUFF_LOG}" 2>&1

## And we're done!
echo "* Successfully uninstalled KoboStuff @ $(date +'%Y-%m-%d @ %H:%M:%S')!" >> "${KOBOSTUFF_LOG}"
