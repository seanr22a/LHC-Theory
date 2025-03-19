2025-03-19 22:28 Asia/Bangkok

theory.sh
 
Status script for LHC Boinc project Theory

Simple bash script to be run in a Linux terminal. It has been tested on Debian 12.

This script shows the status for LHC Theory job currently running in your Boinc client (Currently Linux Boinc client 8.02). 
It adds info not available in the Boinc client so you know how far each job has come in the calculations.

I will update the terminal copy you can see here as soon as I have a greater variation of jobs running.

A short explanation:

Slot - The slot Boinc has created for the job. Usually in /var/lib/boinc-client/slots/

Job id - The job identification created by LHC

Total events - Total number of events in the job

Processed events - Number of events finished

Remaining events - Number of events to go before job is finished

Elapsed time - Total absolute time from when Boinc created the job slot until now

Completed % - How many percent of the job that are finished

Err - This column has several functions; 
        - If it shows nothing the job is running and you can se the progress in the Event/Completed columns.
        
        - If it shows * (a star) the job is running but the script can't extract the events from the logfile. In this case
          Processed Events and Remaining events are shown as zero (0).
          
        - If it shows Pre, it is preparing the job, not all job has this. As soon it's finished preparing it will clear 
          the Event and Completed numbers and show how many Events it must go processing the job. If it shows Pre2 or
          any higher Pre number the job has multiple Preparation phases.
        
--- LHC Theory - pm111 ---- 2025-03-19 22:40:07 ------------------------------------------------------

                                     |          Events          |
  Slot                     Job id    Total  Processed   Remaining     Elapsed time  Completed %   Err
------------------------------------------------------------------------------------------------------
     4  Theory_2843-4283470-553_1      760        372         388   1 day(s) 12:07         48.9   Pre
     7  Theory_2843-4266629-527_1      760        748          12   3 day(s) 04:02         98.4   Pre
    15  Theory_2843-4298132-525_1      600        226         374   1 day(s) 00:50         37.7   Pre2
    22  Theory_2843-4269424-535_2      760        408         352   2 day(s) 18:14         53.7   Pre
    54  Theory_2843-4264765-529_0      760        527         233   2 day(s) 06:22         69.3   Pre

--- Number of Theory jobs for host pm111: 5 ----------------------------------------------------------

It's easiest to run the script in a terminal window with watch -n 60 theory.sh

If you think there is something wrong with the job look in /var/lib/boinc-client/slots/{the slot number from the terminal output}/stderr.txt

Many of these jobs can run for a very long time so please do not terminate any jobs - that is bad to the project. If there is something wrong 
with the job or your computer isn't fast enough to finish within the timeframe set in Boinc, Boinc will terminate the job automatic.

Please see Cern LHC Boinc site https://lhcathome.cern.ch/lhcathome/index.php for everything Boinc related about the project.
