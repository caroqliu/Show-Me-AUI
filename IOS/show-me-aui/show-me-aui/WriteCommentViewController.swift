//
//  WriteCommentViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/17/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

// WriteCommentDelegate.
protocol WriteCommentDelegate {
  func fetchCommentsAsynchrounously()
  var imageId: Int {get}
}

class WriteCommentViewController: UIViewController {
  // UI elements.  
  @IBOutlet weak var textArea: UITextView!
  @IBOutlet weak var postButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  
  var delegate: WriteCommentDelegate?
    
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup background color.
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    
    // Setup tap gesture in order to dismiss controller.
    let tap = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
    tap.numberOfTapsRequired = 1
    self.view.addGestureRecognizer(tap)
    
    // Setup containerView.
    containerView.backgroundColor = UIColor.white
    containerView.clipsToBounds = true
    containerView.layer.cornerRadius = 10.0
    
    // Setup textArea.
    textArea.backgroundColor = UIColor.white
    textArea.font = UIFont.preferredFont(forTextStyle: .footnote)
    textArea.delegate = self
    
    // Setup placeholder for the textArea.
    textArea.textColor = UIColor.lightGray
    textArea.text = "Write comment ... (at most 256 characters)"
    
    // Setup PostButton.
    postButton.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
    
    // Setup CancelButton.
    cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
    
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
    print("didTapPost")
    
    guard let text = self.textArea.text, !text.isEmpty else {
      print("empty comment text.")
      return
    }
    
    guard let userId = Session.shared.getUserIdForCurrentSession() else {
      fatalError("No userId found while session is active.")
    }
    
    guard let imageId = self.delegate?.imageId else {
      print("Delegate not set: Could not retrieve imageId.")
      return
    }
    
    let url = API.UrlPaths.saveComment
    let parameters: Parameters = [API.Keys.userId: userId,
                                  API.Keys.imageId: imageId,
                                  API.Keys.commentText: text]
    
    Alamofire.request(url, method: .get, parameters: parameters).response { _ in
      // Refresh comments through delegate.
      self.delegate?.fetchCommentsAsynchrounously()
    }
    
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
