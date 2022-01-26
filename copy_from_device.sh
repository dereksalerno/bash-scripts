### This is a simple script that uses snmpget and pulls the configuration of many network devices at once. It uses a devices.txt file,
### and then drops them on a TFTP server being run on the local machine, with the resolved hostname as the name of the file. 
### (SNMP_STRING) must be change to RW String
#!/bin/bash

getHostname(){
        local hosty=`snmpget -c (SNMP_STRING) -v 2c $1 1.3.6.1.4.1.9.2.1.3.0`
        hosty=`echo "$hosty" | cut -d'"' -f 2`
        echo $hosty
}

rando=$1
host_ip = `hostname -i`

copyConfigs(){
        allIPs=()
        file='devices.txt'
        while read line; do
                allIPs+=( $line )
                echo $line
        done < $file
        for i in "${allIPs[@]}"
        do
                ip="$i"
                hostname=`getHostname $ip`
                filename="${hostname}.txt"
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.2.$rando i 1 > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.3.$rando i 4 > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.4.$rando i 1 > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.5.$rando a $host_ip > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.6.$rando s $filename > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.14.$rando i 1 > /dev/null`
                echo "Copied ${hostname} from ${ip}"
        done
}

copyConfigs
