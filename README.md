```text
2025-03-20 13:34 Asia/Bangkok

theory.sh

Status script for LHC Boinc project Theory

Simple bash script to be run in a Linux terminal. It has been tested on Debian 12.


This script shows the status for LHC Theory job currently running in your Boinc client
(Currently Linux Boinc client 8.02). It adds info not available in the Boinc client so
you know how far each job has come in the calculations.

A short explanation:

Slot - The slot Boinc has created for the job. Usually in /var/lib/boinc/slots/

Job id - The job identification created by LHC

Total events - Total number of events in the job

Processed events - Number of events finished

Remaining events - Number of events to go before job is finished

Elapsed time - Total absolute time from when Boinc created the job slot until now

Completed % - How many percent of the job that are finished

Err - This column has several functions;
        - If it shows nothing the job is running and you can se the progress in the
          Event/Completed columns.

        - If it shows * (a star) the job is running but the script can't extract the
          events from the logfile. In this case Processed Events and Remaining events
          are shown as zero (0).

        - If it shows Pre, it is preparing the job, not all job has this. As soon it's
          finished preparing it will clear the Prepare Event and Completed numbers and show
          how many Events it must go processing the job. If it shows Pre2 or any higher
          Pre number the job has multiple Preparation phases.



--- LHC Theory - pm111 ---- 2025-03-20 13:33:03 ------------------------------------------------------

                                     |          Events          |
  Slot                     Job id    Total  Processed   Remaining     Elapsed time  Completed %   Err
------------------------------------------------------------------------------------------------------
     0  Theory_2843-4285081-529_1   100000       9100       90900   0 day(s) 00:14          9.1
     4  Theory_2843-4283470-553_1      760        513         247   2 day(s) 03:00         67.5   Pre
     6  Theory_2843-4233686-637_1   100000      12100       87900   0 day(s) 00:20         12.1
     7  Theory_2843-4266629-527_1   100000      32100       67900   4 day(s) 18:55         32.1
     8  Theory_2843-4268236-631_2   100000      11300       88700   0 day(s) 00:40         11.3
     9  Theory_2843-4215060-636_1   100000      12800       87200   0 day(s) 00:40         12.8
    10  Theory_2843-4298305-638_0   100000       4400       95600   0 day(s) 00:40          4.4
    11  Theory_2843-4176419-638_0   100000       5800       94200   0 day(s) 00:40          5.8
    12  Theory_2843-4167410-530_2   100000       2000       98000   0 day(s) 00:40          2.0
    13  Theory_2843-4272131-637_1   100000       4100       95900   0 day(s) 00:08          4.1
    14  Theory_2843-4105059-638_0   100000      98200        1800   0 day(s) 00:06         98.2
    15  Theory_2843-4138784-637_1   100000       8400       91600   0 day(s) 00:14          8.4
    16  Theory_2843-4240147-632_2   100000      50100       49900   0 day(s) 00:14         50.1
    17  Theory_2843-4291709-635_1   100000       8400       91600   0 day(s) 00:14          8.4
    18  Theory_2843-4289920-636_1   100000       8600       91400   0 day(s) 00:14          8.6
    19  Theory_2843-4105980-632_2   100000       1800       98200   0 day(s) 00:14          1.8
    21  Theory_2843-4298935-637_1   100000      16100       83900   0 day(s) 00:14         16.1
    22  Theory_2843-4269424-535_2      760        534         226   2 day(s) 09:07         70.3   Pre
    23  Theory_2843-4215627-634_1   100000      10000       90000   0 day(s) 00:14         10.0
    24  Theory_2843-4202143-634_2   100000      11100       88900   0 day(s) 00:14         11.1
    54  Theory_2843-4264765-529_0      760        650         110   3 day(s) 21:15         85.5   Pre

--- Number of Theory jobs for host pm111: 21 ----------------------------------------------------------



It's easiest to run the script in a terminal window with watch -n 60 theory.sh

If you think there is something wrong with a Theory job look in /var/lib/boinc/slots/{the slot
number from the terminal output}/stderr.txt

Many of these jobs can run for a very long time so please do not terminate any jobs - that
is bad to the project. If there is something wrong with the job or your computer isn't fast
enough to finish within the timeframe set in Boinc, Boinc will terminate the job automatic.


Please see Cern LHC Boinc site https://lhcathome.cern.ch/lhcathome/index.php for everything
Boinc related about the project.

Disclaimer - Please note I'm not affiliated in any way with Cern / LHC.
I'm retired and doing this of my own interest.
```
