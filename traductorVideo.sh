#!/bin/bash

if [ $# -ne 3 ]; then
	#echo "Error, ingress two arguments: ./translateVideo texto_file video_file output_name";
	exit 1;
fi
texto=$1;
video=$2;
ftexto="${2}f";
posfix=$(date +%s);
faudio="audio_$posfix.wav";
fvideo="video_$posfix.mov";
fvideosd="videospeed_$posfix.mov";
ffvideo=$3;

cat $texto | egrep -v "^.{1,2}:.{1,2}" | sed -r 's/[¿]/\ /g' | sed -r 's/[«»“”]/"/g' | iconv -f utf-8 -t iso-8859-1  > "$ftexto"

text2wave "$ftexto" -o "$faudio"
#espeak -ves-la+m2 -f $ftexto -s140 -w $faudio

r=$(echo $(ffprobe -v error -show_entries format=duration   -of default=noprint_wrappers=1:nokey=1 "$faudio")/$(ffprobe -v error -show_entries format=duration   -of default=noprint_wrappers=1:nokey=1 "$video")|bc -l)
echo "++++++++++++++++++++++++++++++++++";
ffmpeg -i "$video" -vcodec copy -an "$fvideo" -y < /dev/null
echo "++++++++++++++++++++++++++++++++++";

ffmpeg -i "$fvideo" -filter_complex "[0:v]setpts=$r*PTS[v]" -map "[v]" "$fvideosd" -y < /dev/null

echo "++++++++++++++++++++++++++++++++++";
ffmpeg -i "$fvideosd" -i $faudio -vcodec copy "$ffvideo" -y < /dev/null

echo "++++++++++++++++++++++++++++++++++";
echo "Video translated created: '$ffvideo'"; 

rm -f "$faudio" "$fvideo" "$fvideosd" "$fftexto" "$ftexto"
