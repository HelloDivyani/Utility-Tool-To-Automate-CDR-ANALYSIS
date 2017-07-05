#!/bin/bash
###############################################################################
#                        Copyright (c) 2017                                   #
#                   Rancore Technologies (P) Ltd.                             #
#                       All Rights Reserved                                   #
###############################################################################
# Script Name    :- rtAnalysis                                                #
# Description    :- System and Product Configuration Details                  #
# Owner          :- Divyani Mittal                                            #
# Last Updated   :- 5  July 2017                                              #
###############################################################################
# SCRIPT INPUTS :
#
#   1. ACTIVE CONTROLLER IP      : XX.XX.XX.XX
#   2. START TIME                : YYYYMMDDHHMMSSMMM
#   3. END TIME                  : YYYYMMDDHHMMSSMMM
#   4.OPTION                     : 1-SUCCESS_RATE 2-FAILURE_DETAILS
#    YYYYMMDDHHMMSSMMM           : YEAR-MONTH-DATE-HOUR-MIN-SEC-MILLISEC
################################################################################


OUTPUT_CDR_PATH=/data1/output
RT_SCRIPT_PATH=/home/imsuser/rtBTAS/AS/scripts/Utility_Scripts
REPORT_COLLECTOR_PATH=$OUTPUT_CDR_PATH/rate_anasysis/report_collector




RT_PRODUCT=rtBTAS
PRODUCT=BTAS
PROD_DOT_VER=`rpm -qa | grep $RT_PRODUCT | awk -F "-" '{print $2}'`     #ex 2.3.0
PROD_VER=`rpm -qa | grep $RT_PRODUCT | awk -F "-" '{print $2}' | awk -F "." '{print $1$2$3}'` #ex 230


mkdir -p $OUTPUT_CDR_PATH/rate_anasysis/reports
mkdir -p $OUTPUT_CDR_PATH/rate_anasysis/logs

