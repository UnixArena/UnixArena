#!/usr/bin/bash
# Solaris SPARC/X86 Memory Statistics  report script version 0.12
echo "=========================================="
echo "It works on Solaris 10 and ealier versions"
echo "Thank you for using UnixArena script"
echo "=========================================="
swap -l |awk '{ print $4 }'|grep -v blocks > temp.swapl
swap -l |awk '{ print $5}'|grep -v free > free.swap1
MEM=$(echo `echo '::memstat' | mdb -k |tail -1|awk '{ print $3 }'` "*" "1024"|bc)
SWP=$(echo $(tr -s '\n' '+' < temp.swapl)0 | bc)
TSWP=$(echo "$SWP" "/" "2" |bc)
TOTALVS=$(echo "$MEM" "+" "$TSWP" |bc)
echo "Total Physical Memory = $(echo "$MEM" "/" "1024" "/" "1024" |bc) GB"
echo "Total Swap Space = $(echo "$TSWP" "/" "1024" "/" "1024" |bc) GB"
echo "Total Virtual storage space(Physical + Swap) = $(echo "$TOTALVS" "/" "1024" "/" "1024" |bc) GB"
FREEVS=$(echo `vmstat 1 2 |tail -1|awk ' { print $4 } '` "+" `vmstat 1 2 |tail -1|awk ' { print $5 } '` |bc)
echo "Free Physical Memory = $(echo "scale=2;`vmstat 1 2 |tail -1|awk ' { print $5 } '` "/" "1024" "/" "1024" "|bc) GB"
echo "Free Swap = $(echo "scale=2;`awk '{total += $NF} END { print total }' free.swap1` "/" "2" "/" "1024" "/" "1024" "|bc) GB"
echo "Free Virtual storage space(Free Physical + Free Swap) = $(echo "$FREEVS" "/" "1024" "/" "1024" |bc) GB"
FREEVSP=$(echo "scale=2;$FREEVS*100/$TOTALVS" |bc)
echo "Free Virtual storage Percentage = $FREEVSP % "
FREEVSPR=$(echo $FREEVSP|cut -c 1-2)
rm temp.swapl
if [[ "$FREEVSPR" -gt 15 ]]
then
echo "System is running with enough virtual storage space(Free virtual storage space $FREEVSP %)"
exit 0
echo "========"
echo "GOOD BYE"
echo "========"
else
echo " UnixArena:`uname -n` : os: The percentage of available storage space is low ($FREEVSP percent)"
exit 1
echo "========"
echo "GOOD BYE"
echo "========"
fi
#Created by Lingeswaran Rangasamy (Email: lingeshwaran.rangasamy@gmail.com)(Website: www.unixarena.com)
