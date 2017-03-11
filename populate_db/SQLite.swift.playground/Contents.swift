import XCPlayground
import SQLite

import Foundation

func randomUniform(_ n: Int) -> Int {
  return Int(arc4random_uniform(UInt32(n)))
}

extension Date {
  init(fromString dateString: String) {
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = "yyyy-MM-dd"
    dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
    let dateFormatter = dateStringFormatter.date(from: dateString)!
    self.init(timeInterval: 0, since: dateFormatter)
  }
  
  static func random() -> Date {
    let yy = Int(arc4random_uniform(18)) + 2000
    let mm = Int(arc4random_uniform(12)) + 1
    let dd = Int(arc4random_uniform(25)) + 1
    
    return Date(fromString: "\(yy)-\(mm)-\(dd)")
  }
}

struct User {
  let userId: Int
  let username: String
  let firstName: String
  let lastName: String
  let email: String
  let userPassword: String
  
  static func fileNames(in filename: String) -> [String]? {
    if let atPath = Bundle.main.path(forResource: filename, ofType: "json") {
      if let data = NSData(contentsOfFile: atPath) as? Data {
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String]
      }
    }
    return nil
  }
  
  static func random() -> User {
    let firstNames = fileNames(in: "first_names")!
    let lastNames = fileNames(in: "last_names")!
    
    let userId = Int(arc4random())
    let firstName = firstNames[randomUniform(firstNames.count)]
    let lastName = lastNames[randomUniform(lastNames.count)]
    let username = firstName + String(userId)
    let email = firstName + lastName + "@somewhere.com"
    let userPassword = "0000"
    
    return User(userId: userId,
                username: username,
                firstName: firstName,
                lastName: lastName,
                email: email,
                userPassword: userPassword)
  }
}

struct Event {
  let eventId: Int
  let startTime: Date
  let endTime: Date
  
  static func random() -> Event {
    let date = Date.random()
    return Event(eventId: Int(arc4random()),
                 startTime: date,
                 endTime: date) // Change to random
  }
}

struct Location {
  let locationId: Int
  let geolocalization: String
  
  static func adresses(in filename: String) -> [String]? {
    if let atPath = Bundle.main.path(forResource: filename, ofType: "json") {
      if let data = NSData(contentsOfFile: atPath) as? Data {
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String]
      }
    }
    return nil
  }
  
  static func random() -> Location {
    let adresses = self.adresses(in: "addresses")!
    return Location(locationId: Int(arc4random()),
                    geolocalization: adresses[randomUniform(adresses.count)])
  }
}

struct Picture {
  let imageId: Int
  let imagePath: String
  let userId: Int
  let eventId: Int?
  let description: String
  let numberSeen: Int
  let createTime: Date
  let modificationTime: Date?
  let device: String?
  let size: Double?
  let locationId: Int?
  
  static func random(withOptions options: [String:Any?]) -> Picture {
    let imageId = Int(arc4random())
    return Picture(imageId: imageId,
                   imagePath: "images/\(imageId)",
      userId: options["userId"] as! Int,
      eventId: options["eventId"] as! Int?,
      description: "description goes here",
      numberSeen: randomUniform(100000),
      createTime: Date.random(), // Change to be inside event Interval if any
      modificationTime: nil,
      device: nil,
      size: Double(randomUniform(100)) * 0.1,
      locationId: options["locationId"] as! Int?)
  }
}

struct PictureRating {
  let userId: Int
  let imageId: Int
  let rating: Int
  
  static func random(withOptions options: [String:Any?]) -> PictureRating {
    return PictureRating(userId: options["userId"] as! Int,
                         imageId: options["imageId"] as! Int,
                         rating: randomUniform(5) + 1)
  }
}

struct PictureComment {
  let commentId: Int
  let commentText: String
  let postTime: Date
  let userId: Int
  let imageId: Int
  
