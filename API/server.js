var express    = require("express");
var mysql      = require('mysql');

var connection = mysql.createConnection({
   host     : 'localhost',
   user     : 'root',
   password : '',
   database : 'db'
});

var app = express();
 
connection.connect(function(err) {
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
      console.log('The solution is: ', rows.affectedRows > 0 ? "true" : "false");  
      if (rows.affectedRows > 0) {
        resp.send("true");
      } else {
        resp.send("false");
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
 
app.listen(process.env.PORT, process.env.IP);