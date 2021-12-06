#!/bin/ksh

        echo
        echo "\t  DISK\t\t\t  ZPOOL\t\t\tSIZE"
        echo "\t--------------------------------------------------------"

DISKLIST="/tmp/disklist"
ZPOOLLIST="/tmp/zpoollist"

        ls /dev/dsk/* | sed "s/\/dev\/dsk\///" | grep s2 | sed "s/s2//" > ${DISKLIST}

        zpool import 2>/dev/null | \
                grep LINE | grep -v state | grep -v pool | grep -v raid | grep -v mirror \
                > ${ZPOOLLIST}
        zpool status | \
                grep LINE | grep -v state | grep -v pool | grep -v raid | grep -v mirror \
                >> ${ZPOOLLIST}

        for DISK in `cat ${DISKLIST} | grep -v c0 | grep -v c1t | awk -F' ' '{print $1}'`
        do
                        SIZEABLE="0"
                        if [ -L /dev/rdsk/${DISK}s2 ]; then
                           SIZEABLE=`prtvtoc /dev/rdsk/${DISK}s2 | grep -v "*" | grep "       2      " | wc -l`
                           if [ ${SIZEABLE} == 1 ]; then
                              SECTORS=`prtvtoc /dev/rdsk/${DISK}s2 | grep -v "*" | grep "       2      " | awk -F' ' '{print $5}'`
                              (( SIZE = ${SECTORS} * 512 / 1073741824 ))
                           else
                              SIZE="Unknown"
                           fi
                        fi

                MATCHES=`fgrep ${DISK} ${ZPOOLLIST} | wc -l`
                if [ "${MATCHES}" -eq "0" ]; then
                        echo "\t${DISK}\t<- available ->\t\t${SIZE}GB"
#                       echo "q" | format ${DISK} | grep ZFS
                else
                        LOCAL=`echo "q" | format ${DISK} 2>&1 | grep ZFS | wc -l`
                        if [ ${LOCAL} == 1 ]; then
                                echo "q" | format ${DISK} 2>&1 | grep ZFS > /tmp/file
                                cat /tmp/file | sed "s/\/dev\/dsk\///" | sed "s/ Please see zpool\(1M\).//" > /tmp/file2
                                DISK="`cat /tmp/file2 | awk -F' ' '{print $1}' | sed "s/s0//"`"
                                POOL="`cat /tmp/file2 | awk -F' ' '{print $8}' | awk -F'.' '{print $1"."$2}'`"
                                echo "\t${DISK}\t<  in use in ${POOL}  >"
                        else
                                echo "\t${DISK}\t<  in use on alternate host  >"
                        fi
                fi
        done

rm ${DISKLIST}
rm ${ZPOOLLIST}
rm /tmp/file
rm /tmp/file2

exit 0
