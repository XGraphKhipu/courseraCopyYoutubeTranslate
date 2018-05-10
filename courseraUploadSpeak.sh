#!/bin/bash
urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_\-\::\/\?=\&]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

if [ $# -ne 2 ]; then
	echo "Error, ingress: ";
	echo " ./program <link_welcome_coursera> <language:es,br,...>";	
	exit 1;
fi 
source config.sh
link=$1;
language=$2;
Language="[translated]";
if [ $language == "es" ]; then
	Language="[Español]";
fi
	
wget $link --header "$cookie" -O welcome.html

strApp=$(cat welcome.html | egrep "window\.App.{0,2}=" | tail -n 1);

App="${strApp#*=}";

echo "app=$App" > infocoursera.js;

cat functionsInforCoursera.js >> infocoursera.js;

numvideo=0
part=0
IDCourse="";
weekmark="";
name_video_tr="";
phantomjs infocoursera.js | while read line; do
	if [ $part -eq 0 ]; then
		IDCourse=$line;
		part=$[part+1];
		continue;
	fi
	week=$(echo $line | cut -d " " -f1);
	idvideo=$(echo ${line#*\ } | cut -d " " -f1);
	rest=${line#*[[};
	namecourse=${rest%%]]*};
	title=${rest#*]]\ };

	echo "week='$week'"
	echo "idvideo='$idvideo'"
	echo "namecourse='$namecourse'"
	echo "title='$title'"
	
	if [ "$weekmark" != "$week" ]; then
		weekmark=$week;
		numvideo=1;
	fi
	#if [ $week -lt 5 ] || ([ $numvideo -lt 11 ] && [ $week -eq 5 ]); then
	#	numvideo=$[numvideo+1];
	#	continue;
	#fi
	wget "https://www.coursera.org/api/onDemandLectureVideos.v1/$IDCourse~$idvideo?includes=video&fields=onDemandVideos.v1(sources%2Csubtitles%2CsubtitlesVtt%2CsubtitlesTxt)" --header "$cookie" -O infoVS;
	sleep 1;
	echo "app=$(cat infoVS)" > infovs.js
	cat functionsInfoVS.js >> infovs.js
	init="";
	error=0;
	while read url; do
		echo $url | grep "%" >>/dev/null;
		if [ $? -ne 0 ]; then
			url=`urlencode "$url"`;
		fi
		if [ ${#url} -lt 45 ]; then
			echo "[`date`] Error url format: '$url'" >> registers.log
			error=1;
			break;
		fi
		if [ -z "$init" ]; then
			wget "$url" --header "$cookie" -O video.mp4
			init="=";
		else
			wget "$url" --header "$cookie" -O subti.txt
		fi
	done < <(phantomjs infovs.js $language);

	sleep 2;
	name_video_tr="$namecourse" 
	if [ $error -eq 0 ]; then
		cat subti.txt | egrep -v "(^[0-9]+$|^([0-9]+:){2}[0-9]+,?[0-9]+?\ -->\ |^$)" > subtitle.txt
		echo "File subtitle.txt created.";
		name_video_tr="$namecourse $Language" 
	fi
	len=$[100-${#name_video_tr}-16];
	if [ ${#title} -gt $len ]; then
		name_video_tr="$name_video_tr ${title:0:$[len-3]}... Class$numvideo Week$week";
	else
		name_video_tr="$name_video_tr $title Class$numvideo Week$week";
	fi
	if [ $error -eq 0 ]; then	
		./traductorVideo.sh subtitle.txt video.mp4 "$name_video_tr.mp4";
	else
		cp video.mp4 "$name_video_tr.mp4";
	fi
	youtube-upload "$name_video_tr.mp4" --client-secrets='/home/user/client_robot.json'  --title="$name_video_tr" --description="$title (semana $week)\nCurso originalmente impartido en Coursera.org."  > idvideo_uploaded;

	for idv in $(cat idvideo_uploaded); do
		if [ ${#idv} -eq 11 ]; then
			echo "Tweeting ... ";
			(sleep 180; python tweet.py "$name_video_tr! http://www.youtube.com/watch?v=$idv")&
			break;
		fi
	done
	rm -f infoVS video.mp4 subti.txt subtitle.txt
	numvideo=$[numvideo+1];
done
