  static func random(withOptions options: [String:Any?]) -> PictureComment {
    return PictureComment(commentId: Int(arc4random()),
                          commentText: "Some text",
                          postTime: Date.random(), // Change to be bigger than creationTime
                          userId: options["userId"] as! Int,
                          imageId: options["imageId"] as! Int)
  }
}

struct Tag {
  let tagName: String
}

struct PictureTag {
  let tagName: String
  let imageId: Int
}

func openDB() -> Connection {
  let path = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    ).first!
  
  print("Path -> " + path)
  
  return try! Connection("\(path)/db.sqlite3")
}

struct UserTable {
  static let userId = Expression<Int>("userId")
  static let username = Expression<String>("username")
  static let firstName = Expression<String>("firstName")
  static let lastName = Expression<String>("lastName")
  static let email = Expression<String>("email")
  static let userPassword = Expression<String>("userPassword")
  static let table = Table("User")
  
  static func insert(_ user: User) {
    let db = openDB()
    
    try! db.run(table.insert(
      userId <- user.userId,
      username <- user.username,
      firstName <- user.firstName,
      lastName <- user.lastName,
      email <- user.email,
      userPassword <- user.userPassword
    ))
  }
}

struct EventTable {
  static let eventId = Expression<Int>("eventId")
  static let startTime = Expression<Date>("startTime")
  static let endTime = Expression<Date>("endTime")
  static let table = Table("Event")
  
  static func insert(_ event: Event) {
    let db = openDB()
    
    do {
      try db.run(table.insert(
        eventId <- event.eventId,
        startTime <- event.startTime,
        endTime <- event.endTime
      ))
    } catch {
      print("insertion failed: \(error)")
    }
  }
}

struct LocationTable {
  static let locationId = Expression<Int>("locationId")
  static let geolocalization = Expression<String>("geolocalization")
  static let table = Table("Location")
  
  static func insert(_ location: Location) {
    let db = openDB()
    
    do {
      try db.run(table.insert(
        locationId <- location.locationId,
        geolocalization <- location.geolocalization
      ))
    } catch {
      print("insertion failed: \(error)")
    }
  }
}

struct PictureTable {
  static let imageId = Expression<Int>("imageId")
  static let imagePath = Expression<String>("imagePath")
  static let userId = Expression<Int>("userId")
  static let description = Expression<String>("description")
  static let numberSeen = Expression<Int>("numberSeen")
  static let createTime = Expression<Date>("createTime")
  static let modificationTime = Expression<Date?>("modificationTime")
  static let device = Expression<String?>("device")
  static let size = Expression<Double?>("size")
  static let locationId = Expression<Int?>("locationId")
  static let table = Table("Picture")
  
  static func insert(_ picture: Picture) {
    let db = openDB()
    
    do {
      try db.run(table.insert(
        imageId <- picture.imageId,
        imagePath <- picture.imagePath,
        userId <- picture.userId,
        description <- picture.description,
        numberSeen <- picture.numberSeen,
        createTime <- picture.createTime,
        modificationTime <- picture.modificationTime,
        device <- picture.device,
        size <- picture.size,
        locationId <- picture.locationId
      ))
    } catch {
      print("insertion failed: \(error)")
    }
  }
}

struct PictureRatingTable {
  static let userId = Expression<Int>("userId")
  static let imageId = Expression<Int>("imageId")
  static let rating = Expression<Int>("rating")
  static let table = Table("PictureRating")
  
  static func insert(_ pictureRating: PictureRating) {
    let db = openDB()
    
    do {
      try db.run(table.insert(
        userId <- pictureRating.userId,
        imageId <- pictureRating.imageId,
        rating <- pictureRating.rating
      ))
    } catch {
      print("insertion failed: \(error)")
    }
  }
}

struct PictureCommentTable {
  static let commentId = Expression<Int>("commentId")
  static let commentText = Expression<String>("commentText")
  static let postTime = Expression<Date>("postTime")
  static let userId = Expression<Int>("userId")
  static let imageId = Expression<Int>("imageId")
  static let table = Table("PictureComment")
  
