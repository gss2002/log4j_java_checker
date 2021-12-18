#!/bin/bash
JAVALIST=`/usr/bin/find / -path /hadoop/diska/hadoop/hdfs/data/current -prune -o -path /hadoop/diskb/hadoop/hdfs/data/current -prune -o -path /hadoop/diskc/hadoop/hdfs/data/current -prune -o -path /hadoop/diskd/hadoop/hdfs/data/current -prune -o -path /hadoop/diske/hadoop/hdfs/data/current -prune -o -path /hadoop/diskf/hadoop/hdfs/data/current -prune -o -path /hadoop/diskg/hadoop/hdfs/data/current -prune -o -path /hadoop/diskh/hadoop/hdfs/data/current -prune -o -path /hadoop/diski/hadoop/hdfs/data/current -prune -o  -path /hadoop/diskj/hadoop/hdfs/data/current -prune -o -path /sys -prune -o -path /proc -prune -o -type f -name java`
for java in $JAVALIST
    do 
        if [[ -f "$java" ]] ; then
            if [[ -x "$java" ]] ; then
                echo "`hostname`::JAVA::$java::`$java -fullversion 2>&1 | sed 's;\n;;g'`"
            fi
        fi
done
