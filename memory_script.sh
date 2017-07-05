#2 Parameters
START_DURATION=$1  ## Format :  YYYYMMDDHHMMSS
minutes=$2         ## Minutes : Till where further Analysis to be done Ahead

#30 minutes assumed interval
total_iteration=`expr $minutes / 30`

#Analysis on Data1 Available Memory
PATH_DF_FILE=/data1/output_cdr/scripts_output/reports/system
#Start _End TimeStamp YYYYMMDDHHMMSS

#Error Code
REACHED_END_OF_FILE=0


#Convert Date into Standard IST  Format :
Var=`echo "$START_DURATION" | awk '{print substr($word,1,14)}'`
startFilter=` echo $Var | sed -r 's/^.{4}/&-/;:a; s/([-:])(..)\B/\1\2:/;ta;s/:/-/;s/:/ /'`
Date_Start=`date -d "$startFilter"`

df_file_name=df_06_07_2017.log
df_lines=`sed -n -e "/${Date_Start}/,// p"  ${PATH_DF_FILE}/${df_file_name}`
df_data1_lines=`echo "$df_lines" | grep /dev/mapper/vg_data-lvdata1`
df_ist_line=`echo "$df_lines" | grep IST`
total_line=`echo "$df_lines" | grep -n -c  /dev/mapper/vg_data-lvdata1`


iterate=$total_iteration
simple_ok=0

until [ $iterate -eq  0 ]
do
    #Get the first line
    i=`expr $total_iteration - $iterate + 1`

    iterate=`expr $iterate - 1`
    if [ $i -gt  $total_line ]
    then
        echo "Further Entry Not Found ============  Reached end of file"
        exit $REACHED_END_OF_FILE
    fi



    line=`echo "$df_data1_lines" | sed "${i}q;d" `

    avail_data1=`echo  "$line"  | awk '{print $4}'`
    next=$avail_data1
    if [ $i -eq 1 ]
    then

         prev=$avail_data1

   else

        diff=`expr $next - $prev`
   #The Default Unit is Bytes
   #Convert it into gigabytes

   #1073741824  =  1024 * 1024 *1024 in giga
   #1048576 = 1024 *1024 in mega
        kiloDiff=` expr $diff / 1024`
    #    echo $kiloDiff
   if [  $kiloDiff -gt  0 -a $kiloDiff -gt 45 ]
   then
   #Get Time
        simple_ok=1
     ist_line=`echo "$df_ist_line" | sed "${i}q;d" `
     echo "Memory Available sudden  increased from $prev to $next Diff : $kiloDiff  Time Noted  :  $ist_line"
   elif [ $kiloDiff -lt 0 -a  $kiloDiff -lt -45 ]
   then
        simple_ok=1
      ist_line=`echo "$df_ist_line" | sed "${i}q;d" `
      echo "Memory Available sudden decreased from $prev to $next Diff :  $kiloDiff  Time Noted  :  $ist_line"
 #  else
  #    echo "Memory Changes OK"
   fi

  fi

done
if [ $simple_ok -eq 0 ]
then
echo "Memory Changes FINE !!!"
fi


### END OF FILE #####
