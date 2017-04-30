//
//  SerializationError.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/16/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation

enum SerializationError: Error {
  case missing(String)
  case invalid(String, Any)
  case timeout
}
