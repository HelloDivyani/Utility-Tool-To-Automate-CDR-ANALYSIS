#!/bin/bash
###############################################################################
#                        Copyright (c) 2017                                   #
#                   Rancore Technologies (P) Ltd.                             #
#                       All Rights Reserved                                   #
###############################################################################
# Script Name    :- rtCdrCircleAnalysis                                       #
# Description    :- CIRCLE-ANALYSIS                                           #
# Owner          :- Divyani Mittal                                            #
# Last Updated   :- 29 June 2017                                              #
###############################################################################
# Script  Inputs:


#Path Variables :

PATH_OUTPUT_CDR=/data1/output
RT_CLUSTER_INVOKE_SCRIPT=/home/imsuser/rtBTAS/AS/scripts/Utility_Scripts/analysis_circle_ip_details.txt
RT_SCRIPT_PATH=/home/imsuser/rtBTAS/AS/scripts/Utility_Scripts
PATH_FINAL_COLLECTOR=$PATH_OUTPUT_CDR/rate_anasysis/circlewise_report_collector
PATH_REPORT_COMPLETE=$PATH_OUTPUT_CDR/rate_anasysis/reports
COLLECTION_FINAL_REPORT=$PATH_OUTPUT_CDR/rate_anasysis/collection_final_report



##############
#Options Ist Parameter 1 : Relative Total 2 Parameters Relative time in minutes 3 Option 1 or 2 
#Options 2nd Parameter 2 : Absolute Enter 3 Parameters start end  Option 1 or 2
####################


SELF_IP_ADDRESS=` hostname -I | awk '{print $1}'`
ACTIVE_TRIGGER_CONTROLLER_IP=$SELF_IP_ADDRESS


#PATH Variables :

PATH_FINAL_COLLECTOR=$PATH_OUTPUT_CDR/rate_anasysis/circlewise_report_collector
PATH_COMPLETE_FINAL=$PATH_OUTPUT_CDR/rate_anasysis/reports
COLLECTION_FINAL_REPORT=$PATH_OUTPUT_CDR/rate_anasysis/collection_final_report

