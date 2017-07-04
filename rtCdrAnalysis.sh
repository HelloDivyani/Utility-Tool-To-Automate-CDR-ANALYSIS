#!/bin/bash
###############################################################################
#                        Copyright (c) 2017                                   #
#                   Rancore Technologies (P) Ltd.                             #
#                       All Rights Reserved                                   #
###############################################################################
# Script Name    :- rtCdrAnalysis                                             #
# Description    :- CDR-ANALYSIS                                              #
# Owner          :- Divyani Mittal                                            #
# Last Updated   :- 29 June 2017                                              #
###############################################################################
# Script Has 4 Inputs:
#
#   1. START TIME                : YYYYMMDDHHMMSSMMM
#   2. END TIME                  : YYYYMMDDHHMMSSMMM
#   3. PHONE NUM                 : 999XXXXXXX
#   4. ACTIVE CONTROLLER IP      : XX.XX.XX.XX
################################################################################


OUTPUT_CDR_PATH=/data1/output
RT_SCRIPT_PATH=/home/imsuser/rtBTAS/AS/scripts/Utility_Scripts
REPORT_COLLECTOR_PATH=$OUTPUT_CDR_PATH/number_anasysis/report_collector


RT_PRODUCT=rtBTAS
PRODUCT=BTAS
PROD_DOT_VER=`rpm -qa | grep $RT_PRODUCT | awk -F "-" '{print $2}'`     #ex 2.3.0
PROD_VER=`rpm -qa | grep $RT_PRODUCT | awk -F "-" '{print $2}' | awk -F "." '{print $1$2$3}'` #ex 230


mkdir -p $OUTPUT_CDR_PATH/number_anasysis/reports
mkdir -p $OUTPUT_CDR_PATH/number_anasysis/logs

