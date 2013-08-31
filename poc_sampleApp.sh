#!/bin/bash

if [ $# -lt 2 ]; then
    echo -e "\nSyntax : $0 <Input File> <Segment Time> \n"
    echo -e "\nExample: $0 'countdown.mp4' 60 \n"
    exit 1
fi

inputFile=$1;shift;
segmentTime=$1;shift;

echo "----------------- STARTING TRANSCODING IN SEGMENTS ----------------------"
echo "---- Make a file /root/Gst.sh and set path for PKG_CONFIG_PATH, GST_PLUGIN_PATH and LD_LIBRARY_PATH ----------- "
echo "----------------- Input File Name is $inputFile -------------------------"

# This file has the PKG_CONFIG_PATH , GST_PLUGIN_PATH and LD_LIBRARY_PATH Set
source /root/Gst.sh
basename=`echo $inputFile | cut -f 1 -d.`

file_ext=${inputFile##*.}

if [ "$file_ext" = "flv" ]; then 
    echo "------------- FLV File Format...Adding Meta Info to the file---------" 
# Adding the Meta Info for FLV Files for the perfect seeking to happen
    ./yamdi -i $inputFile -o ${basename}_meta.flv 
else
    echo "------------- Not a FLV Format --------------------------------------"
fi;

# Calculating the Duration of the Clip
duration=`ffmpeg -i $inputFile 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,// | sed s/:/*60+/g | bc`
#duration=59.09
echo "----------------- Duration of the Clips is $duration --------------------"
durationClip=${duration/\.*}

# Number of Parallel Segments for transcoding
Segments=`echo $durationClip / $segmentTime | bc`
numSegments=`expr $Segments + 1`
echo "----------------- Number of Segments is $numSegments -------------------"

rm -rf segment_*.ts

segmentStart=0
segmentEnd=$segmentTime
if [ "$numSegments" = "1" ];then
segmentEnd=$duration
fi;
# Running the App Code to get Mpegts Chunks

if [ "$file_ext" = "flv" ]; then 
inputFile=${basename}_meta.flv
fi;

for ((j=0 ; j < $numSegments ; j++))
do
./creategdp $inputFile $segmentStart $segmentEnd $j 
segmentStart=`echo $segmentStart + $segmentTime | bc`
segmentEnd=`echo $segmentEnd + $segmentTime | bc`
if [ $(bc <<< "$segmentEnd > $duration") -eq 1 ]; then
segmentEnd=$duration
fi;
done

for ((j=0 ; j < $numSegments ; j++))
do
./createts $j 
done

#rm -rf xcode_$basename.ts
echo "----------------- Adding the Mpegts Segments ---------------------------"
# Merging the Mpegts Chunks
for ((j=0 ; j < $numSegments ; j++))
do
segment+=mux_$j.ts
segment+="|"
done

echo $segment

# Transmuxing the Mpegts Chunks to Mp4 Format
echo "----------------  Transmuxing to Mp4 Container -------------------------"
echo "----------------- Transcoded File is xcode_$basename.mp4----------------"
ffmpeg -i "concat:$segment" -c copy -bsf:a aac_adtstoasc $basename_xcode.mp4
