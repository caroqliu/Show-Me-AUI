DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Picture;
DROP TABLE IF EXISTS InPicture;
DROP TABLE IF EXISTS PicRating;
DROP TABLE IF EXISTS PicComment;
DROP TABLE IF EXISTS Tag;
DROP TABLE IF EXISTS PictureTag;

CREATE TABLE User (
	userId integer PRIMARY KEY,
	loginId varchar(35) NOT NULL UNIQUE,
	lastName varchar(35) NOT NULL,
	firstName varchar(35) NOT NULL,	
	email varchar(35) NOT NULL,
	userPassword varchar(35) NOT NULL
);

CREATE TABLE Event (
	eventId integer PRIMARY KEY,
	startTime datetime NOT NULL,
	endTime datetime NOT NULL
);

CREATE TABLE Location (
	locationId integer PRIMARY KEY,
	geolocalization varchar(256) NOT NULL
);

CREATE TABLE Picture (
	imageId integer PRIMARY KEY,
	imagePath varchar(256) NOT NULL UNIQUE,
	userId integer NOT NULL,
	eventId integer,
	description varchar(256) NOT NULL,	
	numberSeen integer NOT NULL default 0,
	createTime datetime NOT NULL,
	modificationTime datetime,
	device varchar(256),
	size double, 
	locationId varchar(256),
	CONSTRAINT fk_userTakes FOREIGN KEY (userId) REFERENCES User (userId)
		ON DELETE CASCADE,
	CONSTRAINT fk_evRecords FOREIGN KEY (eventId) REFERENCES Event (eventId)
		ON DELETE SET NULL,
	CONSTRAINT fk_imgLocation FOREIGN KEY (locationId) REFERENCES Location (locationId)
		ON DELETE SET NULL
);

CREATE TABLE InPicture (
	userId integer,
	imageId integer,

	PRIMARY KEY (userId, imageId),

	CONSTRAINT fk_userTagged FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgTags FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PicRating (
	userId integer,
	imageId integer,
	rating integer NOT NULL,

	PRIMARY KEY (userId, imageId),

	CONSTRAINT fk_userRates FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgRated FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PicComment (
	commentId integer PRIMARY KEY,
	commentText varchar(256) NOT NULL,
	postTime datetime NOT NULL,
	userId integer,
	imageId integer,
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
	imageId integer,

	PRIMARY KEY (tagName, imageId),

	CONSTRAINT fk_tagUsed FOREIGN KEY (tagName) REFERENCES Tag (tagName)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_imgUses FOREIGN KEY (imageId) REFERENCES Picture (imageId)
		ON UPDATE CASCADE ON DELETE CASCADE
);