  static func insert(_ comment: PictureComment) {
    let db = openDB()
    
    do {
      try db.run(table.insert(
        commentId <- comment.commentId,
        commentText <- comment.commentText,
        postTime <- comment.postTime,
        userId <- comment.userId,
        imageId <- comment.userId
      ))
    } catch {
      print("insertion failed: \(error)")
    }
  }
}

struct TagTable {
  static let tagName = Expression<String>("tagName")
  static let table = Table("Tag")
  
  static func insert(_ tag: Tag) {
    let db = openDB()
    do {
      try db.run(table.insert(
        tagName <- tag.tagName
      ))
    } catch {
      print("insertion(TagTable) failed: \(error)")
    }
  }
}

struct PictureTagTable {
  static let tagName = Expression<String>("tagName")
  static let imageId = Expression<Int>("imageId")
  static let table = Table("PictureTag")
  
  static func insert(_ picTag: PictureTag) {
    let db = openDB()
    do {
      try db.run(table.insert(
        tagName <- picTag.tagName,
        imageId <- picTag.imageId
      ))
    } catch {
      print("insertion(TagTable) failed: \(error)")
    }
  }
}

func createTables() {
  if let path = Bundle.main.path(forResource: "create_tables", ofType: "sql") {
    let db = openDB()
    let script = try! String(contentsOfFile: path)
    try! db.execute(script)
  }
}

createTables()

// Generate users.
let numberOfUsers = 50
var users = [User]()
for _ in 1...numberOfUsers {
  users.append(User.random())
  UserTable.insert(users.last!)
}

// Generate Events.
let numberOfEvents = 10
var events = [Event]()
for _ in 1...numberOfEvents {
  events.append(Event.random())
  EventTable.insert(events.last!)
}

// Generate Locations.
let numberOfLocations = 40
var locations = [Location]()
for _ in 1...numberOfLocations {
  locations.append(Location.random())
  LocationTable.insert(locations.last!)
}

// Generate Pictures.
let numberOfPictures = 100
var pictures = [Picture]()
for _ in 1...numberOfPictures {
  let options: [String:Any?] =
    ["userId": users[0].userId, "locationId": nil, "eventId": nil]
  pictures.append(Picture.random(withOptions: options))
  PictureTable.insert(pictures.last!)
}

// Generate Picture Rating.
let numberOfPictureRatings = 400
var pictureRatings = [PictureRating]()
for _ in 1...numberOfPictureRatings {
  let options: [String:Any?] =
    ["userId": users[randomUniform(users.count)].userId,
     "imageId": pictures[randomUniform(pictures.count)].imageId]
  pictureRatings.append(PictureRating.random(withOptions: options))
  PictureRatingTable.insert(pictureRatings.last!)
}

// Generate Picture Comments.
let numberOfComments = 100
var comments = [PictureComment]()
for _ in 1...numberOfComments {
  let options: [String:Any?] =
    ["userId": users[randomUniform(users.count)].userId,
     "imageId": pictures[randomUniform(pictures.count)].imageId]
  comments.append(PictureComment.random(withOptions: options))
  PictureCommentTable.insert(comments.last!)
}

// Generate tags.
// TODO(achraf): Generate better tag names.
var tags = [Tag]()
for c0 in ["a", "b", "c"] {
  for c1 in ["m", "n", "q"] {
    for c2 in ["x", "y", "z"] {
      tags.append(Tag(tagName: c0 + c1 + c2))
      TagTable.insert(tags.last!)
    }
  }
}

// Generate Tags in Picture.
var pictureTags = [PictureTag]()
for picture in pictures {
  pictureTags.append(PictureTag(tagName: tags[randomUniform(tags.count)].tagName,
                                imageId: picture.imageId))
  PictureTagTable.insert(pictureTags.last!)
}
