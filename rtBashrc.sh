# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi


complete -F  _rtCdrCircleAnalysis ./rtCdrCircleAnalysis.sh

_rtCdrCircleAnalysis()
{
 # printf "$COMP_CWORD"
   done=0
  # COMPREPLY=( $(compgen -W  "1=OptionGUI 2=OptionArgument Enter[1or2]" ) ${cur})
   # now_variable=${COMP_WORDS[COMP_CWORD]}
   # prev_variable=${COMP_WORDS[COMP_CWORD -1]}

        if [ "$COMP_CWORD" == 1 ]
        then
             cur=${COMP_WORDS[COMP_CWORD]}
            now_variable=${COMP_WORDS[COMP_CWORD]}
        prev_variable=${COMP_WORDS[COMP_CWORD -1]}
            if [ "$now_variable" == "" -a "$prev_variable" == "./rtCdrCircleAnalysis.sh" -a $done -eq 0 ]
        then

                COMPREPLY=( $(compgen -W  "GUI_OPTION=1 ARGUMENT_OPTION=2  Enter[1or2]" ) )

             fi

                 if [ "$now_variable" == 1  -a $done -ne 1 ]
                 then
                       done=1
                      #Done
                              printf " DONE PRESS ENTER !!! "
          fi

                   if [ "$now_variable" == 2  -a $done -ne 1 ]
                   then
                         done=0
                             cur=${COMP_WORDS[COMP_CWORD]}

                 COMPREPLY=( $(compgen -W  "Enter[1or2] RELATIVE=1 ABSOLUTE=2" ) ${cur})
                   fi
           fi

           if [ "$COMP_CWORD" == 2 ]
           then
               cur=${COMP_WORDS[COMP_CWORD]}
               now_variable=${COMP_WORDS[COMP_CWORD]}
           prev_variable=${COMP_WORDS[COMP_CWORD -1]}


                   if [ "$now_variable" == ""  -a "$prev_variable" == 1 ]
                   then
                        done=1
                                printf "DONE PRESS ENTER !!!"
                   fi

                   if [  "$now_variable"  == "" -a "$prev_variable" == 2 ]
                   then
                        super_prev=${COMP_WORDS[COMP_CWORD -2]}
                    if [ "$super_prev" == "./rtCdrCircleAnalysis.sh" ]
                then
                    #Argument
                     COMPREPLY=( $(compgen -W  "Enter[1or2]  RELATIVE=1 ABSOLUTE=2" ) ${cur})
                 fi
            fi

            if [ "$now_variable" == 1 -a "$prev_variable" ==  2 ]
             then
                  #Relative
                                  super_prev=${COMP_WORDS[COMP_CWORD -2]}
                      if [ "$super_prev" == "./rtCdrCircleAnalysis.sh" ]
                  then
                     COMPREPLY=( $(compgen -W  "Minutes>1440  Eg:[30]" ) ${cur})
                        fi
             fi

             if [ "$now_variable" == 2 -a "$prev_variable" ==  2 ]
             then
                  #Relative
                                  super_prev=${COMP_WORDS[COMP_CWORD -2]}
                      if [ "$super_prev" == "./rtCdrCircleAnalysis.sh" ]
                   then
                      COMPREPLY=( $(compgen -W  "START_TIME Eg[20170101000000000] Format[YYYYMMDDHHMMSSMMM]" ) ${cur})
                        fi
             fi

                   fi


              if [ "$COMP_CWORD" == 3 ]
              then
                 cur=${COMP_WORDS[COMP_CWORD]}
                  now_variable=${COMP_WORDS[COMP_CWORD]}
              prev_variable=${COMP_WORDS[COMP_CWORD -1]}
          #   printf  "COMP_CWORD : $COMP_CWORD now_variable : $now_variable prev_variable : $prev_variable "

                           if [ "$now_variable" == "" -a "$prev_variable" == 2 ]
                           then

                                   COMPREPLY=( $(compgen -W  "START_TIME Eg[20170101000000000] Format[YYYYMMDDHHMMSSMMM]" ) ${cur})
                                fi


                           if [ "$now_variable" == "" -a "$prev_variable" == 1 ]
                           then

                               COMPREPLY=( $(compgen -W  "Minutes>1440 Eg:[30]" ) ${cur})
                                fi


                                if [ "$prev_variable" == 1 -a "$now_variable" != "" ]
                                then
                                   done=0
                                    super_prev=${COMP_WORDS[COMP_CWORD -2]}
                                    super_super_prev=${COMP_WORDS[COMP_CWORD -3]}
                                        if [ "$super_prev" == 2 -a "$super_super_prev" == "./rtCdrCircleAnalysis.sh" ]
                     then
                          cur=${COMP_WORDS[COMP_CWORD]}

                                        COMPREPLY=( $(compgen -W  "PHONE_NUMBER  Eg[919872001093] " ) ${cur})
                                 fi

                                fi

                                 if [ "$prev_variable" == 2 -a "$now_variable" != "" ]
                                then
                                    #super_prev=${COMP_WORDS[COMP_CWORD -2]}
                                    #super_super_prev=${COMP_WORDS[COMP_CWORD -3]}
                                        COMPREPLY=( $(compgen -W  "END_TIME Eg[20171231000000000] Format[YYYYMMDDHHMMSSMMM]" ) ${cur})
                            fi
                     fi

                   if  [ "$COMP_CWORD" == 4 ]
               then
                   cur=${COMP_WORDS[COMP_CWORD]}
                    now_variable=${COMP_WORDS[COMP_CWORD]}
                prev_variable=${COMP_WORDS[COMP_CWORD -1]}

                           if [ "$now_variable" == "" ]
                           then
                              super_prev=${COMP_WORDS[COMP_CWORD -2]}
                                  if [ "$super_prev" == 1 ]
                                  then
                                      COMPREPLY=( $(compgen -W  "PHONE_NUMBER  Eg[919872001093] " ) ${cur})
                                  fi

                                   if [ "$super_prev" == 2 ]
                                   then
                                      COMPREPLY=( $(compgen -W  "END_TIME Eg[20171231000000000] Format[YYYYMMDDHHMMSSMMM]" ) ${cur})
                                        fi
                            fi

                                if [ "$now_variable" != "" ]
                            then
                                    super_prev=${COMP_WORDS[COMP_CWORD -2]}
                                    if [ "$super_prev" == 1 ]
                                    then
                          done=1
                                           printf "DONE PRESS ENTER !!!"
                                         fi

                                         if [ "$super_prev" == 2 ]
                                     then
                                             COMPREPLY=( $(compgen -W  "Enter_PHONE_NUMBER  Eg[919872001093] " ) ${cur})
                                      fi
                                fi
                    fi

                      if [ "$COMP_CWORD" == 5 ]
                  then
                     cur=${COMP_WORDS[COMP_CWORD]}
                      now_variable=${COMP_WORDS[COMP_CWORD]}
                  prev_variable=${COMP_WORDS[COMP_CWORD -1]}

                                    if [ "$now_variable" == "" ]
                                        then
                                            super_prev=${COMP_WORDS[COMP_CWORD -2]}
                                                 super_super_prev=${COMP_WORDS[COMP_CWORD -3]}
                                                 if [ "$super_super_prev"  == 2 ]
                                                  then
                                                     #Phone
                                                         COMPREPLY=( $(compgen -W  "PHONE_NUMBER  Eg[919872001093] " ) ${cur})
                                                 fi

                                                 if [ "$super_super_prev"  == 1 ]
                                                  then

                                                     done=1
                                                  printf "DONE PRESS ENTER !!!"
                                                     #Phone
                                                         #COMPREPLY=( $(compgen -W  "Enter_PHONE_NUMBER  Eg[919872001093] " ) ${cur})
                                                 fi
                                   fi

                                   if [ "$now_variable" !=  "" ]
                                   then
                                       done=1
                                                  printf "DONE PRESS ENTER !!!"
                   fi
                 fi




}
