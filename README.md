# Spotify livetracker with database

I wrote a script to display the current music played via Spotify. It also writes the data to a MySQL database to get some statistics.

***Set up the Spotify API***

Visit [developer.spotify.com](https://developer.spotify.com/documentation/general/guides/authorization/app-settings/) and register an App. 

***Set up the database***

![databaseERM](https://lunetikk.de/lib/exe/fetch.php?w=800&tok=ad9ce5&media=linux:ubuntu:pasted:20230118-151359.png)

Check spotifymusic.sql for the code

***copySpotifyinSQL.sh***

The script will connect via the API to get the artist, track, album and more info, then it will write all the received data to your database and a .php file.

Edit the following variables inside the script

```
LOGIN="local" => MySQL login profile (see below if you need to add one)
DB=spotifymusic => your database if you wish to rename 
TMPFILE=/tmp/spotifyaudio.json => path of the tempfile
WEBFILE=/var/www/mysite/spotifyaudio.php => path of the webfile which should be inside your webfolder 
WEBFILE2=/var/www/mysite/spotifyaudio2.php => path to a second webfile which is used to compare both webfiles
ALBUMIMGLOCALPATH=/var/www/mysite/albumcovers => fullpath to your albumcovers, used to save the images
ALBUMIMGLOCALPATHWEB=albumcovers => shortpath to your albumcovers, used by HTML/ PHP to display the image
ACCESSTOKENFILE="/spotify/token.json" => path to your accesstoken file which will be renewed if your token expired
BASICAUTH="yourAUTHkey" => your basic auth key 
REFRESH_TOKEN="yourREFRESHtoken" => your refresh token
```

If you dont have a MySQL login profile (used for passwordless login), you can add one with the following command (DO NOT USE ROOT AS USER!)

```mysql_config_editor set --login-path=<YOURPROFILENAME> --host=<YOURHOSTIP> --user=<YOURUSERNAME> --password```

Make sure the script is executeable

```chmod +x copySpotifyinSQL.sh```

***Display the music on a website***

Use an iframe to display the content of $WEBFILE (spotifyaudio.php)

```<iframe id="frame1" src="spotifyaudio.php" width="650" height="100"></iframe>```

![livetracker](https://lunetikk.de/lib/exe/fetch.php?cache=&media=linux:ubuntu:pasted:20191005-132910.png)

***Automation***

Setup a cronjob to execute the script every 2 minutes

```*/2 * * * * /spotify/copySpotifyinSQL.sh >/dev/null 2>&1```
