//
//  APIData.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/16/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import UIKit

class APIData {
  let serverUrl = "https://aui-lekssays.c9users.io/"
  
  // MARK: Shared Instance
  static let shared = APIData()
  
  private init() {}
  
  // Query the server using a get request.
  // param @url: indicated the url to query.
  // param @args: arguments in the get query.
  // param @completion: completion handler that accepts data.
  func queryServer(url: String, args: [String:String], completion: ((Data) -> Void)? = nil) {
    // Create request url in order to query API.
    let url = makeGetRequestUsing(url: url, args: args)
        
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      guard error == nil else {
        NSLog(error as! String)
        return
      }
      
      guard let data = data else {
        NSLog("no data")
        return
      }
      
      completion?(data)
    }
    
    task.resume()
  }

  // MARK: Convenience
  func makeGetRequestUsing(url sub: String, args: [String:String]) -> URL? {
    let urlComponents = NSURLComponents()
    urlComponents.scheme = "https";
    urlComponents.host = "aui-lekssays.c9users.io";
    urlComponents.path = sub;
    
    // add params
    var items = [NSURLQueryItem]()
    for (key, value) in args {
      items.append(NSURLQueryItem(name: key, value: value))
    }
    urlComponents.queryItems = items as [URLQueryItem]?
    
    return urlComponents.url
  }
}
