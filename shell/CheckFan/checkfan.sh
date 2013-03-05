#! /bin/sh
######################################################################
# check ibm fan script                                               #
######################################################################

FAN_LEVEL=7
COUNTER=1
SLEEP=60

# disable auto-fan gest
printf "[!] disable acpi fan gest.\n"
sysctl dev.acpi_ibm.0.fan=0

while [ $COUNTER -le $FAN_LEVEL ]
do
	# set level fan
	printf "[+] fan level: $COUNTER\n"
	sysctl dev.acpi_ibm.0.fan_level="$COUNTER" 2>&1 >/dev/null
	sleep $SLEEP
	
	SPEED=$(sysctl dev.acpi_ibm.0.fan_speed \
		| awk '{ print $NF }')
	printf "[i] fan speed: $SPEED\n"
	COUNTER=$(($COUNTER+1))
done

# enable auto-fan gest
printf "[!] restore acpi fan gest\n"
sysctl dev.acpi_ibm.0.fan=1
