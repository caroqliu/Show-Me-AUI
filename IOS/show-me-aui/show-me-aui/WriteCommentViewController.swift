//
//  WriteCommentViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/17/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class WriteCommentViewController: UIViewController {
  // UI elements.
  private let textArea = UITextView()
  private let postButton = UIButton()
  private let cancelButton = UIButton()
  
  // The current open image id.
  var currentImageId: Int
  
  // Designated initializer
  init(imageId: Int) {
    self.currentImageId = 1
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup background color.
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    
    // Setup textArea.
    textArea.backgroundColor = UIColor.white
    textArea.layer.cornerRadius = 10.0
    textArea.font = UIFont.preferredFont(forTextStyle: .footnote)
    textArea.delegate = self
    
    // Setup placeholder for the textArea.
    textArea.textColor = UIColor.lightGray
    textArea.text = "Write comment ... (at most 256 characters)"
    
    self.view.addSubview(textArea)
    textArea.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.left.equalTo(view).offset(20)
      make.right.equalTo(view).offset(-20)
      make.height.equalTo(100)
      make.centerY.equalTo(view)
    }
    
    // Setup PostButton.
    postButton.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
    postButton.setTitle("Post", for: .normal)
    postButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
    postButton.backgroundColor = UIColor.lightGray
    self.view.addSubview(postButton)
    postButton.snp.makeConstraints { make in
      make.top.equalTo(textArea.snp.bottom).offset(8)
      make.left.equalTo(view).offset(20)
      make.height.equalTo(20)
    }
    
    // Setup CancelButton.
    cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
    cancelButton.backgroundColor = UIColor.lightGray
    self.view.addSubview(cancelButton)
    cancelButton.snp.makeConstraints { make in
      make.top.equalTo(postButton)
      make.height.equalTo(postButton)
      make.width.equalTo(postButton)
      make.right.equalTo(view).offset(-20)
      make.left.equalTo(postButton.snp.right).offset(4)
    }
    
    self.showAnimate()
  }
  
  func showAnimate() {
    self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    self.view.alpha = 0.0;
    UIView.animate(withDuration: 0.25, animations: {
      self.view.alpha = 1.0
      self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    });
  }
  
  func removeAnimate() {
    UIView.animate(withDuration: 0.25, animations: {
      self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
      self.view.alpha = 0.0;
      }, completion:{(finished : Bool)  in
        if (finished) {
          self.view.removeFromSuperview()
        }
    });
  }
  
  func didTapPost() {
    // TODO: write comment in db.
    print("didTapPost")
    
    guard let text = self.textArea.text, !text.isEmpty else {
      print("empty comment text.")
      return
    }
    
    guard let userId = Session.shared.getUserIdForCurrentSession() else {
      fatalError("No userId found while session is active.")
    }
    
    let api = APIData.shared
    api.queryServer(url: "/saveComment",
                   args: ["text": text,
                        "userid": String(userId),
                       "imageid": String(self.currentImageId)])
    
    self.removeAnimate()
  }
  
  func didTapCancel() {
    print("didTapCancel")
    self.removeAnimate()
  }
}

extension WriteCommentViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      // Remove placeholder and change font color.
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
}
