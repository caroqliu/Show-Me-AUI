# DROP TABLES

DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS PictureTag;
DROP TABLE IF EXISTS PictureComment;
DROP TABLE IF EXISTS PictureRating;
DROP TABLE IF EXISTS InPicture;
DROP TABLE IF EXISTS Picture;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Tag;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS User;

# CREATE TABLES

CREATE TABLE User (
	userId integer unsigned PRIMARY KEY,
	username varchar(35) NOT NULL UNIQUE,
	lastName varchar(35) NOT NULL,
	firstName varchar(35) NOT NULL,	
	email varchar(35) NOT NULL,
	userPassword varchar(35) NOT NULL
);

CREATE TABLE Event (
	eventId integer unsigned PRIMARY KEY,
	startTime datetime NOT NULL,
	endTime datetime NOT NULL
);

CREATE TABLE Location (
	locationId integer unsigned PRIMARY KEY,
	geolocalization varchar(256) NOT NULL
);

CREATE TABLE Picture (
	imageId integer unsigned PRIMARY KEY,
	imagePath varchar(256) NOT NULL UNIQUE,
	userId integer unsigned NOT NULL,
	eventId integer unsigned,
	description varchar(256) NOT NULL default '',	
	numberSeen integer unsigned NOT NULL default 0,
	createTime datetime,
	modificationTime datetime,
	device varchar(256),
	size double, 
	locationId integer unsigned,
	CONSTRAINT fk_userTakes FOREIGN KEY (userId) REFERENCES User (userId)
		ON DELETE CASCADE,
	CONSTRAINT fk_evRecords FOREIGN KEY (eventId) REFERENCES Event (eventId)
		ON DELETE SET NULL,
	CONSTRAINT fk_imgLocation FOREIGN KEY (locationId) REFERENCES Location (locationId)
		ON DELETE SET NULL
);

CREATE TABLE InPicture (
	userId integer unsigned,
	imageId integer unsigned,

	PRIMARY KEY (userId, imageId),

	CONSTRAINT fk_userAppearsIn FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgIncludes FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PictureRating (
	userId integer unsigned,
	imageId integer unsigned,
	rating integer unsigned NOT NULL,

	PRIMARY KEY (userId, imageId),

	CONSTRAINT fk_userRates FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgRated FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PictureComment (
	commentId integer unsigned PRIMARY KEY AUTO_INCREMENT,
	commentText varchar(256) NOT NULL,
	postTime datetime NOT NULL,
	userId integer unsigned NOT NULL,
	imageId integer unsigned NOT NULL,
	CONSTRAINT fk_userSends FOREIGN KEY (userID) REFERENCES User (userID)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgGets FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Tag (
	tagName varchar(256) PRIMARY KEY
);

CREATE TABLE PictureTag (
	tagName varchar(256),
	imageId integer unsigned,

	PRIMARY KEY (tagName, imageId),

	CONSTRAINT fk_tagUsed FOREIGN KEY (tagName) REFERENCES Tag (tagName)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgUses FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Notification (
  notificationId integer unsigned PRIMARY KEY AUTO_INCREMENT,
  userId integer unsigned NOT NULL,
  message varchar(1024) NOT NULL,
  notificationDate datetime NOT NULL,
  
  CONSTRAINT fk_notifyUser FOREIGN KEY (userId) REFERENCES User (userId)
    ON UPDATE CASCADE ON DELETE CASCADE
);# DROP TABLES

DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS PictureTag;
DROP TABLE IF EXISTS PictureComment;
DROP TABLE IF EXISTS PictureRating;
DROP TABLE IF EXISTS InPicture;
DROP TABLE IF EXISTS Picture;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Tag;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS User;

# CREATE TABLES

CREATE TABLE User (
	userId integer unsigned PRIMARY KEY,
	username varchar(35) NOT NULL UNIQUE,
	lastName varchar(35) NOT NULL,
	firstName varchar(35) NOT NULL,	
	email varchar(35) NOT NULL,
	userPassword varchar(35) NOT NULL
);

CREATE TABLE Event (
	eventId integer unsigned PRIMARY KEY,
	startTime datetime NOT NULL,
	endTime datetime NOT NULL
);

CREATE TABLE Location (
	locationId integer unsigned PRIMARY KEY,
	geolocalization varchar(256) NOT NULL
);

CREATE TABLE Picture (
	imageId integer unsigned PRIMARY KEY,
	imagePath varchar(256) NOT NULL UNIQUE,
	userId integer unsigned NOT NULL,
	eventId integer unsigned,
	description varchar(256) NOT NULL default '',	
	numberSeen integer unsigned NOT NULL default 0,
	createTime datetime,
	modificationTime datetime,
	device varchar(256),
	size double, 
	locationId integer unsigned,
	CONSTRAINT fk_userTakes FOREIGN KEY (userId) REFERENCES User (userId)
		ON DELETE CASCADE,
	CONSTRAINT fk_evRecords FOREIGN KEY (eventId) REFERENCES Event (eventId)
		ON DELETE SET NULL,
	CONSTRAINT fk_imgLocation FOREIGN KEY (locationId) REFERENCES Location (locationId)
		ON DELETE SET NULL
);

CREATE TABLE InPicture (
	userId integer unsigned,
	imageId integer unsigned,

	PRIMARY KEY (userId, imageId),

	CONSTRAINT fk_userAppearsIn FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgIncludes FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PictureRating (
	userId integer unsigned,
	imageId integer unsigned,
	rating integer unsigned NOT NULL,

	PRIMARY KEY (userId, imageId),

	CONSTRAINT fk_userRates FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgRated FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PictureComment (
	commentId integer unsigned PRIMARY KEY,
	commentText varchar(256) NOT NULL,
	postTime datetime NOT NULL,
	userId integer unsigned NOT NULL,
	imageId integer unsigned NOT NULL,
	CONSTRAINT fk_userSends FOREIGN KEY (userID) REFERENCES User (userID)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgGets FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Tag (
	tagName varchar(256) PRIMARY KEY
);

CREATE TABLE PictureTag (
	tagName varchar(256),
	imageId integer unsigned,

	PRIMARY KEY (tagName, imageId),

	CONSTRAINT fk_tagUsed FOREIGN KEY (tagName) REFERENCES Tag (tagName)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgUses FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Notification (
  notificationId integer unsigned PRIMARY KEY AUTO_INCREMENT,
  userId integer unsigned NOT NULL,
  message varchar(1024) NOT NULL,
  notificationDate datetime NOT NULL,
  
  CONSTRAINT fk_notifyUser FOREIGN KEY (userId) REFERENCES User (userId)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PictureLike (
  userId integer,
  imageId integer,
  
  PRIMARY KEY (userId, imageId)
);

CREATE TABLE PictureDisLike (
  userId integer,
  imageId integer,
  
  PRIMARY KEY (userId, imageId)
);

delimiter // 
CREATE TRIGGER removeDislikeAfterInsert AFTER INSERT on PictureLike
FOR EACH ROW BEGIN
  DELETE FROM PictureDisLike
  WHERE userId = new.userId AND imageId = new.imageId;
END //
delimiter ;

delimiter // 
CREATE TRIGGER removeLikeAfterInsert AFTER INSERT on PictureDisLike
FOR EACH ROW BEGIN
  DELETE FROM PictureLike
  WHERE userId = new.userId AND imageId = new.imageId;
END //
delimiter ;