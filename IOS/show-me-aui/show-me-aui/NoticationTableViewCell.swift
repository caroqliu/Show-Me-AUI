//
//  NoticationTableViewCell.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/30/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit

class NoticationTableViewCell: UITableViewCell {
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var wasReadImageView: UIImageView!
  
  var wasRead: Bool = false {
    didSet {
      if wasRead {
        wasReadImageView.isHidden = true
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // Make it rounded.
    wasReadImageView.layer.cornerRadius = wasReadImageView.bounds.width / 2
  }
  
}
