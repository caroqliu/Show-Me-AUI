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
  @IBOutlet weak var autoCompleteTableView: UITableView!
  
  var delegate: WriteCommentDelegate?
  
  // Suggestions for auto complete.
  var suggestions = [String]()
  
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
    tap.delegate = self
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
    
    // Setup suggestionTableView.
    autoCompleteTableView.delegate = self
    autoCompleteTableView.dataSource = self
    autoCompleteTableView.tableHeaderView = nil
    autoCompleteTableView.tableFooterView = nil
    autoCompleteTableView.bounces = false
    
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

extension WriteCommentViewController: UIGestureRecognizerDelegate {
  // Gestures on autoCompleteTableView have higher precedence.
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldReceive touch: UITouch) -> Bool {
    if (touch.view?.isDescendant(of: self.autoCompleteTableView))! {
      return false
    }
    return true
  }
  
}

extension WriteCommentViewController: UITableViewDelegate, UITableViewDataSource {
  
  // MARK: UITableViewDataSource
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.suggestions.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = self.suggestions[indexPath.row]
    return cell
  }
  
  // MARK: UITableViewDelegate.
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // If suggestion was chosen then add it to the textView.
    guard var text = self.textArea.text, text.contains("@") else {
      return
    }
    
    // Stops when '@' is encoutered.
    while text.remove(at: text.index(before:text.endIndex)) != "@" { }
    
    // Auto Complete the text with the chosen word.
    let chosenWord = self.suggestions[indexPath.row]
    text = "\(text)@\(chosenWord) "
    
    // Reparse the comment to install StringAttributes.
    let attributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)]
    self.textArea.attributedText = CommentParser.processComment(text, with: attributes)
    
    // Hides the autocomplete suggestion table.
    self.autoCompleteTableView.snp.updateConstraints { make in
      make.height.equalTo(0)
    }
  }
}

extension WriteCommentViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      // Remove placeholder and change font color.
      textView.text = nil
      textView.textColor = UIColor.black
      textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    // Checks if the user is trying to tag a person. If the last word starts with '@',
    // then show the user all possible suggestions.
    let word = CommentParser.getLastWord(text: textView.text)
    if !word.isEmpty && word[word.startIndex] == "@" {
      let nextIndex = word.index(after: word.startIndex)
      self.suggestions =
        CommentParser.giveSuggestionsForPrefix(word.substring(from: nextIndex))
      debugPrint(self.suggestions)
    } else {
      // No suggestions.
      self.suggestions = []
    }
    // Relod table of suggestions.
    self.autoCompleteTableView.reloadData()
    // Update UI.
    autoCompleteTableView.snp.updateConstraints { make in
      debugPrint("tableHeight -> ", min(self.suggestions.count, 4) * 44)
      make.height.equalTo(min(self.suggestions.count, 3) * 40)
    }
  }
  
}
