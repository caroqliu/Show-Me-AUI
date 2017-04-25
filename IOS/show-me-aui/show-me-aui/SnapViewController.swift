//
//  SnapViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/24/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit

class SnapViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  var imagePicker: UIImagePickerController!
  
  // Current image in the imageView.
  var image: UIImage? {
    didSet {
      // Update imageView
      self.imageView.image = image
      // Activated or deactive upload button.
      self.uploadButton.isEnabled =  (image != nil) ? true : false
    }
  }
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var uploadButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.uploadButton.isEnabled = false
    
    // Initialize the tap gesture recognizer.
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
    tap.numberOfTapsRequired = 1
    self.imageView.isUserInteractionEnabled = true
    self.imageView.addGestureRecognizer(tap)
  }
  
  func didTap() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
      self.takePhoto()
    }))
    alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { _ in
      self.useCameraRoll()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .default))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func takePhoto() {
    if UIImagePickerController.isSourceTypeAvailable(
        UIImagePickerControllerSourceType.camera) {
      self.imagePicker =  UIImagePickerController()
      self.imagePicker.delegate = self
      self.imagePicker.sourceType = .camera
    
      present(self.imagePicker, animated: true, completion: nil)
    }
  }
  
  func useCameraRoll() {
    if UIImagePickerController.isSourceTypeAvailable(
        UIImagePickerControllerSourceType.savedPhotosAlbum) {
      self.imagePicker = UIImagePickerController()
      
      self.imagePicker.delegate = self
      self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
      
      present(self.imagePicker, animated: true, completion: nil)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    imagePicker.dismiss(animated: true, completion: nil)
    self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
  }
  
  @IBAction func didTapUpload(_ sender: Any) {
    if let image = self.image {
      PageletUploader.upload(image: image)
    }
  }
}
