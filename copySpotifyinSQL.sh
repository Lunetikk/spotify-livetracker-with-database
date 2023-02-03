#!/bin/bash

#----------VARS----------#

#Path to logfile
LOGPATH=/var/log/mysqlinsert_spotify.log

#Login for MYSQL
LOGIN="local"

#Database
DB=spotifymusic

TMPFILE=/tmp/spotifyaudio.json
WEBFILE=/var/www/mysite/spotifyaudio.php
WEBFILE2=/var/www/mysite/spotifyaudio2.php

ALBUMIMGLOCALPATH=/var/www/mysite/albumcovers
ALBUMIMGLOCALPATHWEB=albumcovers

ACCESSTOKENFILE="/spotify/token.json"
ACCESSTOKEN=`jq -r ".access_token" $ACCESSTOKENFILE`
BASICAUTH="yourAUTHkey"
REFRESH_TOKEN="yourREFRESHtoken"

#----------GET_CURRENT_TRACK_INFO----------#

GET_CURRENT_TRACK_INFO () {

OFFLINE=`cat $TMPFILE | jq -r '.is_playing'`

#define array length
ARTISTNUMBER=`cat $TMPFILE | jq '.item.artists | length'`

#artists to array
if [ -z "$ARTISTNUMBER" ]
then
      ARTISTNUMBER="0"
fi

if [ "$ARTISTNUMBER" -gt "1" ];then
        declare -ga ARTISTARRAY=()
        for ((i=1; i<=$ARTISTNUMBER; i+=1)); do
                j=$(($i-1))
                ARTISTS=`cat $TMPFILE | jq -r ".item.artists[$j].name"`
                ARTISTARRAY+=("$ARTISTS")
        done
        echo ${ARTISTARRAY[0]}
        echo ${ARTISTARRAY[1]}
        printf -v ARTISTARRAYOUTPUT '%s,' "${ARTISTARRAY[@]}"; echo "${ARTISTARRAYOUTPUT%,}" | sed 's/, */, /g' > /tmp/artists.txt
else
        ARTIST=`cat $TMPFILE | jq -r '.item.artists[0].name'`
fi

#spotifyinfo to vars
export ARTISTSPOTIFYURL=`cat $TMPFILE | jq -r '.item.artists[0].external_urls.spotify'`

export TITLE=`cat $TMPFILE | jq -r '.item.name'`
export TITLENUMBER=`cat $TMPFILE | jq -r '.item.track_number'`
export TITLEPOPULARITY=`cat $TMPFILE | jq -r '.item.popularity'`
export TITLESPOTIFYURL=`cat $TMPFILE | jq -r '.item.external_urls.spotify'`
export TITLESPOTIFYPREVIEWURL=`cat $TMPFILE | jq -r '.item.preview_url'`

export ALBUM=`cat $TMPFILE | jq -r '.item.album.name'`
export ALBUMTYPE=`cat $TMPFILE | jq -r '.item.album.album_type'`
export ALBUMTRACKS=`cat $TMPFILE | jq -r '.item.album.total_tracks'`
export ALBUMSPOTIFYURL=`cat $TMPFILE | jq -r '.item.album.external_urls.spotify'`
export ALBUMRELEASEDATE=`cat $TMPFILE | jq -r '.item.album.release_date'`
export ALBUMIMG=`cat $TMPFILE | jq -r '.item.album.images[0].url'`

export DBALBUMLOCALIMG=$(mysql --login-path=$LOGIN -D $DB -se "SELECT album_localimg FROM album WHERE album_name = '$ALBUM'")
if [ -z "$DBALBUMLOCALIMG" ]
then
	i=100000
	#switch if you wish to use a date
        # IMG$(date +%Y%m%d_%H%M%S).jpg
        # IMG$i.jpg
        while [ -e "$ALBUMIMGLOCALPATH/IMG$i.jpg" ]
	do
		let i++
	done

        export UNIQUEFILE="IMG$i.jpg"
        export ALBUMIMGLOCAL=$ALBUMIMGLOCALPATH/$UNIQUEFILE
        export ALBUMIMGLOCALFILE=$UNIQUEFILE
        export MISSINGALBUMIMGLOCAL=true

	curl -o $ALBUMIMGLOCAL $ALBUMIMG
else
	export MISSINGALBUMIMGLOCAL=false
fi

}

