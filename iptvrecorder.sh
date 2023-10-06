#!/bin/bash

SERVER_URL='http://xxx:8080'
USER='xxx'
PASSWORD='xxx'
CHANNEL='2101'
RECORDING_DURATION='12000' # in seconds
FFMPEG_LOGFILE='ffmpeg.log'
FILENAME='testinger'
FILENAME_STAR=$FILENAME'*'
FILENAME_STREAMLIST=$FILENAME'.txt'
FILENAME_LOGFILE=$FILENAME'.log'


TIMESTAMP_LOGFILE=$(date +%Y%m%d_%H%M%S)
echo "[$TIMESTAMP_LOGFILE] Welcome to Que's recorder!" > $FILENAME_LOGFILE


x=0
y=1
BLANK=1
DIED=0   # is ffmpeg died?

TIMESTAMP_FILE=$(date +%s)
COMMAND="ffmpeg -i $SERVER_URL/$USER/$PASSWORD/$CHANNEL -t $RECORDING_DURATION -c:v copy -c:a copy $FILENAME$TIMESTAMP_FILE.mkv"
$COMMAND 2> $FFMPEG_LOGFILE &
while [ $x -le $RECORDING_DURATION ]
do
   TIMESTAMP_LOGFILE=$(date +%Y%m%d_%H%M%S)
   x=$(( $x + 1 ))

   if [ `pgrep ffmpeg > /dev/null; echo $?` -ne 0 ]
   then
      if [ $BLANK -eq 0 ] && [ $DIED -eq 0 ]
      then
         echo '' >> $FILENAME_LOGFILE
      fi
      echo "[$TIMESTAMP_LOGFILE] died" >> $FILENAME_LOGFILE
      TIMESTAMP_FILE=$(date +%s)
      COMMAND="ffmpeg -i $SERVER_URL/$USER/$PASSWORD/$CHANNEL -t $RECORDING_DURATION -c:v copy -c:a copy $FILENAME$TIMESTAMP_FILE.mkv"
      $COMMAND 2> $FFMPEG_LOGFILE &
      y=1
      DIED=1
   else
      if [ $y -eq 1 ]
      then
         echo -n "[$TIMESTAMP_LOGFILE] ." >> $FILENAME_LOGFILE
         BLANK=0
      fi
      if [ $y -ne 1 ]
      then
         echo -n "." >> $FILENAME_LOGFILE
         BLANK=0
      fi
      if [ $y -eq 60 ]
      then
         echo "." >> $FILENAME_LOGFILE
         BLANK=1
         y=0
      fi
      y=$((y + 1))
      DIED=0
   fi
   sleep 1
done

echo "[$TIMESTAMP_LOGFILE] End of loop" >> $FILENAME_LOGFILE

pkill ffmpeg

PWD=pwd
ls $FILENAME_STAR > $FILENAME_STREAMLIST
sed -i 's/^/file /g' $FILENAME_STREAMLIST
ffmpeg -f concat -safe 0 -i $FILENAME_STREAMLIST -c copy $FILENAME.mkv

echo "THE END"
