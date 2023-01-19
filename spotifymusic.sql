CREATE TABLE `album` (
  `artist_id` smallint(5) NOT NULL DEFAULT '0',
  `album_id` smallint(5) NOT NULL,
  `album_name` char(128) DEFAULT NULL,
  `album_cover` varchar(1000) DEFAULT NULL,
  `album_localimg` varchar(128) DEFAULT NULL,
  `album_type` varchar(128) DEFAULT NULL,
  `album_releasedate` date DEFAULT NULL,
  `album_tracknumber` smallint(5) DEFAULT NULL,
  `album_spotifyurl` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `artist` (
  `artist_id` smallint(5) NOT NULL,
  `artist_name` char(128) DEFAULT NULL,
  `artist_spotifyurl` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `connectalbumtrack` (
  `album_id` smallint(10) NOT NULL,
  `track_id` smallint(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `connectartisttrack` (
  `artist_id` smallint(10) NOT NULL,
  `track_id` smallint(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `played` (
  `artist_id` smallint(5) NOT NULL DEFAULT '0',
  `album_id` smallint(5) NOT NULL DEFAULT '0',
  `track_id` smallint(5) NOT NULL DEFAULT '0',
  `played` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `track` (
  `artist_id` smallint(5) NOT NULL DEFAULT '0',
  `album_id` smallint(5) NOT NULL DEFAULT '0',
  `track_id` smallint(5) NOT NULL,
  `track_name` char(255) DEFAULT NULL,
  `track_popularity` int(20) DEFAULT NULL,
  `track_tracknumber` smallint(5) DEFAULT NULL,
  `track_previewurl` varchar(128) DEFAULT NULL,
  `track_spotifyurl` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `album`
  ADD PRIMARY KEY (`album_id`),
  ADD KEY `album_id` (`album_id`),
  ADD KEY `artist_id` (`artist_id`);

ALTER TABLE `artist`
  ADD PRIMARY KEY (`artist_id`),
  ADD UNIQUE KEY `artist_id_2` (`artist_id`),
  ADD KEY `artist_id` (`artist_id`),
  ADD KEY `artist_id_3` (`artist_id`);

ALTER TABLE `connectalbumtrack`
  ADD KEY `album_id` (`album_id`),
  ADD KEY `track_id` (`track_id`);

ALTER TABLE `connectartisttrack`
  ADD KEY `artist_id` (`artist_id`),
  ADD KEY `track_id` (`track_id`);

ALTER TABLE `played`
  ADD KEY `artist_id` (`artist_id`),
  ADD KEY `album_id` (`album_id`),
  ADD KEY `track_id` (`track_id`);

ALTER TABLE `track`
  ADD PRIMARY KEY (`track_id`),
  ADD KEY `track_id` (`track_id`),
  ADD KEY `artist_id` (`artist_id`),
  ADD KEY `album_id` (`album_id`);

ALTER TABLE `album`
  MODIFY `album_id` smallint(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

ALTER TABLE `artist`
  MODIFY `artist_id` smallint(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

ALTER TABLE `track`
  MODIFY `track_id` smallint(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

ALTER TABLE `album`
  ADD CONSTRAINT `album_ibfk_1` FOREIGN KEY (`artist_id`) REFERENCES `artist` (`artist_id`);

ALTER TABLE `connectalbumtrack`
  ADD CONSTRAINT `connectalbumtrack_ibfk_1` FOREIGN KEY (`track_id`) REFERENCES `track` (`track_id`),
  ADD CONSTRAINT `connectalbumtrack_ibfk_2` FOREIGN KEY (`album_id`) REFERENCES `album` (`album_id`);

ALTER TABLE `connectartisttrack`
  ADD CONSTRAINT `connectartisttrack_ibfk_1` FOREIGN KEY (`artist_id`) REFERENCES `artist` (`artist_id`),
  ADD CONSTRAINT `connectartisttrack_ibfk_2` FOREIGN KEY (`track_id`) REFERENCES `track` (`track_id`);

ALTER TABLE `played`
  ADD CONSTRAINT `played_ibfk_1` FOREIGN KEY (`artist_id`) REFERENCES `artist` (`artist_id`),
  ADD CONSTRAINT `played_ibfk_2` FOREIGN KEY (`album_id`) REFERENCES `album` (`album_id`),
  ADD CONSTRAINT `played_ibfk_3` FOREIGN KEY (`track_id`) REFERENCES `track` (`track_id`);

ALTER TABLE `track`
  ADD CONSTRAINT `track_ibfk_1` FOREIGN KEY (`artist_id`) REFERENCES `artist` (`artist_id`),
  ADD CONSTRAINT `track_ibfk_2` FOREIGN KEY (`album_id`) REFERENCES `album` (`album_id`);
