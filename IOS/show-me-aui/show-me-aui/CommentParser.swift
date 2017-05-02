//
//  CommentParser.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/28/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import UIKit
import SQLite

class CommentParser {
  static func giveSuggestionsForPrefix(_ prefix: String) -> [String] {
    do {      
      let db = try API.openDB()
      let table = API.DB.usersTable
      let usernames =
        Array(try db.prepare(table.select(API.DB.userName))).map { row in
          return row[API.DB.userName] }
      return usernames.filter { usr in usr.hasPrefix(prefix) }.sorted()
    } catch {
      print(error)
      return []
    }
  }
  
  // Returns the last word.
  static func getLastWord(text: String) -> String {
    let dummyCharacter = " "
    let text = dummyCharacter + text
    
    var index = text.index(before: text.endIndex)
    while !isWhiteSpace(text[index]) {
      index = text.index(before: index)
    }
    
    return text.substring(from: text.index(after:index))
  }
  
  // Check if @arg ch is a whitespace.
  static func isWhiteSpace(_ ch: Character) -> Bool {
    let whitespaces = NSCharacterSet.whitespacesAndNewlines
    if let ch = UnicodeScalar(String(ch)), whitespaces.contains(ch) {
      return true
    }
    return false
  }
  
  // Process @arg text, makes all words sarting with '@' blue, also installs @param attrs.
  // @arg text: text to process.
  // @arg attrs: attributes to install on text.
  // returns an NSAttributedString.
  static func processComment(_ text: String,
                             with attrs: [String: Any] = [:]) -> NSAttributedString {
    let atSign: Character = "@"
    
    // Create attributed string from given text.
    let attributedText = NSMutableAttributedString(string: text)
    
    // Install default attributes.
    let range = NSRange.init(location: 0, length: text.characters.count)
    attributedText.addAttributes(attrs, range: range)
    
    var loc = 0
    var index = text.startIndex
    while index < text.endIndex {
      if text[index] == atSign {
        // At sign found. Get range of next word.
        var word = ""
        let rangeStart = loc
        while index < text.endIndex && !isWhiteSpace(text[index]) {
          if loc > rangeStart {
            // To avoid appending '@'.
            word.append(text[index])
          }
          loc += 1
          index = text.index(after: index)
        }
        
        
        // Highlight the word, only if valid userName.
        do {
          let db = try API.openDB()
          let row = try db.pluck(API.DB.usersTable.filter(API.DB.userName == word))
          if row != nil {
            // Highlight it.
            let range = NSRange.init(location: rangeStart, length: loc - rangeStart)
            attributedText.addAttribute(NSForegroundColorAttributeName,
                                        value: UIColor.blue,
                                        range: range)
          }
        } catch {
          print(error)
        }
      }
      
      // Increment only if not the end.
      if index < text.endIndex {
        loc += 1
        index = text.index(after: index)
      }
    }
    
    return attributedText
  }
  
  // Returns users tagged in @param text.
  // @param text: text to process
  // @returns [(Int, String)]: Ids and user names of users.
  static func usersTaggedInText(_ text: String) -> [(Int, String)] {
    let atSign: Character = "@"
    let words = text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
    
    var users = [(Int, String)]()
    for word in words {
      if word.isEmpty {
        continue
      }
      
      if word[word.startIndex] == atSign {
        let usr = word.substring(from: word.index(after: word.startIndex))
        do {
          let db = try API.openDB()
          let table = API.DB.usersTable
          let userIdCol = API.DB.userId
          let userNameCol = API.DB.userName
          if let row = try db.pluck(table.filter(userNameCol == usr)) {
            users.append((row[userIdCol], row[userNameCol]))
          }
        } catch {
          print(error)
        }
      }
    }
    
    return users
  }
  
}
