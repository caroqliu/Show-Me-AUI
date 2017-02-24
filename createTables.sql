CREATE TABLE User (
	userId integer PRIMARY KEY,
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

CREATE TABLE Photographer (
	userId integer,
	eventId integer,

	PRIMARY KEY (userId, eventId),

	FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (eventId) REFERENCES Event (eventId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Picture (
	imagePath varchar(256) PRIMARY KEY,
	userId integer NOT NULL,
	eventId integer,
	description varchar(256) NOT NULL,	
	numberSeen integer NOT NULL default 0,
	createTime datetime NOT NULL,
	modificationTime datetime,
	device varchar(256),
	size double, 
	geolocalization varchar(256),
	FOREIGN KEY (userId) REFERENCES User (userId)
		ON DELETE CASCADE,
	FOREIGN KEY (eventId) REFERENCES Event (eventId)
		ON DELETE SET NULL
);

CREATE TABLE InPicture (
	userId integer,
	imagePath varchar(256),

	PRIMARY KEY (userId, imagePath),

	FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (imagePath) REFERENCES Picture (imagePath)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PicRating (
	rating integer NOT NULL,
	userId integer,
	imagePath varchar(256),

	PRIMARY KEY (userId, imagePath),

	FOREIGN KEY (userId) REFERENCES User (userId)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (imagePath) REFERENCES Picture (imagePath)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PicComment (
	commentId integer PRIMARY KEY,
	commentText varchar(256) NOT NULL,
	postTime datetime NOT NULL,
	userId integer,
	imagePath varchar(256),
	FOREIGN KEY (userID) REFERENCES User (userID)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (imagePath) REFERENCES Picture (imagePath)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Tag (
	tagName varchar(256) PRIMARY KEY
);

CREATE TABLE EventTag (
	tagName varchar(256),
	eventId integer,

	PRIMARY KEY (tagName, eventId),

	FOREIGN KEY (tagName) REFERENCES Tag (tagName)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (eventId) REFERENCES Event (eventId)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PictureTag (
	tagName varchar(256),
	imagePath varchar(256),

	PRIMARY KEY (tagName, imagePath),

	FOREIGN KEY (tagName) REFERENCES Tag (tagName)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (imagePath) REFERENCES Picture (imagePath)
		ON UPDATE CASCADE ON DELETE CASCADE
);
