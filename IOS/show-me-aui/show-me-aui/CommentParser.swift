//
//  CommentParser.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/28/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import UIKit

class CommentParser {
  static let usernames = ["maha", "kaito", "simo", "luffy", "benkiran"]
  
  static func giveSuggestionsForPrefix(_ prefix: String) -> [String] {
    return usernames.filter { username in
      return username.hasPrefix(prefix)
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
        let rangeStart = loc
        while index < text.endIndex && !isWhiteSpace(text[index]) {
          loc += 1
          index = text.index(after: index)
        }
        
        // Highlight the word.
        let range = NSRange.init(location: rangeStart, length: loc - rangeStart)
        attributedText.addAttribute(NSForegroundColorAttributeName,
                                    value: UIColor.blue,
                                    range: range)
      }
      
      // Increment only if not the end.
      if index < text.endIndex {
        loc += 1
        index = text.index(after: index)
      }
    }
    
    return attributedText
  }
  
}
