#!/bin/bash

# 2016 ROBERT WOLTERMAN (xtacocorex)
# WITH HELP FROM CHIP-hwtest/battery.sh

# MIT LICENSE, SEE LICENSE FILE

# LOGGING HAT-TIP TO http://urbanautomaton.com/blog/2014/09/09/redirecting-bash-script-output-to-syslog/

# THIS NEEDS TO BE RUN AS ROOT
# PROBABLY SET AS A CRON JOB EVERY 5 OR 10 MINUTES

# SIMPLE SCRIPT TO POWER DOWN THE CHIP BASED UPON BATTERY VOLTAGE

# CHANGE THESE TO CUSTOMIZE THE SCRIPT
# ****************************
# ** THESE MUST BE INTEGERS **
MINVOLTAGELEVEL=3100
MINCHARGECURRENT=10
# ****************************

readonly SCRIPT_NAME=$(basename $0)

log() {
    echo "`date -u`" "$@"
    #logger -p user.notice -t $SCRIPT_NAME "$@"
}

# TALK TO THE POWER MANAGEMENT
/usr/sbin/i2cset -y -f 0 0x34 0x82 0xC3

# GET POWER OP MODE
POWER_OP_MODE=$(/usr/sbin/i2cget -y -f 0 0x34 0x01)

# SEE IF BATTERY EXISTS
BAT_EXIST=$(($(($POWER_OP_MODE&0x20))/32))

if [ $BAT_EXIST == 1 ]; then
    
    log "CHIP HAS A BATTERY ATTACHED"
    BAT_VOLT_MSB=$(/usr/sbin/i2cget -y -f 0 0x34 0x78)
    BAT_VOLT_LSB=$(/usr/sbin/i2cget -y -f 0 0x34 0x79)
    BAT_BIN=$(( $(($BAT_VOLT_MSB << 4)) | $(($(($BAT_VOLT_LSB & 0x0F)) )) ))
    BAT_VOLT_FLOAT=$(echo "($BAT_BIN*1.1)"|bc)
    # CONVERT TO AN INTEGER
    BAT_VOLT=${BAT_VOLT_FLOAT%.*}
        
    # CHECK BATTERY LEVEL AGAINST MINVOLTAGELEVEL
    if [ $BAT_VOLT -le $MINVOLTAGELEVEL ]; then
        log "CHIP BATTERY VOLTAGE IS LESS THAN $MINVOLTAGELEVEL"
        log "CHECKING FOR CHIP BATTERY CHARGING"
        # GET THE CHARGE CURRENT
        BAT_ICHG_MSB=$(/usr/sbin/i2cget -y -f 0 0x34 0x7A)
        BAT_ICHG_LSB=$(/usr/sbin/i2cget -y -f 0 0x34 0x7B)
        BAT_ICHG_BIN=$(( $(($BAT_ICHG_MSB << 4)) | $(($(($BAT_ICHG_LSB & 0x0F)) )) ))
        BAT_ICHG_FLOAT=$(echo "($BAT_ICHG_BIN*0.5)"|bc)
        # CONVERT TO AN INTEGER
        BAT_ICHG=${BAT_ICHG_FLOAT%.*}
    
        # IF CHARGE CURRENT IS LESS THAN MINCHARGECURRENT, WE NEED TO SHUTDOWN
        if [ $BAT_ICHG -le $MINCHARGECURRENT ]; then
            log "CHIP BATTERY IS NOT CHARGING, SHUTTING DOWN NOW"
            shutdown -h now
        else
            log "CHIP BATTERY IS CHARGING"
        fi
    else
        log "CHIP BATTERY LEVEL IS GOOD"
    fi

fi

