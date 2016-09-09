#!/bin/bash
#
# This script is create in order to do some random disk test on
# a docker / kubernetes / openshift plateform
# Charles Sabourdin <kanedafromparis@gmail.com>
#
#set -x
#Check for variables ENV
ENV_ARE_SET=0;
ERROR_MSG="";

TIMESLOT=`date +%Y-%m-%d-%H-%M-%S`
echo "$TIMESLOT start"

echo "AUTHUSER : $AUTHUSER"
echo "AUTHPASS : $AUTHPASS"
echo "DESTMAIL : $DESTMAIL"
echo "FILE_PATH : $FILE_PATH"



if [ -d $AUTHUSER ]; then
  ENV_ARE_SET=1;
  ERROR_MSG="  AUTHUSER var for sending email is missing\n";
fi

if [ -d $AUTHPASS ]; then
  ENV_ARE_SET=1;
  ERROR_MSG="$ERROR_MSG  AUTHPASS var for sending email is missing\n";
fi

if [ -d $DESTMAIL ]; then
  ENV_ARE_SET=1;
  ERROR_MSG="$ERROR_MSG  DESTMAIL var for sending email is missing\n";
fi

if [ -d $FILE_PATH ]; then
  ENV_ARE_SET=1;
  ERROR_MSG="$ERROR_MSG  FILE_PATH var for testing is missing\n";
fi

cd $FILE_PATH;
LOG_FILE="$FILE_PATH/sys.log"

if [ $ENV_ARE_SET -eq 0 ]; then
    echo $ERROR_MSG;
    exit 1;
fi

#RND_SIZE="00G"
#while [[ ${RND_SIZE:1:1} == "0" ]]; 
#do 
#   echo "$RND_SIZE";
#   RND_SIZE="${RANDOM:1:2}G"; 
#done
#in our current project this value is not random
RND_SIZE="1G"
#if [ -z $RND_SIZE ]; then
#  echo "$RND_SIZE is not set, using default value 1G " | tee -a $LOG_FILE
#  RND_SIZE="1G"
#fi



echo "$TIMESLOT : test using $RND_SIZE " | tee -a $LOG_FILE

TEST_FILE="$FILE_PATH/test_file.*"

if [ -f "$TEST_FILE" ]
then
  echo "$TIMESLOT : prepare files already exists for $RND_SIZE " | tee -a $LOG_FILE
else
  echo "$TIMESLOT : prepare files for $RND_SIZE " | tee -a $LOG_FILE
  sysbench --file-test-mode=rndrd --test=fileio  --file-total-size=$RND_SIZE prepare | tee -a $LOG_FILE
fi

echo "$TIMESLOT : Running teste with $RND_SIZE " | tee -a $LOG_FILE
sysbench --test=fileio --file-total-size=$RND_SIZE --file-test-mode=rndrw --max-time=300 --max-requests=0 run | tee -a $LOG_FILE
#sysbench --test=fileio --file-total-size="$RND_SIZE" --file-test-mode=seqwr --max-time=300 --max-requests=0 run | tee -a $LOG_FILE
#sysbench --test=fileio --file-total-size="$RND_SIZE" --file-test-mode=rndrw --max-time=300 --max-requests=0 run | tee -a $LOG_FILE
#sysbench --test=fileio --file-total-size="$RND_SIZE" --file-test-mode=rndrw --max-time=300 --max-requests=0 run | tee -a $LOG_FILE
md5sum test_file.* > $TIMESLOT.md5 &&

echo "$TIMESLOT : nb files that fail md5 " | tee -a $LOG_FILE &&
md5sum -c *.md5 | grep -c FAI | tee -a $LOG_FILE &&
md5sum -c *.md5 | grep  FAI | tee -a $LOG_FILE &&
echo "$TIMESLOT : nb files validate md5 " | tee -a $LOG_FILE &&
md5sum -c *.md5 | grep -c OK | tee -a $LOG_FILE &&

echo -e "AuthUser=$AUTHUSER\nAuthPass=$AUTHPASS" >> /etc/ssmtp/ssmtp.conf &&
mail -s "Sysbecnh $TIMESLOT" $DESTMAIL < $LOG_FILE 
rm $LOG_FILE
   

exit 0;