rm $OUTPUT_CDR_PATH/number_anasysis/reports/*.txt &> /dev/null

#Log File For Script Log Dump
LOGFILENAME=/tmp/call_record_`date '+%d.%m.%Y_%H:%M:%S'`.txt
touch $LOGFILENAME


#PATH Variables
PATH_CSV=$OUTPUT_CDR_PATH/chrg/online/cdrs
PATH_TMP=/tmp/utility_temp.txt



#Source Files
source /home/imsuser/packages_btas/${RT_PRODUCT}-${PROD_DOT_VER}/prod_btas/config/ODD/config.sh
source /home/imsuser/packages_btas/${RT_PRODUCT}-${PROD_DOT_VER}/other-software/config/ODD/config.sh


#Error Codes
export SUCCESS=0
export END_TIME_NOT_GIVEN=1
export PNO_NOT_GIVEN=2
export TRIGGER_CONTROLLER_NOT_GIVEN=3
export CONTROLLER_TRIGGERED_NOT_LAST=4
export CDR_IP_RECEIVE_FAIL=5
export CDR_HOSTNAME_RECEIVE_FAIL=6
export CP_CONTROLLER_REPORT_COLLECTOR_FAIL=7
export SCP_REPORT_COLLECTOR_FAIL=8
export ERROR_SSH=9
export START_TIME_NOT_GIVEN=10
export NO_CSV_FILE_FOUND=11
export PROCESS_ALREADY_RUNNING=12

#Variables from source
SELF_CONTROLLER=$SLOT_1_IP_ADDRESS
REMOTE_CONTROLLER=$SLOT_2_IP_ADDRESS
PAYLOAD1=$SLOT_3_IP_ADDRESS
PAYLOAD2=$SLOT_4_IP_ADDRESS
PAYLOAD3=$SLOT_5_IP_ADDRESS
PAYLOAD4=$SLOT_6_IP_ADDRESS


# export l1_date_var=$(date '+%d-%m-%Y_%H%M%S')
# if [ -f /tmp/dummy_$l1_date_var.txt ]; then
#            rm -rf /tmp/clusterLog_$l1_date_var.txt
#  fi

#  pidof -x rtCdrAnalysis.sh > /tmp/clusterLog_$l1_date_var.txt

#  Process_count=`cat /tmp/clusterLog_$l1_date_var.txt | wc -w`
#         rm -rf /tmp/clusterLog_$l1_date_var.txt


                                                           #echo "Process_count val :[$Process_count]"
#         if [ $Process_count -gt 1 ]; then
#         echo "Error-- Script rtCdrAnalysis.sh is already running on this server. Can't execute mutiple Scripts simultaneously"
#   exit $PROCESS_ALREADY_RUNNING
#          fi



#Ensuring that at a time only one instance is created :
LOCKFILE=/tmp/lock_cluster.txt
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running CdrAnalysis Script"
                echo "Process Already Running " >> $LOGFILENAME
                exit $PROCESS_ALREADY_RUNNING
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}



#Argument Supply Check
if [ -z "$1" ]; then
  echo "Please supply the START TIME in format YYYYMMDDHHMMSSMMM" >> $LOGFILENAME
  exit $START_TIME_NOT_GIVEN
fi

if [ -z "$2" ]; then
  echo "Please supply the END TIME in format YYYYMMDDHHMMSSMMM" >> $LOGFILENAME
  exit $END_TIME_NOT_GIVEN
fi

if [ -z "$3" ]; then
  echo "Please supply PHONE NUMBER to be Searched for :"  >> $LOGFILENAME
  exit $PNO_NOT_GIVEN
fi

if [ -z "$4" ]; then
  echo "Please supply the TRIGGER_CONTROLLER_IP_ADDRESS " >> $LOGFILENAME
  exit $TRIGGER_CONTROLLER_NOT_GIVEN
fi




#Assigning Common Arguments
START_DURATION=$1
END_DURATION=$2
PHONE_NUM=$3
SELF_IP_ADDRESS=` hostname -I | awk '{print $1}'`
TRIGGERED_MAIN_CONTROLLER_IP=$4


#Filter based on TIMESTAMP and Phone number
Var=`echo "$START_DURATION" | awk '{print substr($word,1,14)}'`
startFilter=` echo $Var | sed -r 's/^.{4}/&-/;:a; s/([-:])(..)\B/\1\2:/;ta;s/:/-/;s/:/ /'`
Var=`echo "$END_DURATION" | awk '{print substr($word,1,14)}'`
endFilter=` echo $Var | sed -r 's/^.{4}/&-/;:a; s/([-:])(..)\B/\1\2:/;ta;s/:/-/;s/:/ /'`


findOut=`find $PATH_CSV -name "*.csv"   -newermt "$startFilter"  -not  -newermt "$endFilter" `

if [ -z "$findOut" ]
then
        echo "===NO CSV Files to Study Under Condition===" >> $LOGFILENAME
     #   exit $NO_CSV_FILE_FOUND
else
        grep -lr $PHONE_NUM $findOut  | sort  > $PATH_TMP
fi


#sleep 3000
function create_self_report()
{

    CURRTIME=$(date +"%Y-%m-%d@%H:%M:%S:%3N")
    LOG_FILENAME=$OUTPUT_CDR_PATH/number_anasysis/logs/${CURRTIME}_${SELF_IP_ADDRESS}_log.txt
    REPORT_FILENAME=$OUTPUT_CDR_PATH/number_anasysis/reports/${CURRTIME}_${SELF_IP_ADDRESS}_report.txt


    touch  $LOG_FILENAME
    touch  $REPORT_FILENAME

    FILE_LIST=`cat $PATH_TMP`


       if [[ -s $PATH_TMP ]]; then  #Checks for file size greater than 0

            FIRST_FILE_NAME=`head -n 1 $PATH_TMP |  sed -r 's/^.+\///'`
            START_TIME=`echo $FIRST_FILE_NAME | cut -d "_" -f 4`   # Format :  YYYYMMDDHHMMSSMMM
            LAST_FILE_NAME=`tail -n 1 $PATH_TMP | sed -r 's/^.+\///'`
            echo "[$FIRST_FILE_NAME] [$LAST_FILE_NAME]" >> $LOG_FILENAME
            END_TIME=`echo $LAST_FILE_NAME| cut -d "_" -f 4`   # Format :  YYYYMMDDHHMMSSMMM
            echo "PHONE NO : [$PHONE_NUM] , IP ADDR : [$SELF_IP_ADDRESS] , CALL START TIME :  [$START_TIME] , CALL END TIME :  [$END_TIME] " >> $REPORT_FILENAME

#################################################################################
            echo "LIST OF LOG FILES WHERE PHONE NO:[$PHONE_NUM] FOUND" >> $REPORT_FILENAME    # if needed

            for file in `cat $PATH_TMP`
             do
                CSVFile=$file
                CSVFile_Name=`echo $file |  sed -r 's/^.+\///'`
                echo "Files Processing : $CSVFile_Name " >> $LOG_FILENAME
                NoLines=`grep -n -c $PHONE_NUM  $CSVFile`
                echo "Total Number of Lines Phone found : $NoLines" >> $LOG_FILENAME
                echo " * $CSVFile_Name " >> $REPORT_FILENAME
             done
##################################################################################

        else

            echo "PHONE NO $PHONE_NUM NOT FOUND IN BLADE $SELF_IP_ADDRESS " >> $LOGFILENAME
#   echo "PHONE NO : [$PHONE_NUM] , IP ADDR : [$SELF_IP_ADDRESS] " >> $REPORT_FILENAME
#            echo "NOT - FOUND "  >> $REPORT_FILENAME
            echo "PHONE NO : [$PHONE_NUM] , IP ADDR : [$SELF_IP_ADDRESS] " >> $LOG_FILENAME
            echo "NOT - FOUND "  >> $LOG_FILENAME

        fi


if [ "X$SELF_CONTROLLER" == "X$SELF_IP_ADDRESS" ]; then
    cp $REPORT_FILENAME  $REPORT_COLLECTOR_PATH
else
    scp $REPORT_FILENAME   imsuser@$SELF_CONTROLLER:$REPORT_COLLECTOR_PATH
fi
rm $OUTPUT_CDR_PATH/number_anasysis/reports/*.txt &> /dev/null

}



##################################### ACTIVE CONTROLLER CASE #################


if [ "X$SELF_CONTROLLER" == "X$SELF_IP_ADDRESS" ]; then  #self controller case

  mkdir -p $REPORT_COLLECTOR_PATH

  create_self_report

       if [[ $REL_BTAS_INSTALLATION_TYPE -gt 1 ]]; then  #Possibility 2 or 6
                  echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Controller2 [$REMOTE_CONTROLLER] \$1 [$1] \$2[$2] \$3[$3] \$4[$4] " | tee -a  $LOGFILENAME

                  ssh  imsuser@$REMOTE_CONTROLLER $RT_SCRIPT_PATH/rtCdrAnalysis.sh $START_DURATION $END_DURATION $PHONE_NUM $TRIGGERED_MAIN_CONTROLLER_IP

                  remote_1_result=$?
                  if  [ "$remote_1_result" != "0"  ]; then
                     echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Remote [$REMOTE_CONTROLLER] failed  with error code [$remote_1_result]"  >>  $LOGFILENAME
                  fi

       fi

       if [[ $REL_BTAS_INSTALLATION_TYPE -gt 2 ]]; then

                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload1 [$PAYLOAD1] - \$1 [$1] \$2[$2] \$3[$3] \$4[$4]" | tee -a  $LOGFILENAME
                   ssh imsuser@$PAYLOAD1 $RT_SCRIPT_PATH/rtCdrAnalysis.sh $START_DURATION $END_DURATION $PHONE_NUM $TRIGGERED_MAIN_CONTROLLER_IP
                   remote_2_result=$?
                   if [ "$remote_2_result" != "0" ] ; then #assumed 0 as success case
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Payload1 [$PAYLOAD1]  failed with error code [$remote_2_result]" >> $LOGFILENAME
                   fi


                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload2 [$PAYLOAD2] - \$1 [$1] \$2[$2] \$3[$3] \$4[$4] " | tee -a  $LOGFILENAME
                   ssh -o "ServerAliveInterval=10" imsuser@$PAYLOAD2 $RT_SCRIPT_PATH/rtCdrAnalysis.sh $START_DURATION $END_DURATION $PHONE_NUM $TRIGGERED_MAIN_CONTROLLER_IP
                   remote_3_result=$?
                   if [ $remote_3_result != "0" ] ; then
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Payload2 [$PAYLOAD2]  failed with error code [$remote_3_result]" >>  $LOGFILENAME
                   fi

                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload3 [$PAYLOAD3] - \$1 [$1] \$2[$2] \$3[$3] \$4[$4] " | tee -a  $LOGFILENAME
                   ssh -o "ServerAliveInterval=10" imsuser@$PAYLOAD3 $RT_SCRIPT_PATH/rtCdrAnalysis.sh $START_DURATION $END_DURATION $PHONE_NUM $TRIGGERED_MAIN_CONTROLLER_IP
                   remote_4_result=$?
                   if [ $remote_4_result != "0" ] ; then
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Payload1 [$PAYLOAD3]  failed  with error code [$remote_4_result]" >>   $LOGFILENAME
                   fi

                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload4 [$PAYLOAD4]  - \$1 [$1] \$2[$2] \$3[$3] \$4[$4] " | tee -a  $LOGFILENAME
                   ssh -o "ServerAliveInterval=10" imsuser@$PAYLOAD4 $RT_SCRIPT_PATH/rtCdrAnalysis.sh $START_DURATION $END_DURATION $PHONE_NUM $TRIGGERED_MAIN_CONTROLLER_IP
                   remote_5_result=$?
                   if [ $remote_5_result != "0" ] ; then
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Payload1 [$PAYLOAD4]  failed  with error code [$remote_5_result]"  >>   $LOGFILENAME
                   fi

                   echo "Values Are  [$remote_2_result]  [$remote_3_result] [$remote_4_result] [$remote_5_result] "
                   if [ $remote_2_result != "0"  ]  || [ $remote_3_result != "0" ]|| [ $remote_4_result != "0" ]|| [ $remote_5_result != "0" ]; then
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Remote failed " | tee -a  $LOGFILENAME
                   fi


       fi


       #Made it to sleep


       sleep 5


       CLUSTER_REPORT=$OUTPUT_CDR_PATH/number_anasysis/reports/Cluster_report_${SELF_IP_ADDRESS}_`date '+%d.%m.%Y_%H:%M:%S'`.txt
       touch  $CLUSTER_REPORT

       for finalReport in `ls  $REPORT_COLLECTOR_PATH/*.txt`
       do

       filesize=`stat -c %s $finalReport`
                         if [ $filesize = 0 ];then
                                #Not - Found Case
                         continue
                         fi

#if [[ -s $finalReport ]] #Check for file size greater than 0
#                               then
#                               else &> /dev/null
                                 #Not Found Case
#                               continue &> /dev/null
#                               fi


         FILE_NAME=`echo $finalReport | sed -r 's/^.+\///'`
         BLADE_IP=`echo $FILE_NAME | awk -F "_" '{print $2}'`
         echo "###################################################" >> $CLUSTER_REPORT
         echo "BLADE : $BLADE_IP" >> $CLUSTER_REPORT
         echo " `cat $finalReport ` " >> $CLUSTER_REPORT
         echo "###################################################" >> $CLUSTER_REPORT

       done

#       echo " $SELF_IP_ADDRESS $TRIGGERED_MAIN_CONTROLLER_IP "
       rm $REPORT_COLLECTOR_PATH/*.txt &> /dev/null
       if [ "X$SELF_IP_ADDRESS"  == "X$TRIGGERED_MAIN_CONTROLLER_IP" ]
          then
          #Final Report cp to different folder
          cp $CLUSTER_REPORT   $OUTPUT_CDR_PATH/number_anasysis/circlewise_report_collector/
          else
                  #SCP TO Different folder
#scp $CLUSTER_REPORT imsuser@$TRIGGERED_MAIN_CONTROLLER_IP:$OUTPUT_CDR_PATH/number_anasysis/circlewise_report_collector/
                        ########## Expect Code #######################
                        /usr/bin/expect<<EOF

             spawn scp $CLUSTER_REPORT imsuser@$TRIGGERED_MAIN_CONTROLLER_IP:$OUTPUT_CDR_PATH/number_anasysis/circlewise_report_collector/
             expect {
                    "Are you sure you want to continue connecting (yes/no)?" {send yes\r;exp_continue}
                    "$TRIGGERED_MAIN_CONTROLLER_IP's password:" {send Password\r;exp_continue}
                    }
EOF
           fi
         exit 0

else
      create_self_report
      exit 0
fi

#sleep 1000

rm -f ${LOCKFILE}


############################## END report creation ####################

