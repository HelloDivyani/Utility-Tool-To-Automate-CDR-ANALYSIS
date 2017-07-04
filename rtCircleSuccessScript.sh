#!/bin/bash
###############################################################################
#                        Copyright (c) 2017                                   #
#                   Rancore Technologies (P) Ltd.                             #
#                       All Rights Reserved                                   #
###############################################################################
# Script Name    :- rtCircleSuccessScript                                     #
# Description    :- CIRCLE-SUCCESS-ANALYSIS                                   #
# Owner          :- Divyani Mittal                                            #
# Last Updated   :- 30 June 2017                                              #
###############################################################################
# Script  Inputs:
#  NO INPUTS
################################################################################

#TRIGGER ALL IP's in  success_cluster_invoke.txt

#PATH Variables
PATH_OUTPUT_CDR=/data1/output
RT_CLUSTER_INVOKE_SCRIPT=/home/imsuser/rtBTAS/AS/scripts/Utility_Scripts/success_circle_ip_details.txt
RT_SCRIPT_PATH=/home/imsuser/rtBTAS/AS/scripts/Utility_Scripts
PATH_FINAL_COLLECTOR=$PATH_OUTPUT_CDR/success_anasysis/circlewise_report_collector
PATH_REPORT_COMPLETE=$PATH_OUTPUT_CDR/success_anasysis/reports
COLLECTION_FINAL_REPORT=$PATH_OUTPUT_CDR/success_anasysis/collection_final_report

#Variables
SELF_IP_ADDRESS=` hostname -I | awk '{print $1}'`


