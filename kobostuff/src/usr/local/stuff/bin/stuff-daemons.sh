#!/bin/sh
#
# $Id: stuff-daemons.sh 18745 2021-09-19 18:49:54Z NiLuJe $
#

# Handle inetd & dropbear... :)
USBNET_BASEDIR="/usr/local/niluje/usbnet"
STUFF_BUSYBOX="${USBNET_BASEDIR}/bin/busybox"
SSD_BINARY="${USBNET_BASEDIR}/sbin/start-stop-daemon"
INETD_PID="${USBNET_BASEDIR}/run/inetd.pid"
INETD_BINARY="${USBNET_BASEDIR}/usr/sbin/inetd"
INETD_CONF="${USBNET_BASEDIR}/etc/inetd.conf"
INETD_OPTS="${INETD_CONF}"
SSHD_PID="${USBNET_BASEDIR}/run/sshd.pid"

## NOTE: We default to dropbear
SSHD_BINARY="/usr/bin/dropbear"
SSHD_OPTS="-P ${SSHD_PID} -K 15"
## NOTE: Comment me out if you want dropbear to actually check passwords
SSHD_OPTS="${SSHD_OPTS} -n"
## NOTE: Uncomment if you want to limit dropbear to shared-key auth only
#SSHD_OPTS="${SSHD_OPTS} -s"

## NOTE: But we also support OpenSSH (it *will* check passwords)...
if [ -e "${USBNET_BASEDIR}/etc/USE_OPENSSH" ] ; then
	SSHD_BINARY="/usr/sbin/sshd"
	SSHD_OPTS=""

	# OpenSSH also requires an unpriviledged user account...
	if ! grep -q sshd /etc/passwd ; then
		# Should ideally be 22:22, but GID 22 is already taken, so choose the next best thing that's still < 1000...
		${STUFF_BUSYBOX} addgroup -g 122 sshd
		${STUFF_BUSYBOX} adduser -h "${USBNET_BASEDIR}/empty" -g "OpenSSH PrivSep" -s /sbin/nologin -G sshd -D -u 22 sshd
	fi

	# Make sure the permissions are sane for the sandbox...
	mkdir -p "${USBNET_BASEDIR}/empty"
	chown -R root:root "${USBNET_BASEDIR}/empty"
	chmod -R 0755 "${USBNET_BASEDIR}/empty"
fi

# An SSH/telnet server of course needs to be able to manipulate pseudoterminals...
# Why that's not already done as part of Kobo's boot process beats me.
if [ ! -d "/dev/pts" ] ; then
	mkdir -p /dev/pts
	mount -t devpts devpts /dev/pts
fi

# Start our own inetd for telnetd/ftpd support
## NOTE: It might be a good idea to disable this if you intend to use open/public WiFi!
if [ ! -e "${USBNET_BASEDIR}/etc/NO_TELNET" ] ; then
	${SSD_BINARY} -q -p ${INETD_PID} -x ${INETD_BINARY} -S -- ${INETD_OPTS}
fi

# Start the sshd on its own, to avoid the initial connection delays of running it through inetd
if [ ! -e "${USBNET_BASEDIR}/etc/NO_SSH" ] ; then
	# shellcheck disable=SC2086
	${SSD_BINARY} -q -p ${SSHD_PID} -x ${SSHD_BINARY} -S -- ${SSHD_OPTS}
fi

# Done :)
exit 0

