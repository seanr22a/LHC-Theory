#!/bin/bash
############################################
#
# 2025-03-19 22:28 Asia/Bangkok
#
# theory.sh
# 
# Status script for LHC Boinc project Theory
#
############################################

DATE=$(date +"%Y-%m-%d %H:%M:%S")
HOST=$(hostname)
BASEDIR=/var/lib/boinc-client
ERRLOG=stderr.txt # not used yet in this script, this file is in $BASEDIR/slots/$SLOT/stderr.txt for each job - check if you have problems
RUNRIVET=cernvm/shared/runRivet.log
TMPRUNRIVET=/tmp/runRivet.log
JOBINPUT=init_data.xml

# Find all Boinc slots
SLOTLIST=$(ls $BASEDIR/slots | sort -n)

echo -e "\n"
echo "--- LHC Theory - $HOST ---- $DATE ------------------------------------------------------"
echo " "
echo "                                     |          Events          |"
printf "%*s%*s%*s%*s%*s%*s%*s%*s\n" 6 "Slot" 27 "Job id" 9 "Total" 11 "Processed" 12 "Remaining" 17 "Elapsed time" 13 "Completed %" 7 "Err "
echo "------------------------------------------------------------------------------------------------------"

for SLOT in $SLOTLIST
do
  # Check if the slot is a Theory job. Only the Theory jobs has the cernvm folder and check for the runRivet.log file.
  if [ -d $BASEDIR/slots/"$SLOT"/cernvm ] && [ -f $BASEDIR/slots/"$SLOT"/$RUNRIVET ]; then
     # Work with a copy of the runRivet.log file to avoid errors if the file is modified during script exec.
     cp $BASEDIR/slots/"$SLOT"/$RUNRIVET $TMPRUNRIVET
     ERR=""

     # Keep track of how many theory jobs
     ((CERNVMCOUNTER++))

     # Calculate runtime. This is not cpu time, it's the total time from when the slot was created in Boinc until now.
     JOBSTART=$(stat --format %w $BASEDIR/slots/"$SLOT"/boinc_lockfile | awk -F'.' '{print $1}')
     JOBCURRENT=$(date +"%Y-%m-%d %H:%M:%S")
     diff=$(($(date -d "$JOBCURRENT" +'%s') - $(date -d "$JOBSTART" +'%s')))
     days=$(($(date -d @$diff +'%-j')-1))
     JOBTIME=$(TZ=GMT date -d @"$diff" +"$days"' day(s) %H:%M')

     JOBNAME="Theory_"$(grep -Pom1 '<result_name>Theory_\K[^<]+' $BASEDIR/slots/"$SLOT"/$JOBINPUT)

     TOTALEVENT=$(grep "\[runRivet\]" $TMPRUNRIVET | awk '{print$18}')
     if [ -z "${TOTALEVENT}" ]; then
       TOTALEVENT=0
       ERR="*"
     fi

     # If PROCESSEDEVENT get a number when disable INTEGRATE and IDLESTART
     PROCESSEDEVENT=$(grep "events processed" $TMPRUNRIVET | tail -1  | awk '/events processed/{print $1;exit}')
     # Check so PROCESSEDEVENT is a number
     if [ -n "$PROCESSEDEVENT" ] && [ "$PROCESSEDEVENT" -eq "$PROCESSEDEVENT" ] 2>/dev/null; then
        NOINTEGRATE=1
     else
         if [ -z "${PROCESSEDEVENT}" ]; then # empty
            NOINTEGRATE=0
            NOIDLESTART=0
         else
            NOINTEGRATE=1
            NOIDLESTART=1
            IDLESTART=""
            RUNNING=""
            COMPLETED=""
            INTEGRATE=""
            ERR="*"
         fi
     fi

#if [[ ( "$A" -eq "0" || "$B" -ne "0" ) && "$C" -eq "0" ]]; the
     # Check if it is a job using prepare
     if [[ ( "$NOINTEGRATE" -eq "0" && "$NOIDLESTART" -eq "0" ) ]]; then
       IDLESTART=$(awk -v p="Idle:" '$2 == p' $TMPRUNRIVET | head -1 | awk '{print $3}' | sed 's/.$//')
       RUNNING=$(awk -v p="Running:" '$4 == p' $TMPRUNRIVET | tail -1 | awk '{print $5}' | sed 's/.$//')
       COMPLETED=$(awk -v p="Completed:" '$6 == p' $TMPRUNRIVET | tail -1 | awk '{print $7}')
       INTEGRATE=$(awk -v p="Integrate" '$1 == p' $TMPRUNRIVET | awk '{last=$0} END{print last}' | sed 's/.$//')
       if [ -n "$INTEGRATE" ]; then
         if [ ${INTEGRATE:+1} ]; then
           # Uses Integrate
           TOTALEVENT=$(echo "$INTEGRATE" | awk '{print $4}')
           PROCESSEDEVENT=$(echo "$INTEGRATE" | awk '{print $2}')
           ERR="Pre "
         fi
       else
         if [ -n "$IDLESTART" ]; then
           if [ ${IDLESTART:+1} ]; then
             # Uses Idle/Completed
             TOTALEVENT=$(("$IDLESTART" + "$RUNNING"))
             PROCESSEDEVENT="$COMPLETED"
             ERR=$(grep -c "Completed: 0" $TMPRUNRIVET)
             if [ "$ERR" -lt "2" ]; then
               ERR="Pre"
             else
               ERR="Pre"$(grep -c "Completed: 0" $TMPRUNRIVET)
             fi
           fi
         fi
       fi
     fi

     # Check so PROCESSEDEVENT is a number
     if [ -n "$PROCESSEDEVENT" ] && [ "$PROCESSEDEVENT" -eq "$PROCESSEDEVENT" ] 2>/dev/null; then
       if [ "$TOTALEVENT" -ge "$PROCESSEDEVENT" ]; then
         EVENTTOGO=$(( TOTALEVENT - PROCESSEDEVENT ))
         PERCENT=$(awk -v a="$PROCESSEDEVENT" -v b="$TOTALEVENT" 'BEGIN {printf("%.1f\n",100*a/b)}')
       else
         EVENTTOGO=0
         PERCENT=0
         ERR="*"
       fi
     else
       PROCESSEDEVENT=0
       EVENTTOGO=0
       PERCENT=0
       ERR="*"
     fi

     printf "%*s%*s%*s%*s%*s%*s%*s%*s\n" 6 "$SLOT" 27 "$JOBNAME" 9 "$TOTALEVENT" 11 "$PROCESSEDEVENT" 12 "$EVENTTOGO" 17 "$JOBTIME" 13 "$PERCENT" 7 "$ERR"
     rm $TMPRUNRIVET
  fi
done

if (( CERNVMCOUNTER == 0 )); then
  echo "No Theory job running"
fi

echo -e "\n--- Number of Theory jobs for host $HOST: $CERNVMCOUNTER ----------------------------------------------------------"
echo " "
