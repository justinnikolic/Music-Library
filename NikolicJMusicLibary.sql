 drop database music_library;
CREATE DATABASE music_library;
USE music_library;


CREATE TABLE artist (
name VARCHAR(64) PRIMARY KEY NOT NULL
);


LOCK TABLES `artist` WRITE;
/*!40000 ALTER TABLE `artist` DISABLE KEYS */;
INSERT INTO `artist` VALUES ('Kid Cudi'),('Travis Scott'),('The Fugees'), ('Pink Floyd');
/*!40000 ALTER TABLE `artist` ENABLE KEYS */;
UNLOCK TABLES;


-- Error Code: 1192. Can't execute the given command because you have active locked tables or an active transaction
-- Error Code: 1136. Column count doesn't match value count at row 1



CREATE TABLE album (
title VARCHAR(64) NOT NULL,
artist VARCHAR(64) NOT NULL,
release_date date NOT NULL,
Primary Key (title, artist),
Foreign Key (artist) REFERENCES artist(name)
ON UPDATE RESTRICT ON DELETE RESTRICT,
UNIQUE (title, artist, release_date)
);

LOCK TABLES `album` WRITE;
/*!40000 ALTER TABLE `album` DISABLE KEYS */;
INSERT INTO `album` VALUES ('Man on the Moon', 'Kid Cudi', '2009-09-15'),('Astroworld', 'Travis Scott', '2018-08-03'),('The Score', 'The Fugees', '1996-02-13'),('The Dark Side of the Moon', 'Pink Floyd', '1973-03-01');
/*!40000 ALTER TABLE `album` ENABLE KEYS */;
UNLOCK TABLES;


CREATE TABLE user (
username VARCHAR(64) PRIMARY KEY NOT NULL,
password VARCHAR(64) NOT NULL,
UNIQUE(username, password)
);


LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES ('justin', '2021'),('julian', 'julian22'),('ellie', 'Sunshine23');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;


CREATE TABLE playlist (
username VARCHAR(64) NOT NULL,
name VARCHAR(64) NOT NULL,
PRIMARY KEY (username, name),
FOREIGN KEY (username) REFERENCES user(username)
ON UPDATE RESTRICT ON DELETE CASCADE
);


LOCK TABLES `playlist` WRITE;
/*!40000 ALTER TABLE `playlist` DISABLE KEYS */;
INSERT INTO `playlist` VALUES ('justin', 'Bops'), ('julian', 'Favorite Songs');
/*!40000 ALTER TABLE `playlist` ENABLE KEYS */;
UNLOCK TABLES;


CREATE TABLE song (
title VARCHAR(64) NOT NULL,
artist VARCHAR(64) NOT NULL,
Primary Key (title, artist),
FOREIGN KEY (artist) REFERENCES artist(name)
ON UPDATE RESTRICT ON DELETE CASCADE,
UNIQUE (title, artist)
);

LOCK TABLES `song` WRITE;
/*!40000 ALTER TABLE `song` DISABLE KEYS */;
INSERT INTO `song` VALUES ('Pursuit of Happiness', 'Kid Cudi'),('SKELETONS', 'Travis Scott'), ('Killing Me Softly', 'The Fugees');
/*!40000 ALTER TABLE `song` ENABLE KEYS */;
UNLOCK TABLES;


CREATE TABLE playlist_song (
  username VARCHAR(64) NOT NULL,
  playlist VARCHAR(64) NOT NULL,
  title VARCHAR(64) NOT NULL,
  artist VARCHAR(64) NOT NULL,
  PRIMARY KEY (username, playlist, title, artist),
  FOREIGN KEY (username, playlist) REFERENCES playlist(username, name)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (title, artist) REFERENCES song(title, artist)
    ON UPDATE RESTRICT ON DELETE RESTRICT
);


LOCK TABLES `playlist_song` WRITE;
/*!40000 ALTER TABLE `playlist_song` DISABLE KEYS */;
INSERT INTO `playlist_song` (username, playlist, title, artist)
VALUES ('justin', 'Bops', 'Pursuit of Happiness', 'Kid Cudi'),
       ('justin', 'Bops', 'SKELETONS', 'Travis Scott'),
       ('justin', 'Bops', 'Killing Me Softly', 'The Fugees');
/*!40000 ALTER TABLE `playlist_song` ENABLE KEYS */;
UNLOCK TABLES;


DELIMITER //
CREATE PROCEDURE DeleteSongFromPlaylist(
    IN p_user VARCHAR(64),
    IN p_playlist VARCHAR(64),
    IN p_title VARCHAR(64),
    IN p_artist VARCHAR(64)
)
BEGIN

	DECLARE rows_affected INT;
    -- Delete the song from the playlist_song table
    DELETE FROM playlist_song
    WHERE username = p_user AND playlist = p_playlist
    AND title = p_title AND artist = p_artist;
    
    SET rows_affected = ROW_COUNT();
    
    IF rows_affected = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'This song does not exist in the playlist.';
    END IF;
    
    COMMIT;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE CreatePlaylist(
    IN p_user VARCHAR(64),
    IN p_playlist VARCHAR(64)
)
BEGIN
    -- Insert the new playlist into the playlist table
    INSERT INTO playlist (username, name)
    VALUES (p_user, p_playlist);
END //
DELIMITER ;

 
 



DELIMITER //
CREATE PROCEDURE AddSongToPlaylist(
    IN p_user VARCHAR(64),
    IN p_playlist VARCHAR(64),
    IN p_title VARCHAR(64),
    IN p_artist VARCHAR(64)
)
BEGIN
    DECLARE duplicate_count INT;
    
    -- Check if the song already exists in the playlist
    SELECT COUNT(*) INTO duplicate_count
    FROM playlist_song
    WHERE username = p_user AND playlist = p_playlist
    AND title = p_title AND artist = p_artist;
    
    IF duplicate_count > 0 THEN
        -- Handle the error: Song already exists in the playlist
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The song already exists in the playlist.';
    ELSE
        -- Add the song to the playlist_song table
        UPDATE playlist_song
        SET username = p_user
        WHERE username = p_user AND playlist = p_playlist;
        
        INSERT INTO playlist_song (username, playlist, title, artist)
        VALUES (p_user, p_playlist, p_title, p_artist);
    END IF;
    
    COMMIT;
END //

DELIMITER ;


 DELIMITER //
CREATE FUNCTION GetPlaylistSongCount(p_user VARCHAR(64), p_playlist VARCHAR(64))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE song_count INT;
    
    -- Get the count of songs in the playlist
    SELECT COUNT(*) INTO song_count
    FROM playlist_song
    WHERE username = p_user AND playlist = p_playlist;
    
    RETURN song_count;
END//

DELIMITER ;


select * from playlist;


SELECT title, artist
FROM playlist_song
WHERE playlist = 'Summertime';










