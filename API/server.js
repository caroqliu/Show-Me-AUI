var express    = require("express");
var mysql      = require('mysql');

var connection = mysql.createConnection({
   host     : 'localhost',
   user     : 'root',
   password : '',
   database : 'db'
 });
 
 var app = express();
 
 connection.connect(function(err){
 if(!err) {
     console.log("Database is connected ... \n\n");  
 } else {
     console.log("Error connecting database ... \n\n");  
 }
 });
 
 // Returns true if email and password are in the database, false otherwise.
 app.get("/authenticate", function(req, resp) {
    var email    = req.query.email,
        password = req.query.password;
        
    var query = "select 1 from User where email=? and userPassword=?;";
    connection.query(query, [email, password], function(err, rows, fields) {
        if (!err) {
            console.log('Athenticate is: ', rows.length);

            resp.setHeader('Content-Type', 'application/json');
            if (rows.length > 0) {
                resp.send(JSON.stringify({ result : true }));
            } else {
                resp.send(JSON.stringify({ result : false }));
            }
        } else {
            console.log(err);
        }
    });
 });
 
// Get all pictures for user Id.
app.get("/picturesForUserId", function(req, resp) {
    var userId = req.query.uid;
    var query = "select imagePath from Picture where userId=?;";

    connection.query(query, [userId], function(err, rows, fields) {
        if (!err) {
            console.log('Image Paths: ', rows);
            resp.send(rows);
        } else {
            console.log(err);
        }
    }); 
});

// Get picture information using image Id.
app.get("/image", function(req, resp) {
    var imageId = req.query.imageId;
    var sql = "select * " +
              "from Picture " +
              "where imageId=?;";

    connection.query(sql, [imageId], function(err, rows, fields) {
        if (!err) {
            console.log('Images: ', rows);
            resp.send(rows);
        } else {
            console.log(err);
        }
    }); 
});

app.get("/getCommentsForImageId", function(req, resp) {
    var imageId = req.query.id;
    var sql = "select * " +
              "from PictureComment " + 
              "where imageId = ?";
    
    connection.query(sql, [imageId], function(error, rows, fields) {
        if (!error) {
            console.log("Comments: ", rows);
            resp.send(JSON.stringify(rows));
        } else {
            console.log(error);
        }
    });
    
});

app.get("/userImageForId", function(req, resp) {
    var id = req.query.id;
    var imageDirectory = __dirname+"/images/profile_images/";
    console.log(imageDirectory+id+".jpg");
    resp.sendFile(imageDirectory+id+".jpg");
});

app.get("/userNameForId", function(req, resp) {
    var id = req.query.id;
    var sql = "select username " +
              "from User " + 
              "where userId = ?";
    
    connection.query(sql, [id], function(error, rows, fields) {
        if (!error) {
            console.log("userName: ", rows);
            resp.send(JSON.stringify(rows[0]));
        } else {
            console.log(error);
        }
    });
});

app.get("/saveComment", function(req, resp) {
  var userid = req.query.userid;
  var text = req.query.text;
  var imageid = req.query.imageid;
  var sql = "insert into PictureComment (commentText, postTime, userId, imageId) "+
            "values (?, now(), ?, ?);";
            
  console.log(userid, text, imageid);
  
  connection.query(sql, [text, userid, imageid], function(error, rows, fields) {
    if (!error) {
      console.log("comment saved: ", rows);
      resp.send(JSON.stringify({ result : true }));
    } else {
      console.log(error);
      resp.send(JSON.stringify({ result : false }));
    }
  });
});

app.get("/saveLike", function(req, resp) {
  var userId = req.query.userId;
  var imageId = req.query.imageId;
  var sql = "insert into PictureLike (userId, imageId) " +
            "values (?, ?);";
  connection.query(sql, [userId, imageId], function(error, rows, fields) {
    if (!error) {
      console.log("Like saved: ", rows);
      resp.send(JSON.stringify({ result : true }));
    } else {
      console.log(error);
      resp.send(JSON.stringify({ result : false }));
    }
  });
});

app.get("/saveDisLike", function(req, resp) {
  var userId = req.query.userId;
  var imageId = req.query.imageId;
  var sql = "insert into PictureDisLike (userId, imageId) " +
            "values (?, ?);";
  connection.query(sql, [userId, imageId], function(error, rows, fields) {
    if (!error) {
      console.log("DisLike saved: ", rows);
      resp.send(JSON.stringify({ result : true }));
    } else {
      console.log(error);
      resp.send(JSON.stringify({ result : false }));
    }
  });
});

app.listen(process.env.PORT, process.env.IP);