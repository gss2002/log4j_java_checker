#!/bin/bash
LISTOFJARS=`find / -path /hadoop/diska/hadoop/hdfs/data/current -prune -o -path /hadoop/diskb/hadoop/hdfs/data/current -prune -o -path /hadoop/diskc/hadoop/hdfs/data/current -prune -o -path /hadoop/diskd/hadoop/hdfs/data/current -prune -o -path /hadoop/diske/hadoop/hdfs/data/current -prune -o -path /hadoop/diskf/hadoop/hdfs/data/current -prune -o -path /hadoop/diskg/hadoop/hdfs/data/current -prune -o -path /hadoop/diskh/hadoop/hdfs/data/current -prune -o -path /hadoop/diski/hadoop/hdfs/data/current -prune -o  -path /hadoop/diskj/hadoop/hdfs/data/current -prune -o -path /sys -prune -o -path /proc -prune -o -type f -iname \*.jar`;
JARSWITHCLASS=""
for i in $LISTOFJARS
  do
        if [[ -f $i ]] ; then
                grep -F "org/apache/logging/log4j/core/lookup/JndiLookup.class" $i >/dev/null 2>&1
                EXISTS=`echo $?`
                if [[ "$EXISTS" == "0" ]] ; then
                        echo "`hostname`::JAR::$i"
                        JARSWITHCLASS+="${i} "
                fi
        fi
  done
for i2 in $JARSWITHCLASS
   do
        PIDLOG4JCORE=`/sbin/lsof -t $i2`
        PIDOK=`echo $?`
        if [[ "$PIDOK" == "0" ]] ; then
                for PIDLSOF in $PIDLOG4JCORE
                   do
                        CMDINFO=`ps hww -o command -p $PIDLSOF | sed 's;\n;;g'`
                        USERINFO=`ps hww -o user:32 -p $PIDLSOF | sed 's;\n;;g'| sed 's; ;;g';`
                        PORTS=`/bin/netstat -anp | /bin/grep LISTEN | /bin/grep -iE "tcp|udp" | /bin/grep "$PIDLSOF/"| /bin/awk '{print $4}'| /bin/xargs | /bin/sed 's; ;|;g'| /bin/sed 's;:::;;g';`
                        if [[ "$PORTS" == "" ]] ; then
                                echo "`hostname`::PROC::$PIDLSOF::$i2::no_ports::$USERINFO::$CMDINFO"
                        else
                                echo "`hostname`::PROC::$PIDLSOF::$i2::$PORTS::$USERINFO::$CMDINFO"
                        fi
                done
        fi
done
