 #!/bin/bash

# do not end this directory specification with a slash (/)
DIR=/tmp/cisco

# add "-y" to the command-line to auto-confirm folder cleanup
yesflag=$1 

if [ "$USER" != 'root' ]; then
	echo "You must be root for this operation."
	exit 1
fi
if [ -d "$DIR" ]; then
	echo "$DIR detected. Refusing to overwrite it."
	exit 2;
fi
echo Starting Cisco OS log collection...
mkdir "$DIR" && \
echo "journalctl" && journalctl >"$DIR"/journalctl.log
echo "dmesg -T" && dmesg -T >"$DIR"/dmesg-T.log
echo "lsmod" && lsmod >"$DIR"/lsmod.log
echo "lsblk" && lsblk >"$DIR"/lsblk.log
echo "fdisk -l" && fdisk -l >"$DIR"/fdisk-l.log
echo "ps -ef" && ps -ef > "$DIR"/ps-ef.log
echo "boot.log*" && cp -i /var/log/boot.log* "$DIR"/
echo "kern.log*" && cp -i /var/log/kern.log* "$DIR"/
echo "messages*" && cp -i /var/log/messages* "$DIR"/
echo "syslog*" && cp -i /var/log/syslog* "$DIR"/

## if doing drive log stuff...
#echo "drivelogs"
# TBD
#echo "Ok."
#ls -l "$DIR"/drivelogs

## if doing iostat logs...
#echo -e "================================================
#ATTENTION: YOU MUST NOW MANUALLY OBTAIN THE IOSTAT LOGS
#command: timeout 12m iostat -xcdt -g All | tee "$DIR"/iostat.log
#================================================"

echo "Compressing $DIR..."
tar czf "$DIR".tar.gz "$DIR"

if [ "$?" -eq 0 ]; then
    echo "Success."
    if [ "$yesflag" = '-y' ]; then
	echo "Remove temporary directory $DIR? [y/n]"
	read line
    else
	line='y'
    fi
    if [ "$line" = 'y' ]; then
	rm -rf "$DIR"
    fi
    echo "All done. Logfile is here:"
    ls -l "$DIR".tar.gz
else
    echo "Compression failed. $DIR was not removed."
    exit 3
fi
