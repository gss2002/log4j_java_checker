#!/bin/bash
LOG4J_JNDILOOKUP_217="719b34335646f58d0ca2a9b5cc7712a3"
LOG4J_CORE_217="da06f4ab7faebc965ae04d0ba92be715"
LISTOFJARS=`find / -path /hadoop/diska/hadoop/hdfs/data/current -prune -o -path /hadoop/diskb/hadoop/hdfs/data/current -prune -o -path /hadoop/diskc/hadoop/hdfs/data/current -prune -o -path /hadoop/diskd/hadoop/hdfs/data/current -prune -o -path /hadoop/diske/hadoop/hdfs/data/current -prune -o -path /hadoop/diskf/hadoop/hdfs/data/current -prune -o -path /hadoop/diskg/hadoop/hdfs/data/current -prune -o -path /hadoop/diskh/hadoop/hdfs/data/current -prune -o -path /hadoop/diski/hadoop/hdfs/data/current -prune -o  -path /hadoop/diskj/hadoop/hdfs/data/current -prune -o -path /sys -prune -o -path /proc -prune -o -type f -iname \*.jar`;
JARSWITHCLASS=""
for i in $LISTOFJARS
  do
        if [[ -f $i ]] ; then
                /bin/grep -F "log4j/core/lookup/JndiLookup.class" $i >/dev/null 2>&1
                EXISTS=`echo $?`
                if [[ "$EXISTS" == "0" ]] ; then
                        if [[ "$i" =~ "log4j-core" ]] ; then
                                md5log4j=`/bin/md5sum $i | /bin/awk '{print $1}'`
                                if [[ "$md5log4j" == "$LOG4J_CORE_217" ]] ; then
                                        echo ""
                                else
                                        echo "`hostname`::JAR::$i"
                                        JARSWITHCLASS+="${i} "
                                fi
                        else
                                if [[ -f /bin/unzip ]] ; then
                                        mkdir /tmp/_jartmp > /dev/null 2>&1
                                        JNDICLASSNAME=`/bin/unzip -l  $i | /bin/grep "log4j/core/lookup/JndiLookup" | /bin/awk '{print $NF}';`
                                        JNDICLASSONLY=`/bin/echo $JNDICLASSNAME| /bin/awk 'BEGIN {FS="/"} {print $NF}';`
                                        /bin/unzip -j -d /tmp/_jartmp $i $JNDICLASSNAME >/dev/null 2>&1
                                        classmd5sum=`/bin/md5sum /tmp/_jartmp/$JNDICLASSONLY`
                                        if [[ "$classmd5sum" == "$LOG4J_JNDILOOKUP_217" ]] ; then
                                                /bin/echo ""
                                        else
                                                if [[ -f /bin/javap ]] ; then
                                                        PATHCONDCLASSNAME=`/bin/unzip -l $i | /bin/grep "action/PathCondition" | /bin/awk '{print $NF}';` 
                                                        PATHCLASSONLY=`echo $PATHCONDCLASSNAME| awk 'BEGIN {FS="/"} {print $NF}';`
                                                        /bin/unzip -j -d /tmp/_jartmp $i $PATHCONDCLASSNAME >/dev/null 2>&1
                                                        /bin/javap -p  /tmp/_jartmp/$PATHCLASSONLY | /bin/grep "copy" | /bin/grep "PathCondition..." >/dev/null 2>&1
                                                        JAVAPEXISTS=`echo $?`
                                                        if [[ "$JAVAPEXISTS" == "0" ]] ; then
                                                                /bin/echo ""
                                                        else 
                                                                /bin/echo "`hostname`::JAR::$i"
                                                                JARSWITHCLASS+="${i} "
                                                        fi
                                                else
                                                        /bin/echo "`hostname`::JAR::$i"
                                                        JARSWITHCLASS+="${i} "                                        
                                                fi
                                        fi  
					/bin/rm -rf /tmp/_jartmp/*
                                else 
                                        /bin/echo "`hostname`::JAR::$i"
                                        JARSWITHCLASS+="${i} "    
                                fi                     
                        fi
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

mkdir /oldjars
for i3 in $JARSWITHCLASS
   do
        if [[ -f /bin/zip ]] ; then
                if [[ -f /bin/unzip ]] ; then
                        JARJNDICLASSNAME=`/bin/unzip -l  $i3 | /bin/grep -i "log4j/core/lookup/JndiLookup" | /bin/awk '{print $NF}';`
                        if [[ "$JARJNDICLASSNAME" != "" ]] ; then
                                jarname=`echo $i3 | awk 'BEGIN {FS="/"} {print $NF}';`
                                jarpath=`echo $i3 | awk 'BEGIN {FS="'$jarname'"} {print $1}'| sed 's;/;_;g'| sed 's;^_;;g';`
				jarmovepath=$jarpath""$jarname
                                /bin/cp $i3 /oldjars/$jarmovepath
                                /bin/gpg --batch -c --passphrase=`hostname -s` /oldjars/$jarmovepath
                                /bin/rm /oldjars/$jarmovepath
                                /bin/zip -q -d $i3 "$JARJNDICLASSNAME"
                                echo "`hostname`::MITIGATION::MITIGATED::$i3::$JARJNDICLASSNAME"
                        else
                                echo "`hostname`::MITIGATION::!UNABLE_TO_MITIGATE!::$i3::$"
                        fi
                else
                        echo "`hostname`::MITIGATION::!UNZIP_MISSING!::$i3"
                fi

        else
                echo "`hostname`::MITIGATION::!ZIP_MISSING!::$i3"
        fi
done
