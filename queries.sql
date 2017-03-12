# Calcualtes average rating for an image with imageId @id.
delimiter //
create function averageForImageId(id integer unsigned)
returns double
begin
  declare r double default 0;
  select avg(rating) into r
         from PictureRating 
         where imageId = id;
  return r;   
end // 
delimiter ;

# Get path from imageId @id
delimiter //
create function imagePathForId(id integer unsigned)
returns varchar(256)
begin
  declare path varchar(256) default NULL;
  select imagePath into path
  from Picture
  where ImageId = id;
  return path;
end //
delimiter ;

# Trigger to add a notification to user when someone tags him in some picture.
delimiter //
create trigger notifyUser
  after insert on InPicture
  for each row
begin
  declare path varchar(256);
  declare usr varchar(80);
  
  select imagePath, username into path, usr
  from InPicture join Picture 
    on Picture.imageId = InPicture.imageId
    join User on Picture.userId = User.userId
  where InPicture.imageId = new.imageId;
    
  insert into Notification (userId, message, notificationDate)
  values (new.userId, concat(usr, " has tagged you in: ", path), now());
end //
delimiter ;

# Gets all Pictures for a specific event with eventId @id.
delimiter //
create procedure picturesForEventId(id integer unsigned)
begin
  select imageId
  from Picture
  where eventId is not null and eventId = id;
end //
delimiter ;

# Gets all comments for an image.
delimiter //
create procedure commentsForImageId(id integer unsigned)
begin
  select commentId, commentText
  from PictureComment
  where imageId = id;
end //
delimiter ;

# Gets all pictures of a userid @id.
delimiter //
create procedure picturesOfUserWithId(id integer unsigned)
begin
  select imagePath
  from Picture
  where userId = id;
end //
delimiter ;

# Gets all pictures with tag @tag.
delimiter //
create procedure picturesWithTagName(tag varchar(35))
begin
  select imagePath
  from Picture natural join PictureTag
  where tagName = tag;
end //
delimiter ;

# Gets all pictures with location @geo
delimiter //
create procedure picturesWithLocation(geo varchar(256))
begin
  select imagePath
  from Picture natural join Location
  where geolocalization = geo; 
end //
delimiter ;

# Gets photographers that have submitted pictures for some event with eventId @id.
delimiter //
create procedure photographersForEventId(id integer unsigned)
begin
  select userId
  from Picture
  where eventId = id;
end //
delimiter ;

# Gets all pictures where a user with userId is tagged in
delimiter //
create procedure picturesWhereUserWithIdIsTaggedIn(id integer unsigned)
begin
  select imagePath
  from Picture natural join InPicture
  where InPicture.userId = id;
end //
delimiter ;

# Gets all people tagged in some picture.
delimiter //
create procedure peopleTaggedInPictureWith(id integer unsigned)
begin
  select username, firstName, lastName
  from InPicture natural join User
  where InPicture.imageId = id;
end //
delimiter ;

# Gets all pictures taken with device @dev.
delimiter //
create procedure picturesTakenWithDevice(dev varchar(80))
begin
  select imageId
  from Picture
  where device = dev;
end //
delimiter ;

# Get all pictures with seen bigger than or equal to @minSeen.
delimiter //
create procedure picturesWithNumberOfSeenBiggerThanOrEquall(minSeen integer unsigned)
begin
  select imageId
  from Picture
  Where numberSeen >= minSeen; 
end //
delimiter ;

# Get all picture with size less than @sz.
delimiter //
create procedure picturesWithSizeLessThanOrEquallTo(sz double)
begin
  select imageId
  from Picture
  where size <= sz;
end //
delimiter ;

# Get all pictures in time interval [@earliest, @latest].
delimiter //
create procedure picturesInTimeInterval(earliest datetime, latest datetime)
begin
  select imageId
  from Picture
  where createTime between earliest and latest;
end //
delimiter ;