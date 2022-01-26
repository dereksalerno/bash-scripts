### This is a simple script that will take a list of IP addresses (devices.txt) and use SNMPv2 to change the configuration 
### of Cisco devices. As long as the SNMP admin string is known, this is a much faster way to make changes on many devices
### than using an automated SSH script. It uses the snmpset binary.

#!/bin/bash

if command -v snmpset >/dev/null 2>&1 ; then
    echo "snmpset found"
else
    echo "snmp not found"
fi

getHostname(){
        local hosty=`snmpget -c (SNMP_STRING) -v 2c $1 1.3.6.1.4.1.9.2.1.3.0`
        hosty=`echo "$hosty" | cut -d'"' -f 2`
        echo $hosty
}

rando=$1

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
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.3.$rando i 1 > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.4.$rando i 4 > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.5.$rando a 10.9.50.225 > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.6.$rando s config_change.txt > /dev/null`
                `/usr/bin/snmpset -c (SNMP_STRING) -v 2c $ip 1.3.6.1.4.1.9.9.96.1.1.1.1.14.$rando i 1 > /dev/null`
                echo "Changed ${hostname} on ${ip}"
        done
}

copyConfigs