#----------GET_SPOTIFY_TRACK----------#

GET_SPOTIFY_TRACK () {
  curl -X "GET" "https://api.spotify.com/v1/me/player/currently-playing" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer "$ACCESSTOKEN"" > $TMPFILE
}

#----------CHECK_TOKEN----------# 

CHECK_TOKEN () {
  grep -i '"status": 401,\|"status": 400,' $TMPFILE && return 0 || return 1
}

#----------REFRESH_TOKEN----------#

REFRESH_TOKEN () {
  curl -H "Authorization: Basic $BASICAUTH" -d grant_type="refresh_token" -d refresh_token="$REFRESH_TOKEN" -d redirect_uri="http%3A%2F%2Flocalhost:4815%2Fcallback%2F" https://accounts.spotify.com/api/token > $ACCESSTOKENFILE
  ACCESSTOKEN=`jq -r ".access_token" $ACCESSTOKENFILE`
}

#----------WRITE_TO_WEBSITE----------#

WRITE_TO_WEBSITE () {

   echo "" > $WEBFILE

#sometimes $ARTISTS was empty, this is the workaround, might be fixed in the meantime
WHYUNOWORKIN=$(cat /tmp/artists.txt)

if [ -z "$OFFLINE" ]
then
      OFFLINE="false"
fi

if [ "$OFFLINE" != "false" ]; then
   echo "<link rel='stylesheet' href='./styles.css' type='text/css' media='screen' />" >> $WEBFILE
   echo "<div id='iframe'>" >> $WEBFILE
   echo "<table style='width:100%'><col style='width:12%'><col style='width:73%'><col style='width:15%'>" >> $WEBFILE
   echo "<tr>" >> $WEBFILE
   echo "<td>State: </td>" >> $WEBFILE
   echo "<td>PLAYING</td>" >> $WEBFILE
   if [ -z "$DBALBUMLOCALIMG" ] || [ "$DBALBUMLOCALIMG" == "NULL" ]
   then
       echo "<td rowspan='4'><img src='$ALBUMIMGLOCALPATHWEB/$ALBUMIMGLOCALFILE' alt='albumcover' style='width:64px;height:64px;'></td>" >> $WEBFILE
   else
       echo "<td rowspan='4'><img src='$ALBUMIMGLOCALPATHWEB/$DBALBUMLOCALIMG' alt='albumcover' style='width:64px;height:64px;'></td>" >> $WEBFILE
   fi
   echo "</tr>" >> $WEBFILE
   echo "<tr>" >> $WEBFILE
   echo "<td>Artist: </td>" >> $WEBFILE
   if [ -z "$ARTIST" ]; then
       echo "<td>"$WHYUNOWORKIN"</td>" >> $WEBFILE
   else
       echo "<td>"$ARTIST"</td>" >> $WEBFILE
   fi
   echo "<td></td>" >> $WEBFILE
   echo "</tr>" >> $WEBFILE
   echo "<tr>" >> $WEBFILE
   echo "<td>Title: </td>" >> $WEBFILE
   echo "<td>"$TITLE"</td>" >> $WEBFILE
   echo "</tr>" >> $WEBFILE
   echo "<tr>" >> $WEBFILE
   echo "<td>Album: </td>" >> $WEBFILE
   echo "<td>"$ALBUM"</td>" >> $WEBFILE
   echo "</tr>" >> $WEBFILE
   echo "</table>" >> $WEBFILE
   echo "</div>" >> $WEBFILE
else
   echo "<link rel='stylesheet' href='./styles.css' type='text/css' media='screen' />" >> $WEBFILE
   echo "<div id='iframe'>" >> $WEBFILE
   echo "Iam not listening to music right now..." >> $WEBFILE
   echo "</div>" >> $WEBFILE
fi
}

#----------WRITE_TO_MYSQL----------#

