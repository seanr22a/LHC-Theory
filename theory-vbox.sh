#!/bin/bash
#################################################
#
# 2026-05-05 11:38 Asia/Bangkok
# seanr22a@hotmail.com
#
# theory-vbox.sh
#
# Status script for LHC Boinc project Theory/vbox
#
#################################################

DATE=$(date +"%Y-%m-%d %H:%M:%S")
HOST=$(hostname)
BASEDIR=/var/lib/boinc
ERRLOG=stderr.txt # not used yet in this script, this file is in $BASEDIR/slots/$SLOT/stderr.txt for each job - check if you have problems
RUNRIVET=shared/runRivet.log
TMPRUNRIVET=/tmp/runRivet.log
JOBINPUT=init_data.xml
CERNVMCOUNTER=0

# Helper checking if a value is a valid integer
is_num() { [[ "$1" =~ ^[0-9]+$ ]]; }

# Fins Theory slots
SLOTLIST=$(grep -r wu_name $BASEDIR/slots/*/init_data.xml | grep Theory_ | awk -F'/' '{print $6}' | sort -n)

echo -e "\n"
echo "--- LHC Theory - $HOST ---- $DATE ------------------------------------------------------"
echo " "
echo "                                     |          Events          |"
printf "%*s%*s%*s%*s%*s%*s%*s%*s\n" 6 "Slot" 27 "Job id" 9 "Total" 11 "Processed" 12 "Remaining" 17 "Elapsed time" 13 "Completed %" 7 "Err "
echo "------------------------------------------------------------------------------------------------------"

for SLOT in $SLOTLIST
do
    SLOTDIR="$BASEDIR/slots/$SLOT"

    # Check if the slot is active
    if [ -d "$SLOTDIR/shared" ] && [ -f "$SLOTDIR/$RUNRIVET" ] && [ -f "$SLOTDIR/boinc_lockfile" ]; then
        cp "$SLOTDIR/$RUNRIVET" "$TMPRUNRIVET"
        ((CERNVMCOUNTER++))
        ERR=""

        # Calculate runtime
        START_EPOCH=$(stat --format %Y "$SLOTDIR/boinc_lockfile")
        NOW_EPOCH=$(date +%s)
        diff=$((NOW_EPOCH - START_EPOCH))
        days=$((diff / 86400))
        JOBTIME=$(printf "%dd %02d:%02d" $days $((diff % 86400 / 3600)) $((diff % 3600 / 60)))

        # Get Job Name
        JOBNAME="Theory_"$(grep -Pom1 '<result_name>Theory_\K[^<]+' "$SLOTDIR/$JOBINPUT")

        # Use NF-1 logic for total number of events
        TOTALEVENT=$(grep "\[runRivet\]" "$TMPRUNRIVET" | tail -1 | awk '{print $(NF-1)}' | tr -d '[]')

        if ! is_num "$TOTALEVENT"; then
            TOTALEVENT=0
            ERR="*"
        fi

        # Get processed events
        PROCESSEDEVENT=$(awk '/events processed/ {val=$1} END {print val}' "$TMPRUNRIVET")

        # Fallback for "Integrate" or "Pre" phase jobs
        if ! is_num "$PROCESSEDEVENT" || [ -z "$PROCESSEDEVENT" ]; then
            INTEGRATE_LINE=$(awk '/Integrate/ {last=$0} END {print last}' "$TMPRUNRIVET")
            if [ -n "$INTEGRATE_LINE" ]; then
                PROCESSEDEVENT=$(echo "$INTEGRATE_LINE" | awk '{print $2}')
                TOTALEVENT=$(echo "$INTEGRATE_LINE" | awk '{print $4}')
                ERR="Pre "
            else
                IDLESTART=$(awk '/Idle:/ {print $3; exit}' "$TMPRUNRIVET" | tr -d ':')
                if is_num "$IDLESTART"; then
                    RUNNING=$(awk '/Running:/ {val=$5} END {print val}' "$TMPRUNRIVET" | tr -d ':')
                    COMPLETED=$(awk '/Completed:/ {val=$7} END {print val}' "$TMPRUNRIVET")
                    TOTALEVENT=$((IDLESTART + RUNNING))
                    PROCESSEDEVENT="$COMPLETED"
                    ERR="Pre"
                else
                    PROCESSEDEVENT=0
                    EVENTTOGO=0
                    PERCENT=0
                    ERR="*"
                fi
            fi
        fi

        # Final check and progress
        if is_num "$PROCESSEDEVENT" && is_num "$TOTALEVENT" && [ "$TOTALEVENT" -gt 0 ]; then
            if [ "$TOTALEVENT" -ge "$PROCESSEDEVENT" ]; then
                EVENTTOGO=$(( TOTALEVENT - PROCESSEDEVENT ))
                PERCENT=$(awk -v a="$PROCESSEDEVENT" -v b="$TOTALEVENT" 'BEGIN {printf("%.1f", 100*a/b)}')
            else
                EVENTTOGO=0; PERCENT="0.0"; ERR="*"
            fi
        else
            # Only set to 0 if not already handled by "Pre" logic
            [ -z "$PROCESSEDEVENT" ] && PROCESSEDEVENT=0
            EVENTTOGO=0; PERCENT="0.0"; ERR="*"
        fi

        printf "%*s%*s%*s%*s%*s%*s%*s%*s\n" 6 "$SLOT" 27 "$JOBNAME" 9 "$TOTALEVENT" 11 "$PROCESSEDEVENT" 12 "$EVENTTOGO" 17 "$JOBTIME" 13 "$PERCENT" 7 "$ERR"
        rm -f "$TMPRUNRIVET"
    fi
done

if (( CERNVMCOUNTER == 0 )); then
    echo "No Theory job running"
fi

echo -e "\n--- Number of Theory jobs for host $HOST: $CERNVMCOUNTER ----------------------------------------------------------"
echo " "