rm $OUTPUT_CDR_PATH/rate_anasysis/reports/*.txt &> /dev/null

#Log File For Script Log Dump
LOGFILENAME=/tmp/analysis_record_`date '+%d.%m.%Y_%H:%M:%S'`.txt
touch $LOGFILENAME


#PATH Variables
PATH_CSV=$OUTPUT_CDR_PATH/chrg/online/cdrs
PATH_TMP=/tmp/utility_temp_analysis.txt
touch PATH_TMP


#Source Files
source /home/imsuser/packages_btas/${RT_PRODUCT}-${PROD_DOT_VER}/prod_btas/config/ODD/config.sh
source /home/imsuser/packages_btas/${RT_PRODUCT}-${PROD_DOT_VER}/other-software/config/ODD/config.sh




#Error Code
export PROCESS_ALREADY_RUNNING=1
export TRIGGER_CONTROLLER_NOT_GIVEN=2
export START_TIME_NOT_GIVEN=3
export END_TIME_NOT_GIVEN=4
export OPTION_NOT_GIVEN=5
export INVALID_OPTION=6

#Variables from source
SELF_CONTROLLER=$SLOT_1_IP_ADDRESS
REMOTE_CONTROLLER=$SLOT_2_IP_ADDRESS
PAYLOAD1=$SLOT_3_IP_ADDRESS
PAYLOAD2=$SLOT_4_IP_ADDRESS
PAYLOAD3=$SLOT_5_IP_ADDRESS
PAYLOAD4=$SLOT_6_IP_ADDRESS



##COLORS
BLACK="\e[1;39m";   export BLACK;
blue="\e[0;34m";    export blue;
BLUE="\e[1;34m";    export BLUE;
red="\e[0;31m";     export red;
RED="\e[1;31m";     export RED;
GREEN="\e[0;32m";   export GREEN;
NC="\e[0m";         export NC;
cyan="\e[0;36m";    export cyan;
CYAN="\e[1;36m";    export CYAN;
PINK="\e[1;35m";    export PINK;
grey="\e[0;30m";    export grey;
GREY="\e[1;30m";    export GREY;



#Variables
SELF_IP_ADDRESS=` hostname -I | awk '{print $1}'`



#Ensuring that at a time only one instance is created :
LOCKFILE=/tmp/lock_cluster_analysis.txt
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running  Script"
                echo "Process Already Running " >> $LOGFILENAME
                exit $PROCESS_ALREADY_RUNNING
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}




############# ARGUMENT CHECK ############
if [ -z "$1" ]; then
 echo "Please supply the TRIGGER_CONTROLLER_IP_ADDRESS "
 echo "Please supply the TRIGGER_CONTROLLER_IP_ADDRESS " >> $LOGFILENAME
  exit $TRIGGER_CONTROLLER_NOT_GIVEN
fi

if [ -z "$2" ]; then
  echo "Please supply the START TIME in format YYYYMMDDHHMMSSMMM" >> $LOGFILENAME
  exit $START_TIME_NOT_GIVEN
fi

if [ -z "$3" ]; then
  echo "Please supply the END TIME in format YYYYMMDDHHMMSSMMM" >> $LOGFILENAME
  exit $END_TIME_NOT_GIVEN
fi

if [ -z "$4" ]; then
   echo "Please  supply the option " >> $LOGFILENAME
   exit $OPTION_NOT_GIVEN
fi


#Assigning Common Arguments
TRIGGERED_MAIN_CONTROLLER_IP=$1
START_DURATION=$2
END_DURATION=$3
OPTION=$4

#Filter based on TIMESTAMP 
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
      ## COPY FINDOUT IN PATH_TMP
	  echo "$findOut" >> $PATH_TMP
#       sort $findOut > $PATH_TMP
#echo "Find  : $findOut" > $PATH_TMP     
fi
#echo "`cat $PATH_TMP`"
#List of all csv files in tmp folder


######### Function create self report ############

function create_self_report()
{

    CURRTIME=$(date +"%Y-%m-%d@%H:%M:%S:%3N")
    LOG_FILENAME=$OUTPUT_CDR_PATH/rate_anasysis/logs/${CURRTIME}_${SELF_IP_ADDRESS}_log.txt
    REPORT_FILENAME=$OUTPUT_CDR_PATH/rate_anasysis/reports/${CURRTIME}_${SELF_IP_ADDRESS}_report.txt

    touch  $LOG_FILENAME
    touch  $REPORT_FILENAME
	
	FILE_LIST=`cat $PATH_TMP`
	
	# if [[ -s $PATH_TMP ]]; then  #Checks for file size greater than 0
	 # echo "CSV FILES PRESENT  " >> $LOGFILENAME
	 #else
	    #Not Present
		#if [ $OPTION -eq 1 ]
		#then
		   
	
	if [ $OPTION -eq 1 ]
	then
	################################################  OPTION 1 PROCESSING ########################################################
	    #SUCCESS RATE
		#Variables
       TOTAL_BLADE_LINE=0
       TOTAL_BLADE_CALL_FAILURE_LINES=0
       TOTAL_BLADE_CALL_SUCCESS_LINES=0
	   
	   
             echo -e $RED "BLADE_IP_ADDR : [$SELF_IP_ADDRESS] ">> $REPORT_FILENAME $NC		 
	
			 #file has complete path
			for file in `cat $PATH_TMP`
            do 
			      TOTAL_FILE_LINES=`wc -l < $file `
                 TOTAL_BLADE_LINE=`expr $TOTAL_BLADE_LINE + $TOTAL_FILE_LINES`

                  FILE_LINE_COUNTER=$TOTAL_FILE_LINES
                  FILE_CALL_FAILURE_LINES=0
                  FILE_CALL_SUCCESS_LINES=0
   #echo "File Name :  $file TOTAL_FILE_LINES : $TOTAL_FILE_LINES"
                  echo "Files Processing in SUCCESS RATE CALCULATION : $file " >> $LOG_FILENAME

                 until [ $FILE_LINE_COUNTER -eq 0 ]
                 do
                         LINE_NO=`expr $TOTAL_FILE_LINES  - $FILE_LINE_COUNTER + 1`
                            FILE_LINE_COUNTER=`expr $FILE_LINE_COUNTER - 1`
               #  echo "Line No : $LINE_NO "
                          LINE=`sed "${LINE_NO}q;d"  $file`

               ## Analysis on 12th Parameter
               ##          Call Answered Status
               ##      0 – means not answered
               ##      1 – means answered

                          CALL_ANSWER_STATUS=`echo $LINE | cut -d, -f12 | tr -d '\n' `
               #echo "LINE_NO : $LINE_NO CALL_ANSWER_STATUS : $CALL_ANSWER_STATUS"
                          if [ $CALL_ANSWER_STATUS  -eq 1 ]
                        then
                                 FILE_CALL_SUCCESS_LINES=`expr $FILE_CALL_SUCCESS_LINES + 1`
                           elif [ $CALL_ANSWER_STATUS -eq 0 ]
                          then
                                 FILE_CALL_FAILURE_LINES=`expr $FILE_CALL_FAILURE_LINES + 1`
                           else
                    #echo " Call Answered Status Parameter neither 1 or 2  in File : $file Line_No : $LINE_NO" >> $LOG_FILENAME
                                        echo "CALL_ANSWER_STATUS INVALID IN FILE : $file  FILE_LINE_NO : $LINE_NO" >> $LOG_FILENAME
                            fi


            done

                   echo "FILE : $file  TOTAL_CALL_SESSION : $TOTAL_FILE_LINES  TOTAL_CALL_SUCCESSFUL_SESSION : $FILE_CALL_SUCCESS_LINES" >> $LOGFILENAME &> /dev/null

                   #Update Blade Line
            TOTAL_BLADE_CALL_FAILURE_LINES=`expr $TOTAL_BLADE_CALL_FAILURE_LINES + $FILE_CALL_FAILURE_LINES`
            TOTAL_BLADE_CALL_SUCCESS_LINES=`expr $TOTAL_BLADE_CALL_SUCCESS_LINES + $FILE_CALL_SUCCESS_LINES`

          done
		
if [ $TOTAL_BLADE_LINE -eq 0 ]
then
   SUCCESS_RATIO=''
   SUCCESS_RATE=''
else

#Success Rate Calculation
   SUCCESS_RATIO=`echo "$TOTAL_BLADE_CALL_SUCCESS_LINES / $TOTAL_BLADE_LINE" | bc -l`
   SUCCESS_RATE=`echo "$SUCCESS_RATIO * 100" | bc -l`
fi
#echo "End of Script Display Success Rate  $SUCCESS_RATIO  : $SUCCESS_RATE"
## Multiple Cluster Expect Script
## Report Collection

   ### WRITING IN REPORT  FILE OF BLADE ####

  # echo  -e $RED "BLADE_IP_ADDR : [$SELF_IP_ADDRESS]"   >> $REPORT_FILENAME $NC
   echo "TOTAL_CALL_SESSION : [$TOTAL_BLADE_LINE]  TOTAL_CALL_SUCCESSFUL_SESSION : [$TOTAL_BLADE_CALL_SUCCESS_LINES] BLADE_SUCCESS_RATE : [$SUCCESS_RATE]" >> $REPORT_FILENAME

   #### WRITING IN LOG FILE OF BLADE ####
   echo " **************** BLADE SUMMARY ***************** " >> $LOG_FILENAME
   #  echo "BLADE_IP_ADDR : [$SELF_IP_ADDRESS]"   >> $REPORT_FILENAME
   echo "TOTAL_CALL_SESSION : [$TOTAL_BLADE_LINE]  TOTAL_CALL_SUCCESSFUL_SESSION : [$TOTAL_BLADE_CALL_SUCCESS_LINES] BLADE_SUCCESS_RATE : [$SUCCESS_RATE]" >> $LOG_FILENAME



	
			 
			 
			 
############################ OPTION 1 DONE ##############################################	   
	   
	   
		
    elif [ $OPTION -eq 2 ]
	then
	######################################################### OPTION 2 PROCESSING ########################################################
	   #FAILURE CODE
	   
TOTAL_BLADE_INTERNAL_ERROR_CALL_SESSION=0
TOTAL_BLADE_EXTERNAL_ERROR_CALL_SESSION=0


#TMP FILE TO STORE ERROR CODE - COUNT EXTERNAL CODES  IN BLADE
EXTERNAL_FILE=/tmp/external_error_code_failure_analysis_script.txt
touch $EXTERNAL_FILE

#TMP FILE TO STORE ERROR CODE - COUNT INTERNAL  CODES IN BLADE
INTERNAL_FILE=/tmp/internal_error_code_failure_analysis_script.txt
touch $INTERNAL_FILE


## PRINTING IN EXTERNAL AND INTERNAL FILES
#echo "[ERROR_CODE] : [COUNT]" >> $EXTERNAL_FILE
#echo "[ERROR_CODE] : [COUNT]" >> $INTERNAL_FILE

 
	   
             echo -e $RED "BLADE_IP_ADDR : [$SELF_IP_ADDRESS] ">> $REPORT_FILENAME $NC		 
	



for file in `cat $PATH_TMP`
do


  TOTAL_FILE_LINES=`wc -l < $file `
  FILE_LINE_COUNTER=$TOTAL_FILE_LINES
  TOTAL_FILE_INTERNAL_ERROR_CALL_SESSION=0
  TOTAL_FILE_EXTERNAL_ERROR_CALL_SESSION=0

     echo "Files Processing FAILURE ERROR CODE STUDY : $file " >> $LOG_FILENAME

   until [ $FILE_LINE_COUNTER -eq 0 ]
   do
             LINE_NO=`expr $TOTAL_FILE_LINES  - $FILE_LINE_COUNTER + 1`
               FILE_LINE_COUNTER=`expr $FILE_LINE_COUNTER - 1`

              LINE=`sed "${LINE_NO}q;d"  $file`
               # 10 digit Clear Code of Call Session
                           CLEAR_CODE=`echo $LINE | cut -d, -f24 | tr -d '\n' `

						      ## Just a Check
                   len=`echo $CLEAR_CODE|awk '{print length}'`  ## CORRECT  LENGTH SHOULD BE 10
                   if [ $len -ne  10 ]
                   then
                        echo "Clear Code Length is not 10 digit in File :  $file  ">> $LOGFILENAME
                        echo "CLEAR CODE LENGTH IS NOT 10 DIGIT IN FILE : $file " >>  $LOG_FILENAME
                        continue
                    fi
			   
						   
                           # CHECK INTERNAL OR EXTERNAL
                           FIRST_DIGIT_CLEAR_CODE=`echo $CLEAR_CODE | awk '{print substr($word,1,1)}'`
               ## Error Code 3rd Parameter Extract 4 digit code sent to BTAS
                                ERROR_CODE=`echo $CLEAR_CODE | awk '{print substr($word,4,4)}'`
                if [ $FIRST_DIGIT_CLEAR_CODE -eq 1 ]    #Internal Error
                then
                     #Internal Error BTAS Error
                                         #3rd Parameter : Internal Error Code
                     TOTAL_FILE_INTERNAL_ERROR_CALL_SESSION=`expr $TOTAL_FILE_INTERNAL_ERROR_CALL_SESSION + 1`
                                         grep_line_error_code=`grep $ERROR_CODE $INTERNAL_FILE`

                                         if [ -z "$grep_line_error_code" ]
                                         then
                                              echo "[$ERROR_CODE] : [1]">> $INTERNAL_FILE
                                         fi
                                         #Increment Case
                                         grep_line_count=`echo $grep_line_error_code | cut -d "[" -f3 | cut -d "]" -f1`
                     #Increment that count
                                         grep_line_count=`expr $grep_line_count + 1`
                                         #Write count Back
                                         `sed -i "s/^.*$ERROR_CODE.*$/[$ERROR_CODE] : [$grep_line_count]/" $INTERNAL_FILE`


                             elif [ $FIRST_DIGIT_CLEAR_CODE -eq 2 ] #External Error
                             then
                        #Error due to other network elements
                                                #3rd Parameter  : Error Code Received from Network
                                                TOTAL_FILE_EXTERNAL_ERROR_CALL_SESSION=`expr $TOTAL_FILE_EXTERNAL_ERROR_CALL_SESSION + 1`
                                                grep_line_error_code=`grep $ERROR_CODE $EXTERNAL_FILE`

                                                if [ -z "$grep_line_error_code" ]
                                            then
                                                echo "[$ERROR_CODE] : [1]">> $EXTERNAL_FILE
                                                fi
                                         #Increment Case
                                         grep_line_count=`echo $grep_line_error_code | cut -d "[" -f3 | cut -d "]" -f1`
                     #Increment that count
                                         grep_line_count=`expr $grep_line_count + 1`
                                         #Write count Back
                                         `sed -i "s/^.*$ERROR_CODE.*$/[$ERROR_CODE] : [$grep_line_count]/" $EXTERNAL_FILE`




                             else
                                     echo "CLEAR CODE FIRST DIGIT NEITHER 1 OR 2 IN FILE  : $file "  >> $LOGFILENAME

                                fi





    done

         ## Done with all call sessions in 1 file
         TOTAL_BLADE_EXTERNAL_ERROR_CALL_SESSION=`expr $TOTAL_BLADE_EXTERNAL_ERROR_CALL_SESSION + $TOTAL_FILE_EXTERNAL_ERROR_CALL_SESSION`
         TOTAL_BLADE_INTERNAL_ERROR_CALL_SESSION=`expr $TOTAL_BLADE_INTERNAL_ERROR_CALL_SESSION + $TOTAL_FILE_INTERNAL_ERROR_CALL_SESSION`


   done

 ### WRITING IN REPORT  FILE OF BLADE ####

#echo  -e $RED "BLADE_IP_ADDR : [$SELF_IP_ADDRESS]"   >> $REPORT_FILENAME $NC
#echo "BLADE INFO : "
echo "TOTAL_BLADE_EXTERNAL_ERROR_CALL_SESSION : [$TOTAL_BLADE_EXTERNAL_ERROR_CALL_SESSION] " >> $REPORT_FILENAME
echo "[ERROR_CODE] : [COUNT]" >> $REPORT_FILENAME
echo "`cat $EXTERNAL_FILE`" >> $REPORT_FILENAME

echo "TOTAL_BLADE_INTERNAL_ERROR_CALL_SESSION : [$TOTAL_BLADE_INTERNAL_ERROR_CALL_SESSION]" >> $REPORT_FILENAME
echo "[ERROR_CODE] : [COUNT]" >> $REPORT_FILENAME
echo "`cat $INTERNAL_FILE`" >> $REPORT_FILENAME

  #### WRITING IN LOG FILE OF BLADE ####
   echo " **************** BLADE SUMMARY ***************** " >> $LOG_FILENAME
echo "TOTAL_BLADE_EXTERNAL_ERROR_CALL_SESSION : [$TOTAL_BLADE_EXTERNAL_ERROR_CALL_SESSION] " >> $LOG_FILENAME
echo "[ERROR_CODE] : [COUNT]" >> $LOG_FILENAME
echo "`cat $EXTERNAL_FILE`" >> $LOG_FILENAME

echo "TOTAL_BLADE_INTERNAL_ERROR_CALL_SESSION : [$TOTAL_BLADE_INTERNAL_ERROR_CALL_SESSION]" >> $LOG_FILENAME
echo "[ERROR_CODE] : [COUNT]" >> $LOG_FILENAME
echo "`cat $INTERNAL_FILE`" >> $LOG_FILENAME


rm $EXTERNAL_FILE
rm $INTERNAL_FILE


	   

################################### OPTION 2 PROCESSING DONE ###############################################################################################################


   else
	    echo "INVALID OPTION SUPPLY  " >>  $LOGFILENAME
		exit $INVALID_OPTION
     fi



   #Reports and logs done

if [ "X$SELF_CONTROLLER" == "X$SELF_IP_ADDRESS" ]; then
    cp $REPORT_FILENAME  $REPORT_COLLECTOR_PATH
else
    scp $REPORT_FILENAME   imsuser@$SELF_CONTROLLER:$REPORT_COLLECTOR_PATH
fi
rm $OUTPUT_CDR_PATH/success_anasysis/reports/*.txt &> /dev/null




### Done create self report function


}


######### CHECKING PROCESS ############################
##BEGIN
##################################### ACTIVE CONTROLLER CASE #################


if [ "X$SELF_CONTROLLER" == "X$SELF_IP_ADDRESS" ]; then  #self controller case

  mkdir -p $REPORT_COLLECTOR_PATH

  create_self_report

       if [[ $REL_BTAS_INSTALLATION_TYPE -gt 1 ]]; then  #Possibility 2 or 6
                  echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Controller2 [$REMOTE_CONTROLLER] \$1 [$1] \$2[$2] \$3[$3] \$4[$4]  " | tee -a  $LOGFILENAME

                  ssh  imsuser@$REMOTE_CONTROLLER  $RT_SCRIPT_PATH/rtAnalysis.sh  $SELF_CONTROLLER $START_DURATION $END_DURATION $OPTION

                  remote_1_result=$?
                  if  [ "$remote_1_result" != "0"  ]; then
                     echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Remote [$REMOTE_CONTROLLER] failed  with error code [$remote_1_result]"  >>  $LOGFILENAME
                  fi

       fi

       if [[ $REL_BTAS_INSTALLATION_TYPE -gt 2 ]]; then  #Confirm 6 Blade

                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload1 [$PAYLOAD1] - \$1 [$1] \$2[$2] \$3[$3] \$4[$4] " | tee -a  $LOGFILENAME
                   ssh imsuser@$PAYLOAD1  $RT_SCRIPT_PATH/rtAnalysis.sh  $SELF_CONTROLLER $START_DURATION $END_DURATION $OPTION
                   remote_2_result=$?
                   if [ "$remote_2_result" != "0" ] ; then #assumed 0 as success case
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Payload1 [$PAYLOAD1]  failed with error code [$remote_2_result]" >> $LOGFILENAME
                   fi


                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload2 [$PAYLOAD2] - \$1 [$1] \$2[$2] \$3[$3] \$4[$4]]" | tee -a  $LOGFILENAME
                   ssh -o "ServerAliveInterval=10" imsuser@$PAYLOAD2  $RT_SCRIPT_PATH/rtAnalysis.sh   $SELF_CONTROLLER $START_DURATION $END_DURATION $OPTION
                   remote_3_result=$?
                   if [ $remote_3_result != "0" ] ; then
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Payload2 [$PAYLOAD2]  failed with error code [$remote_3_result]" >>  $LOGFILENAME
                   fi

                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload3 [$PAYLOAD3] - \$1 [$1] \$2[$2] \$3[$3] \$4[$4]] " | tee -a  $LOGFILENAME
                   ssh -o "ServerAliveInterval=10" imsuser@$PAYLOAD3  $RT_SCRIPT_PATH/rtAnalysis.sh  $SELF_CONTROLLER $START_DURATION $END_DURATION $OPTION
                                   remote_4_result=$?
                   if [ $remote_4_result != "0" ] ; then
                      echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Output Captured from Payload1 [$PAYLOAD3]  failed  with error code [$remote_4_result]" >>   $LOGFILENAME
                   fi

                   echo "[Time=`date '+%d.%m.%Y_%H:%M:%S'`] Invoking script from Payload4 [$PAYLOAD4]  - \$1 [$SELF_CONTROLLER] " | tee -a  $LOGFILENAME
                   ssh -o "ServerAliveInterval=10" imsuser@$PAYLOAD4  $RT_SCRIPT_PATH/rtAnalysis.sh  $SELF_CONTROLLER $START_DURATION $END_DURATION $OPTION
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


       CLUSTER_REPORT=$OUTPUT_CDR_PATH/rate_anasysis/reports/Cluster_report_${SELF_IP_ADDRESS}_`date '+%d.%m.%Y_%H:%M:%S'`.txt
       touch  $CLUSTER_REPORT

            #Cluster Report Contains Data Appended From Reports of all Blades of the particular cluster which is generated in controller case
                 #echo "`ls $REPORT_COLLECTOR_PATH`"
                  for finalReport in `ls $REPORT_COLLECTOR_PATH`
                  do
                    #echo "$finalReport"
            #echo "###################################################" >> $CLUSTER_REPORT
            echo " `cat $REPORT_COLLECTOR_PATH/$finalReport ` " >> $CLUSTER_REPORT
            #echo "###################################################" >> $CLUSTER_REPORT
              done

                    #Empty Collector

                    rm $REPORT_COLLECTOR_PATH/*.txt &> /dev/null

                  if [ "X$SELF_IP_ADDRESS"  == "X$TRIGGERED_MAIN_CONTROLLER_IP" ]
          then
               #Final Report cp to different folder
               cp $CLUSTER_REPORT   $OUTPUT_CDR_PATH/rate_anasysis/circlewise_report_collector/
          else
                  #SCP TO Different folder
                   #scp $CLUSTER_REPORT imsuser@$TRIGGERED_MAIN_CONTROLLER_IP:$OUTPUT_CDR_PATH/number_anasysis/circlewise_report_collector/
                        ########## Expect Code #######################
                        /usr/bin/expect<<EOF

             spawn scp $CLUSTER_REPORT imsuser@$TRIGGERED_MAIN_CONTROLLER_IP:$OUTPUT_CDR_PATH/rate_anasysis/circlewise_report_collector/
             expect {
                    "Are you sure you want to continue connecting (yes/no)?" {send yes\r;exp_continue}
                    "$TRIGGERED_MAIN_CONTROLLER_IP's password:" {send Password\r;exp_continue}
                    }
EOF
           fi
         exit 0


else              ## NON CONTROLLER CASE
            create_self_report

fi

rm -f ${LOCKFILE}

#################### END OF SCRIPT #######################################