WRITE_TO_MYSQL () {

#wanted to use the comparison below but it didnt work. maybe someone knows how to fix it?
#HASH="$(cmp --silent $WEBFILE $WEBFILE2; echo $?)"  # "$?" gives exit status for each comparison
#If a FILE is '-' or missing, read standard input. Exit status is 0 if inputs are the same, 1 if different, 2 if trouble.

HASHONE=$(md5sum $WEBFILE | cut -d " " -f1)
HASHTWO=$(md5sum $WEBFILE2 | cut -d " " -f1)

if [ "$HASHONE" != "$HASHTWO" ]
then  # if status is equal to 1, then execute code

DBTRACK=$(mysql --login-path=$LOGIN -D $DB -se "SELECT track_id FROM track WHERE track_name = '$TITLE'")
DBALBUM=$(mysql --login-path=$LOGIN -D $DB -se "SELECT album_id FROM album WHERE album_name = '$ALBUM'")

if [ "$ARTISTNUMBER" -gt "1" ];then
        for ((i = 0; i < ${#ARTISTARRAY[*]}; i++))
        do
            DBARTIST=$(mysql --login-path=$LOGIN -D $DB -se "SELECT artist_id FROM artist WHERE artist_name = '${ARTISTARRAY[$i]}'")
                if [ -z "$DBARTIST" ]
                then
mysql --login-path=$LOGIN -D $DB << EOFMYSQL
INSERT INTO artist (artist_name,artist_spotifyurl)
VALUES ('${ARTISTARRAY[$i]}','$ARTISTSPOTIFYURL');
EOFMYSQL
                fi
        done
else
        echo "artist"
        echo $ARTIST
        DBARTIST=$(mysql --login-path=$LOGIN -D $DB -se "SELECT artist_id FROM artist WHERE artist_name = '$ARTIST'")
        if [ -z "$DBARTIST" ]
        then
mysql --login-path=$LOGIN -D $DB << EOFMYSQL
INSERT INTO artist (artist_name,artist_spotifyurl)
VALUES ('$ARTIST','$ARTISTSPOTIFYURL');
EOFMYSQL
        fi
fi

if [ "$ARTISTNUMBER" -gt "1" ];then
        DBARTISTNEW=$(mysql --login-path=$LOGIN -D $DB -se "SELECT artist_id FROM artist WHERE artist_name = '${ARTISTARRAY[0]}'")
else
        DBARTISTNEW=$(mysql --login-path=$LOGIN -D $DB -se "SELECT artist_id FROM artist WHERE artist_name = '$ARTIST'")
fi

if [ -z "$DBALBUM" ]
then
        if [ "$ARTISTNUMBER" -gt "1" ];then
mysql --login-path=$LOGIN -D $DB  << EOFMYSQL
INSERT INTO album (album_name,album_cover,artist_id,album_type,album_releasedate,album_tracknumber,album_spotifyurl)
VALUES ('$ALBUM','$ALBUMIMG','$DBARTISTNEW','$ALBUMTYPE','$ALBUMRELEASEDATE','$ALBUMTRACKS','$ALBUMSPOTIFYURL');
EOFMYSQL
        else
mysql --login-path=$LOGIN -D $DB  << EOFMYSQL
INSERT INTO album (album_name,album_cover,artist_id,album_type,album_releasedate,album_tracknumber,album_spotifyurl)
VALUES ('$ALBUM','$ALBUMIMG','$DBARTISTNEW','$ALBUMTYPE','$ALBUMRELEASEDATE','$ALBUMTRACKS','$ALBUMSPOTIFYURL');
EOFMYSQL
        fi
elif $MISSINGALBUMIMGLOCAL
then
mysql --login-path=$LOGIN -D $DB  << EOFMYSQL
UPDATE album SET album_localimg = '$ALBUMIMGLOCALFILE' WHERE album_id = '$DBALBUM'
EOFMYSQL
fi

DBALBUMNEW=$(mysql --login-path=$LOGIN -D $DB -se "SELECT album_id FROM album WHERE album_name = '$ALBUM'")

if [ -z "$DBTRACK" ]
then
        if [ "$ARTISTNUMBER" -gt "1" ];then
mysql --login-path=$LOGIN -D $DB << EOFMYSQL
INSERT INTO track (track_name,album_id,artist_id,track_tracknumber,track_popularity,track_previewurl,track_spotifyurl)
VALUES ('$TITLE','$DBALBUMNEW','$DBARTISTNEW','$TITLENUMBER','$TITLEPOPULARITY','$TITLESPOTIFYPREVIEWURL','$TITLESPOTIFYURL');
EOFMYSQL
        else
mysql --login-path=$LOGIN -D $DB << EOFMYSQL
INSERT INTO track (track_name,album_id,artist_id,track_tracknumber,track_popularity,track_previewurl,track_spotifyurl)
VALUES ('$TITLE',$DBALBUMNEW,'$DBARTISTNEW','$TITLENUMBER','$TITLEPOPULARITY','$TITLESPOTIFYPREVIEWURL','$TITLESPOTIFYURL');
EOFMYSQL
        fi
fi

DBTRACKNEW=$(mysql --login-path=$LOGIN -D $DB -se "SELECT track_id FROM track WHERE track_name = '$TITLE'")
DBALBUMTRACK=$(mysql --login-path=$LOGIN -D $DB -se "SELECT a.album_name, c.track_name FROM album a, connectalbumtrack b, track c WHERE b.album_id = '$DBALBUMNEW' AND b.track_id = '$DBTRACKNEW'")

#connectartisttrack
if [ "$ARTISTNUMBER" -gt "1" ]
then
        for ((i = 0; i < ${#ARTISTARRAY[*]}; i++))
        do
                DBARTISTNEW=$(mysql --login-path=$LOGIN -D $DB -se "SELECT artist_id FROM artist WHERE artist_name = '${ARTISTARRAY[$i]}'")
                DBARTISTTRACK=$(mysql --login-path=$LOGIN -D $DB -se "SELECT a.artist_name, c.track_name FROM artist a, connectartisttrack b, track c WHERE b.artist_id = '$DBARTISTNEW' AND b.track_id = '$DBTRACKNEW'")
                if [ -z "$DBARTISTTRACK" ]
                then
mysql --login-path=$LOGIN -D $DB  << EOFMYSQL
INSERT INTO connectartisttrack (artist_id,track_id)
VALUES ('$DBARTISTNEW','$DBTRACKNEW');
EOFMYSQL
                fi
        done
else
        DBARTISTNEW=$(mysql --login-path=$LOGIN -D $DB -se "SELECT artist_id FROM artist WHERE artist_name = '$ARTIST'")
        DBARTISTTRACK=$(mysql --login-path=$LOGIN -D $DB -se "SELECT a.artist_name, c.track_name FROM artist a, connectartisttrack b, track c WHERE b.artist_id = '$DBARTISTNEW' AND b.track_id = '$DBTRACKNEW'")
        if [ -z "$DBARTISTTRACK" ]
        then
mysql --login-path=$LOGIN -D $DB  << EOFMYSQL
INSERT INTO connectartisttrack (artist_id,track_id)
VALUES ('$DBARTISTNEW','$DBTRACKNEW');
EOFMYSQL
        fi
fi

#connectalbumtrack
if [ -z "$DBALBUMTRACK" ]
then
mysql --login-path=$LOGIN -D $DB << EOFMYSQL
INSERT INTO connectalbumtrack (album_id,track_id)
VALUES ('$DBALBUMNEW','$DBTRACKNEW');
EOFMYSQL
fi

#played is not yet fixed for multiple artists and just uses the first one
if [ "$ARTISTNUMBER" -gt "1" ];then
mysql --login-path=$LOGIN -D $DB << EOFMYSQL
INSERT INTO played (artist_id,track_id,album_id)
VALUES ('$DBARTISTNEW','$DBTRACKNEW','$DBALBUMNEW');
EOFMYSQL
else
mysql --login-path=$LOGIN -D $DB << EOFMYSQL
INSERT INTO played (artist_id,track_id,album_id)
VALUES ('$DBARTISTNEW','$DBTRACKNEW','$DBALBUMNEW');
EOFMYSQL
fi

#copy webfile to webfile2 for comparison in the next run
cp -a $WEBFILE $WEBFILE2

fi
}

#----------MAIN----------#

GET_SPOTIFY_TRACK
CHECK_TOKEN

LASTSTATUS=`echo $?`

if [ "$LASTSTATUS" -eq 0 ];then
        REFRESH_TOKEN
        GET_SPOTIFY_TRACK
fi

GET_CURRENT_TRACK_INFO
WRITE_TO_WEBSITE
WRITE_TO_MYSQL
