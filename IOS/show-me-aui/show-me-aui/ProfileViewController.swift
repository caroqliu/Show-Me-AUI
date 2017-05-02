//
//  ProfileViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 5/2/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SnapKit

class ProfileViewController: UIViewController {
  @IBOutlet weak var myCollectionView: UICollectionView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  
  var imagesUploaded = [UIImage?]()
  
  var userId: Int = 61755
  
  fileprivate let sectionInsets = UIEdgeInsets(top: 30.0, left: 5.0, bottom: 30.0, right: 5.0)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setaup after loading the view.
    myCollectionView.delegate = self
    myCollectionView.dataSource = self
    
    profileImageView.image = #imageLiteral(resourceName: "profile-placeholder")
    profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0
    profileImageView.clipsToBounds = true
    
    // Download userImage.
    var parameters = [API.Keys.userId: userId]
    var url = API.UrlPaths.userImageWithId
    Alamofire.download(url, method: .get, parameters: parameters, encoding: URLEncoding.default,
                       headers: nil, to: API.Keys.alamofireDownloadDestination)
      .response { response in
        if response.error == nil, let imagePath = response.destinationURL?.path {
          DispatchQueue.main.async {
            // In case the image is not found on the server use a placeholder.
            let image = UIImage(contentsOfFile: imagePath) ?? #imageLiteral(resourceName: "profile-placeholder")
            self.profileImageView.image = image
          }
        }
    }

    // Fetch username.
    parameters = [API.Keys.userId: userId]
    url = API.UrlPaths.userNameWithId
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON { response in
        let json = response.result.value as? [String: String]
        DispatchQueue.main.async {
          self.userNameLabel.text = json?[API.Keys.userName]
        }
    }

    // Download images uploaded by this user.
    url = API.UrlPaths.picturesForUserId
    parameters = [API.Keys.userId: userId]
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global(qos: .utility)) { response in
      
      switch response.result {
      case .success(let value):
        let jsonArray = JSON(value)
        let count = jsonArray.count
        self.imagesUploaded = Array(repeatElement(nil, count: count))
        var index = 0
        for (_, json) : (String, JSON) in jsonArray {
          if let path = json[API.Keys.imagePath].string {
            let url = API.UrlPaths.imageAtPath
            let params: Parameters = [API.Keys.imagePath: path]
            
            let which = index
            Alamofire.download(url, method: .get, parameters: params, encoding: URLEncoding.default,
                               headers: nil, to: API.Keys.alamofireDownloadDestination)
              .response { response in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                  DispatchQueue.main.async {
                    self.imagesUploaded[which] = UIImage(contentsOfFile: imagePath)
                    self.myCollectionView.reloadData()
                  }
                }
              }
          }
          index += 1
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  
}


extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  var reuseIdentifier: String {
    return "ImageCell"
  }
  
  //1
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  //2
  func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return imagesUploaded.count
  }
  
  //3
  func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                  for: indexPath) as! ImageCollectionViewCell
    cell.backgroundColor = UIColor.white
    cell.imageView.image = imagesUploaded[indexPath.row]
    
    return cell
  }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    var itemsPerRow: CGFloat {
      return 3
    }
    
    //2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  //3
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