#Permission Error
mkdir -p  $PATH_OUTPUT_CDR/rate_anasysis/circlewise_report_collector &> /dev/null
rm $PATH_FINAL_COLLECTOR/*  &> /dev/null
mkdir -p $PATH_OUTPUT_CDR/rate_anasysis/collection_final_report   &> /dev/null



## Error code
export GUI_ARGUMENT_OPTION_NOT_GIVEN=1
export INVALID_MINUTES=2
export MIN_EXCEED_LIMIT=3
export GUI_MINUTES_NOT_GIVEN=4
export INVALID_END_TIME=5
export INVALID_START_TIME=6
export GUI_END_TIME_NOT_GIVEN=7
export GUI_START_TIME_NOT_GIVEN=8
export INVALID_ARGUMENTS=9
export RELATIVE_MINUTES_NOT_GIVEN=10
export SF_ENTRY_NOT_GIVEN=11
export GUI_ARGUMENT_OPTION_NOT_GIVEN=12
export SF_ENTRY_INVALID=13

#Ensuring that at a time only one instance is created :
LOCKFILE=/tmp/circle_analysis_success_failure_lock.txt
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
          exit $PROCESS_ALREADY_RUNNING
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE} &> /dev/null






##################  -- HELP -- #####################
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
help_exit=1



if [ "$1" = "--help" ] || [ "$1" = "--HELP" ]; then

     echo -e $GREEN "******************* Welcome to rtCircleAnalysis Script *******************" $NC
     echo -e $BLUE  "The script is used to trigger the rtAnalysis Script in Clusters supplied through  analysis_circle_ip_details.txt " $NC

        until [ $help_exit -eq 0 ]
        do

                 echo -e $BLUE  "Parameters to be supplied as command line argument to invoke the script are  : " $NC
                 echo -e $CYAN  " 1. GUI-ARGUMENT  CHOICE          : Enter 1 = GUI 2 = Argument " $NC
                 echo -e $red   " --  SELECTED 1 REDIRECT TO GUI  /  SELECTED 2 ENTER FURTHER PARAMETERS --  " $NC
                 echo -e $CYAN  " 2. RELATIVE-ABSOLUTE CHOICE     : Enter 1 = Relative Time 2 = Absolute Time " $NC
                 echo -e $red   " --  SELECTED 1 ENTER BELOW PARAMETER -- " $NC
                 echo -e $CYAN  " 3. MINUTES                      : Minutes to be Run from current time " $NC
                 echo -e $CYAN  " 4. OPTION SUCESS_FAILURE        : Enter 1 = SUCCESS_RATE 2 =  FAILURE_ERROR_CODE_ANALYSIS " $NC
                 echo -e $CYAN  " -- SELECTED 2 ENTER BELOW PARAMETER -- " $NC
                 echo -e $CYAN  " 3. START_DURATION               : Start time from where you want start analysis [YYYYMMDDHHMMSSMMM] " $NC
                 echo -e $CYAN  " 4. END_DURATION                 : End time where to stop analysis [YYYYMMDDHHMMSSMMM] " $NC
                 echo -e $CYAN  " 5. OPTION SUCESS_FAILURE        : Enter 1 = SUCCESS_RATE 2 =  FAILURE_ERROR_CODE_ANALYSIS " $NC
#                echo -e $CYAN  " 4. ACTIVE_TRIGGER_CONTROLLER_IP : IP of the server where the circle report to be generated [XX.XX.XX.XX] " $NC
                echo  "PRESS ENTER TO RUN "
                 echo -e $BLUE  " Options :-" $NC
                 echo -e $PINK   " CHOOSE OPTION FROM BELOW LIST TO GET MORE INFO " $NC
                echo -e $RED    "1.START_DURATION "$NC
                echo -e $RED    "2.END_DURATION "$NC
               # echo -e $RED    "3.PHONE_NUMBER "$NC
                 echo -e $RED    "3.MINUTES" $NC
                echo -e $RED   "4.Information About Working of Script " $NC
                 echo -e $RED   "5.EXIT HELP" $NC
                 echo -e $BLUE  "Enter the option " $NC
                 read option

                 if [ "$option" = "1" ]; then
                             echo -e $GREEN  " START_DURATION " $NC
                             echo -e $PINK   " Format - [YYYYMMDDHHMMSSMMM] " $NC
                             echo -e $GREY   " [YYYYMMDDHHMMSSMMM] = (YearMonthDateHourMinuteSecMillisec)" $NC
                             echo -e $GREY   " Example : 20170101000000000 " $NC


#                fi


                elif [ "$option" = "2" ]; then
                                             echo -e $GREEN  " END_DURATION " $NC
                                             echo -e $PINK   " Format - [YYYYMMDDHHMMSSMMM] " $NC
                                                 echo -e $GREY   " [YYYYMMDDHHMMSSMMM] = (YearMonthDateHourMinuteSecMillisec)" $NC
                                                         echo -e $GREY   " Example : 20171231000000000 " $NC


# fi

                # elif [ "$option" = "3" ]; then
                                             # echo -e $GREEN  " PHONE NUMBER " $NC
                                             # echo -e $PINK   " Format - [XXXXXXXXXXXX] " $NC
                                                         # echo -e $GREY   " [XXXXXXXXXXXX] = (12-DIGIT PHONE NUMBER)" $NC
                                                         # echo -e $GREY   " Example : 919872001093 " $NC


#        fi

           elif [ "$option" = "3" ]; then
                           echo -e $GREEN  " MINUTES " $NC
                                             echo -e $GREY   " POSITIVE INTEGER  < 1440 " $NC
                                                 echo -e $GREY   " EG : 30 " $NC



#  fi

          elif [ "$option" = "4" ]; then
                                             echo -e $GREEN  " WORKING INFORMATION OF SCRIPT " $NC
                                             echo -e $GREY   "The script prompts 1 or 2 1=GUI 2=ARGUMENT " $NC
                                                 echo -e $GREY   "Cluster node 1 ip to be written analysis_circle_ip_details.txt" $NC
                                                         echo -e $GREY   "Enter the specified Arguments " $NC
                                 echo -e $GREY   "ClusterReport is then copied to active controller server  where Combined Circle Report is generated " $NC
              echo -e $GREY    "Circle Report is generated in /data1/output/number_anaysis/reports" $NC

#       fi

         elif [ "$option" = "5" ]; then
                                     echo -e $GREEN  " EXIT" $NC
                   help_exit=0
                                                 exit $HELP_EXIT
#         fi

#        [ $option -ne 1 -a $option -ne 2 -a $option -ne 3 $option -ne 4 -a $option -ne 5 -a $option -ne 6 ]
#               then
    else
                                        echo -e $RED "--INVALID OPTION -- PLEASE CHOOSE CORRECT OPTION ---- " $NC
                                        exit $INVALID_HELP_OPTION_CHOSEN
          fi

  done
fi


################################################# PARAMETER STUDY BEGIN #####################################################################

if [ -z "$1" ]
then
   echo -e $RED "PLEASE CHOOSE BETWEEN 1 =  GUI AND 2 =  PARAMETERS --- CHECK --help FOR MORE INFO " $NC
   exit $GUI_ARGUMENT_OPTION_NOT_GIVEN
fi

OPTION_ENTRY=0
SF_ENTRY=0

if [  "$1" -eq 1 ]
then
      

###################################   GUI BUILDING  ######################################################
if (whiptail --title "--- CIRCLE ANALYSIS ---" --yes-button "Option 1" --no-button "Option 2"  --yesno "CHOOSE OPTION  1 = Relative Time  2 = Absolute Time " 10 60) then

##############  OPTION 1 CHOOSEN #########################################################################
  OPTION_ENTRY=1

####################  GET MINUTES FROM USERS ###############################################################
       MINUTES_ENTRY=$(whiptail --title "Relative Time From Now" --inputbox "Enter Minutes ( < 1440 ) : " 10 60 30  3>&1 1>&2 2>&3)
       exitstatus=$?

       if [ $exitstatus = 0 ]; then


           if [ "$MINUTES_ENTRY" -eq  "$MINUTES_ENTRY" ] &> /dev/null
           then
              echo "yes" &> /dev/null
           else
                echo  -e $RED "--INVALID MINUTES ENTERED ----" $NC
               exit $INVALID_MINUTES
            fi
            # case $MINUTES_ENTRY in
             #    [0-9][0-9][0-9]*)  echo "Check pass " &> /dev/null  ;;
              #           *)    echo  -e $RED "--INVALID MINUTES ENTERED ----" $NC
               #     exit $INVALID_MINUTES
                #    ;;
            # esac


            #Also check fpor 1440
              if [  $MINUTES_ENTRY -gt 1440 ]
              then
                    echo -e $RED " ---- PLEASE CHOOSE OPTION 2 FOR BETTER PERFORMANCE MINUTES EXCEED 1 DAY ** CHECK --help FOR MORE INFO ** ---" $NC
                    exit $MIN_EXCEED_LIMIT
              fi



      else
            #Script Cannot Run without Minutes
       # echo   "You chose Cancel."
            echo -e $RED  " Please provide minutes to script to execute -- CHECK --help FOR MORE INFO -- "   $NC
           exit $GUI_MINUTES_NOT_GIVEN
            #Prevent User From Cancelling ...
      fi

############## OPTION SUCCESS RATE OR FAILURE

    if (whiptail --title "--- CIRCLE ANALYSIS ---" --yes-button "Option 1" --no-button "Option 2"  --yesno "CHOOSE OPTION :\n 1 = SUCCESS_RATE  2 = FAILURE_ERROR_CODE_ANALYSIS " 10 60) then

###  OPTION 1 SUCESS RATE #########################################################################
      SF_ENTRY=1
	  else
	    SF_ENTRY=2
	fi
else

   #################  OPTION 2 CHOOSEN #########################################################################

  OPTION_ENTRY=2


################### START_TIME ENTRY ########################################################################
       START_ENTRY=$(whiptail --title "START-TIME ENTRY" --inputbox "Enter Start Time in YYYYMMDDHHMMSSMMM" 10 60 20170101000000000  3>&1 1>&2 2>&3)

       exitstatus=$?
       if [ $exitstatus = 0 ]; then
              strlength=`printf "%s" "$START_ENTRY" | wc -m`
              if [ $strlength -eq 17 ]
              then
                      if [ "$START_ENTRY" -eq  "$START_ENTRY" ] &> /dev/null
                     then
                        echo "yes" &> /dev/null
                       else
                              echo  -e $RED "--INVALID START-TIME ENTERED ----" $NC
                               exit $INVALID_START_TIME
                        fi


                    #  case $START_ENTRY in
                         # [0-9]*) echo "Check pass " &> /dev/null  ;;
                          # *)    echo -e $RED  "--INVALID START-TIME ----" $NC
                           #     exit $INVALID_START_TIME
                           #;;
                     # esac
               else
                       echo -e $RED  "--- INVALID START-TIME ---- " $NC
                        exit $INVALID_START_TIME
               fi
            #Apply a check in Start Time
      else
             echo -e $RED  "Please provide START_TIME for script to execute --- CHECK --help for MORE INFO ---- " $NC
                #Prevent User From Cancelling Start Time
             exit $GUI_START_TIME_NOT_GIVEN
      fi

################## END_TIME ENTRY ###########################################################################


      END_ENTRY=$(whiptail --title "END-TIME ENTRY" --inputbox "Enter End Time in YYYYYMMDDHHMMSSMMM" 10 60 20171231000000000  3>&1 1>&2 2>&3)

     if [ $exitstatus = 0 ]; then
              strlength=`printf "%s" "$END_ENTRY" | wc -m`
              if [ $strlength -eq 17 ]
              then

                    if [ "$END_ENTRY" -eq  "$END_ENTRY" ] &> /dev/null
                     then
                        echo "yes" &> /dev/null
                       else
                              echo  -e $RED "--INVALID END-TIME ENTERED ----" $NC
                               exit $INVALID_END_TIME
                        fi

                      #case $END_ENTRY in
                       #   [0-9]*) echo "Check pass " &> /dev/null  ;;
                        #   *)    echo -e $RED  "--INVALID END-TIME ----" $NC
                         #       exit $INVALID_END_TIME
                          # ;;
                     # esac
               else
                       echo -e $RED  "--- INVALID END-TIME ---- " $NC
                        exit $INVALID_END_TIME
               fi

      else
             echo -e $RED  "Please provide END_TIME for script to execute --- CHECK --help FOR MORE INFO ---- " $NC
                #Prevent User From Cancelling Start Time
             exit $GUI_END_TIME_NOT_GIVEN
      fi
     ############## OPTION SUCCESS RATE OR FAILURE

    if (whiptail --title "--- CDR CIRCLE ANALYSIS ---" --yes-button "Option 1" --no-button "Option 2"  --yesno "CHOOSE OPTION  1 = SUCCESS_RATE  2 = FAILURE_ERROR_CODE_ANALYSIS " 10 60) then

###  OPTION 1 SUCESS RATE #########################################################################
      SF_ENTRY=1
	  else
	    SF_ENTRY=2
	fi
fi
##########################   GUI BUILDING CODE DONE ##############################################################

fi


if [  "$1" -eq 2 ]
then

    #Invoke it by Arguments
    TOTAL_ARGUMENTS="$#"
    OPTION_ENTRY=$2

    if [ -z "$OPTION_ENTRY" ]
    then
        echo -e $RED  "--PLEASE PROVIDE 1 = RELATIVE TIME 2 = ABSOLUTE TIME " $NC
        exit $INVALID_ARGUMENTS
    fi

 if [ "$OPTION_ENTRY"  -eq 1 ]
   then
   
      ### RELATIVE CHECK
      #Total  = 4
       MINUTES_ENTRY=$3


         if [ -z "$MINUTES_ENTRY" ]
                then
                                echo -e $RED  "Please Enter Minutes to be run from current Time" $NC
                                exit $RELATIVE_MINUTES_NOT_GIVEN
         fi
		 
		 #minute check

         if [ "$MINUTES_ENTRY" -eq  "$MINUTES_ENTRY" ] &> /dev/null
           then
              echo "yes" &> /dev/null
           else
                echo  -e $RED "--INVALID MINUTES ENTERED ----" $NC
               exit $INVALID_MINUTES
         fi
          
          if [  $MINUTES_ENTRY -gt 1440 ]
              then
                    echo -e $RED " ---- PLEASE CHOOSE OPTION 2 FOR BETTER PERFORMANCE MINUTES EXCEED 1 DAY ** CHECK --help FOR MORE INFO ** ---" $NC
                    exit $MIN_EXCEED_LIMIT
          fi
		  
			
		  SF_ENTRY=$4

          if [ -z "$SF_ENTRY" ]; then
                                 echo -e $RED "Please supply Option 1 or 2 Check --help for more info :" $NC
                               exit $SF_ENTRY_NOT_GIVEN
           fi


		 
		 if [ $TOTAL_ARGUMENTS -ne 4 ]
        then
              echo -e $RED " --- INVALID ARGUMENTS ---- **CHECK --help FOR MORE INFO** --- "  $NC
              exit $INVALID_ARGUMENTS
        fi
		
	  elif [ "$OPTION_ENTRY" -eq 2 ]
      then
      #Total = 5	
		
		 START_ENTRY=$3

        if [ -z "$START_ENTRY" ]; then
                    echo -e $RED "Please supply the START TIME in format YYYYMMDDHHMMSSMMM" $NC
                    exit $START_TIME_NOT_GIVEN
        fi
        
		
        #Start Check

              strlength=`printf "%s" "$START_ENTRY" | wc -m`
              if [ $strlength -eq 17 ]
              then

                         if [ "$START_ENTRY" -eq  "$START_ENTRY" ] &> /dev/null
                        then
                        echo "yes" &> /dev/null
                        else
                              echo  -e $RED "--INVALID START-TIME ENTERED ----" $NC
                               exit $INVALID_START_TIME
                        fi


                    #  case $START_ENTRY in
                  #        [0-9]*) echo "Check pass " &> /dev/null  ;;
                   #        *)    echo -e $RED  "--INVALID START-TIME ----" $NC
                    #            exit $INVALID_START_TIME
                     #      ;;
                      #esac
               else
                       echo -e $RED  "--- INVALID START-TIME ---- " $NC
                        exit $INVALID_START_TIME
               fi

              END_ENTRY=$4


        if [ -z "$END_ENTRY" ]; then
              echo -e $RED "Please supply the END TIME in format YYYYMMDDHHMMSSMMM" $NC
              exit $END_TIME_NOT_GIVEN
        fi
		
		
		
		#End Time Check
             strlength=`printf "%s" "$END_ENTRY" | wc -m`
              if [ $strlength -eq 17 ]
              then
                          if [ "$END_ENTRY" -eq  "$END_ENTRY" ] &> /dev/null
                     then
                        echo "yes" &> /dev/null
                       else
                              echo  -e $RED "--INVALID END-TIME ENTERED ----" $NC
                               exit $INVALID_END_TIME
                        fi




#                      case $END_ENTRY in
 #                         [0-9]*) echo "Check pass " &> /dev/null  ;;
  #                         *)    echo -e $RED  "--INVALID END-TIME ----" $NC
   #                             exit $INVALID_END_TIME
    #                       ;;
     #                 esac
               else
                       echo -e $RED  "--- INVALID END-TIME ---- " $NC
                        exit $INVALID_END_TIME
               fi


           SF_ENTRY=$5
		  

          if [ -z "$SF_ENTRY" ]; then
                                 echo -e $RED "Please supply option 1 or 2 check --help for more info :" $NC
                               exit $SF_ENTRY_NOT_GIVEN
           fi
		   
		if [ $TOTAL_ARGUMENTS -ne 5 ]
        then
              echo -e $RED " --- INVALID ARGUMENTS ---- **CHECK --help FOR MORE INFO** --- "  $NC
              exit $INVALID_ARGUMENTS
        fi


   else
         echo -e $RED " --- INVALID ARGUMENTS ---- **CHECK --help FOR MORE INFO** --- "  $NC
         exit $INVALID_ARGUMENTS
    fi
		
fi	 


		
		 #Phone Number Check
		 
		 if [ $SF_ENTRY -ne 1 -a $SF_ENTRY -ne 2 ]
		 then
		     echo -e $RED " --- INVALID ARGUMENTS ---- **CHECK --help FOR MORE INFO** --- "  $NC
              exit $SF_ENTRY_INVALID
	     fi		  


if [  "$1" -ne 1 -a "$1" -ne 2 ]
then
   echo -e $RED  "INVALID OPTION CHOOSEN -- CHECK --help for more info " $NC
   exit $INVALID_GUI_ARG_OPTION_SELECTED
fi



#$####################################  EVALUATION OF PARAMETERS ##############################

OPTION=$OPTION_ENTRY
if [  $OPTION -eq 1 ]
then
##Relative
 RELATIVE_MIN=$MINUTES_ENTRY
 S_F=$SF_ENTRY
 
  #Get Current Date Time from System and Convert it to Timestamp YYYYMMDDHHMMSSMMMM
    CURR_DATE_TIME=`date`
    #Converted to Timestamp YYYYMMDDHHMMSSMMM
    START_DURATION=`date -d"$CURR_DATE_TIME" +%Y%m%d%H%M%S%3N`

       END_TIME=`date --date="$RELATIVE_MIN minutes ago"`
                END_DURATION=`date -d"$END_TIME" +%Y%m%d%H%M%S%3N`
     temp=$END_DURATION
     END_DURATION=$START_DURATION
    START_DURATION=$temp

#               echo " $START_DURATION $END_DURATION $PHONE_NUMBER $ACTIVE_TRIGGER_CONTROLLER_IP "


elif [ $OPTION -eq 2 ]
then
   START_DURATION=$START_ENTRY
    END_DURATION=$END_ENTRY
   S_F=$SF_ENTRY
   
   
else
     echo -e $RED " --- INVALID ARGUMENTS ---- **CHECK --help FOR MORE INFO** --- "  $NC
     exit $INVALID_ARGUMENTS

fi


##################################### PARAMETER STUDY OVER ###############################################################################################################################33


echo -e $GREEN " Passed Parameters :  ACTIVE_CONTROLLER_IP [$ACTIVE_TRIGGER_CONTROLLER_IP] START_DURATION [$START_DURATION] END_DURATION [$END_DURATION]  OPTION [$S_F]  " $NC



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
        sh $RT_SCRIPT_PATH/rtAnalysis.sh $SELF_IP_ADDRESS $START_DURATION  $END_DURATION $S_F
 
        else
               /usr/bin/expect<<EOF
                          spawn ssh imsuser@$CLUSTER_ACTIVE_CONTROLLER_IP  $RT_SCRIPT_PATH/rtAnalysis.sh $SELF_IP_ADDRESS  $START_DURATION  $END_DURATION $S_F
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

touch $PATH_REPORT_COMPLETE/Analysis_${CURRTIME}_Circle_Report.txt
COMPLETE_PATH_FINAL=$PATH_REPORT_COMPLETE/Analysis_${CURRTIME}_Circle_Report.txt
echo -e $BLUE  "*********************************************************" >> $COMPLETE_PATH_FINAL $NC
for file in `ls $PATH_FINAL_COLLECTOR`
do
 #    echo "${PATH_FINAL_COLLECTOR}/$file"

      echo "` cat ${PATH_FINAL_COLLECTOR}/$file`" >> $COMPLETE_PATH_FINAL

done

if [ $S_F -eq 1 ]
then
   ## Cal OverAll Success
   
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

fi
   


echo -e $BLUE  "*********************************************************" >> $COMPLETE_PATH_FINAL $NC
 echo "                                                         " >> $COMPLETE_PATH_FINAL

   
 
 


##################
##Collection Final Report :


cp $COMPLETE_PATH_FINAL $COLLECTION_FINAL_REPORT


########################################### GUI BUILDING  -  FINAL REPORT SHOW #############################

#final_report_data=`cat $COMPLETE_PATH_FINAL`

whiptail --title "--FINAL REPORT DETAILS--" --msgbox "CLICK OK TO SEE THE FINAL REPORT" 10 60

echo -e $GREEN  "*********************  FINAL REPORT :  *************************** " $NC
echo "`cat $COMPLETE_PATH_FINAL`"




rm -f ${LOCKFILE}

#################### END OF SCRIPT #######################################