mkdir -p  $PATH_OUTPUT_CDR/success_anasysis/circlewise_report_collector &> /dev/null
rm $PATH_FINAL_COLLECTOR/*  &> /dev/null
mkdir -p $PATH_OUTPUT_CDR/success_anasysis/collection_final_report   &> /dev/null


#Error Code
export PROCESS_ALREADY_RUNNING=1
export HELP_EXIT=2

#Ensuring that at a time only one instance is created :
LOCKFILE=/tmp/success_trigger_cluster.txt
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running CdrAnalysis Script"
                echo "Process Already Running " >> $LOGFILENAME
                exit $PROCESS_ALREADY_RUNNING
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}



### HELP OPTION #####
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


if [ "$1" = "--help" ] || [ "$1" = "--HELP" ]; then

     echo -e $GREEN "******************* Welcome to rtCircleSuccessScript *******************" $NC
     echo -e $BLUE  "The script is used to trigger the rtSuccessScript in Clusters supplied through success_cluster_invoke.txt " $NC
     echo -e $BLUE  "FINDS OVERALL SUCCESS" $NC
    echo -e $BLUE "Success Rate is based on CALL_ANSWERED_STATUS Value"
    echo -e $BLUE  "NO INPUTS TO BE SUPPLIED" $NC
    exit $HELP_EXIT
fi
#### END OF HELP OPTION #####

#Enter For how many cluster need to run :

no_of_cluster=` grep -n -c "." $RT_CLUSTER_INVOKE_SCRIPT `

cluster=$no_of_cluster

#This data Text File read
until [ $cluster -eq  0 ]
do
   line_no=`expr $no_of_cluster - $cluster + 1`
   #  Read that line_no form that file
   CLUSTER_ACTIVE_CONTROLLER_IP=`sed "${line_no}q;d"  $RT_CLUSTER_INVOKE_SCRIPT`

    cluster=`expr $cluster - 1 `

   if [ "X$SELF_IP_ADDRESS" == "X$CLUSTER_ACTIVE_CONTROLLER_IP" ]
         then
        sh $RT_SCRIPT_PATH/rtSuccessScript.sh $SELF_IP_ADDRESS

        else
               /usr/bin/expect<<EOF
                          spawn ssh imsuser@$CLUSTER_ACTIVE_CONTROLLER_IP  $RT_SCRIPT_PATH/rtSuccessScript.sh $SELF_IP_ADDRESS
                                 expect {
                                                   "Are you sure you want to continue connecting (yes/no)?" {send yes\r;exp_continue}
                                                   "$CLUSTER_ACTIVE_CONTROLLER_IP's password:" {send Password\r;exp_continue}
                                                    }
EOF


   fi
done


## Generate Success Circle Report
## for all reports in circle wise report collector

echo "Preparing complete Final Report :"

rm $PATH_REPORT_COMPLETE/* &> /dev/null


CURRTIME=$(date +"%Y-%m-%d@%H:%M:%S:%3N")

touch $PATH_REPORT_COMPLETE/SuccessAnalysis_${CURRTIME}_Circle_Report.txt
COMPLETE_PATH_FINAL=$PATH_REPORT_COMPLETE/SuccessAnalysis_${CURRTIME}_Circle_Report.txt
#echo "Path Variable : $PATH_FINAL_COLLECTOR"
#echo "Here : `ls $PATH_FINAL_COLLECTOR`"
 echo -e $BLUE  "*********************************************************" >> $COMPLETE_PATH_FINAL $NC
for file in `ls $PATH_FINAL_COLLECTOR`
do
 #    echo "${PATH_FINAL_COLLECTOR}/$file"

      echo "` cat ${PATH_FINAL_COLLECTOR}/$file`" >> $COMPLETE_PATH_FINAL

done
 echo "                                                         " >> $COMPLETE_PATH_FINAL
 ### Overall Success Rate Calculation
 #Total line

total_line_data=`grep "TOTAL" $COMPLETE_PATH_FINAL | cut -d "[" -f2 | cut -d "]" -f1`
total_success_line_data=`grep "TOTAL"  $COMPLETE_PATH_FINAL | cut -d "[" -f3 | cut -d "]" -f1`

#echo " *** Here total_line_data  : $total_line_data"
#echo "***** Here total_success_line_data  : $total_success_line_data "


total_line_cal=`echo "$total_line_data" | wc -l`
#echo "******* total_line_cal : $total_line_cal "


total_success_line_cal=`echo "$total_success_line_data" | wc -l`

#echo "****** total_success_line_cal : $total_success_line_cal"

total_line_cal_counter=$total_line_cal

#total_success_line_cal_counter=$total_success_line_cal
TOTAL_LINES=0
TOTAL_SUCCESS_LINE=0

#echo "****** total_line_cal_counter  :  $total_line_cal_counter"


 echo -e $BLUE  "*********************************************************" >> $COMPLETE_PATH_FINAL $NC



 until [  $total_line_cal_counter -eq  0 ]
do
 #            echo "Inside Loop"
              LINE_NO=`expr $total_line_cal  - $total_line_cal_counter + 1`
  #             echo "LINE_NO : $LINE_NO"
                          total_line_cal_counter=`expr $total_line_cal_counter - 1`
               #  echo "Line No : $LINE_NO "
              #LINE=`sed "${LINE_NO}q;d"  $total_line_data`
                          LINE=`echo "$total_line_data" | sed -n ${LINE_NO}p`
        #                 echo "**** LINE : $LINE"
                          SUCCESS_LINE=`echo "$total_success_line_data" | sed -n ${LINE_NO}p`
     #         echo "***** SUCCESS_LINE : $SUCCESS_LINE"
                          TOTAL_LINES=`expr $TOTAL_LINES + $LINE`

                          TOTAL_SUCCESS_LINE=`expr $TOTAL_SUCCESS_LINE + $SUCCESS_LINE`
                #         echo "****  TOTAL_LINES : $TOTAL_LINES AND TOTAL_SUCCESS_LINE : $TOTAL_SUCCESS_LINE"

done


if [ $TOTAL_LINES -eq 0 ]
then
    SUCCESS_RATE=''
        SUCCESS_RATIO=''
else

#Success Rate Calculation
   SUCCESS_RATIO=`echo "$TOTAL_SUCCESS_LINE / $TOTAL_LINES" | bc -l`
    SUCCESS_RATE=`echo "$SUCCESS_RATIO * 100" | bc -l`
fi


 echo -e $GREEN "OVERALL  SUCCESS RATE      :       [$SUCCESS_RATE]  ">> $COMPLETE_PATH_FINAL $NC





##################
##Collection Final Report :


cp $COMPLETE_PATH_FINAL $COLLECTION_FINAL_REPORT





########################################### GUI BUILDING  -  FINAL REPORT SHOW #############################

#final_report_data=`cat $COMPLETE_PATH_FINAL`

whiptail --title "--FINAL REPORT DETAILS--" --msgbox "CLICK OK TO SEE THE FINAL REPORT" 10 60

echo -e $GREEN  "*********************  FINAL REPORT :  *************************** " $NC
echo "`cat $COMPLETE_PATH_FINAL`"

rm -f ${LOCKFILE}
##### END OF SCRIPT #############
