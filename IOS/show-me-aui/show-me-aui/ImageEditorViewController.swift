//
//  ImageEditorViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/26/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import CoreImage
import UIKit
import SnapKit

protocol ImageEditorDelegate {
  var image: UIImage? {get set}
}

class ImageEditorViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var filterScrollView: UIScrollView!
  
  // Scroll view's content view.
  let contentView = UIView()
  
  typealias FilterPreview = UIButton
  
  // CoreImage filter names.
  let filterNames =
    ["CIFalseColor", "CIPhotoEffectFade", "CIPhotoEffectNoir", "CIPhotoEffectChrome",
     "CISepiaTone", "CIVignette", "CIColorMonochrome"]
  
  // Filter Previews.
  var filterPreviews = [FilterPreview]()
  
  // Maps FilterPreview to filterName.
  var filterNameForPreview = [FilterPreview: String]()
  
  // Last selected filterPreview.
  var lastSelectedFilterPreview: FilterPreview?
  
  // Autolayout constants.
  struct AutoLayoutConstants {
    static let normalHeight = CGFloat(100)
    static let zoomedHeight = CGFloat(120)
    static let spacing      = CGFloat(10)
  }

  // Delegate.
  var delegate: ImageEditorDelegate? {
    didSet {
      if imageView == nil || filterScrollView == nil {
        return
      }
      
      lastSelectedFilterPreview = nil
      imageView.image = delegate?.image
      setupFilterScrollView(image: delegate?.image)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Remove the default back button and left swipe.
    self.navigationItem.hidesBackButton = true
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    
    // Setup save button.
    let saveButton = UIBarButtonItem()
    saveButton.title = "Save"
    saveButton.tintColor = UIColor.red
    saveButton.target = self
    saveButton.action = #selector(didTapSave)
    
    // Add it to the navigationItem.
    self.navigationItem.leftBarButtonItem = saveButton
    
    // Setup filterScrollView.
    self.filterScrollView.showsHorizontalScrollIndicator = false
    self.filterScrollView.showsVerticalScrollIndicator = false
    self.filterScrollView.addSubview(self.contentView)
    contentView.snp.makeConstraints { make in
      make.height.equalTo(AutoLayoutConstants.zoomedHeight)
      make.edges.equalTo(self.filterScrollView)
    }

    // Fetch image from delegate.
    lastSelectedFilterPreview = nil
    imageView.image = delegate?.image
    setupFilterScrollView(image: delegate?.image)
    
  }
  
  func didTapSave() {
    print("didTapSave")
    
    // Save image and exit
    self.delegate?.image = self.imageView.image
    self.navigationController?.popViewController(animated: true)
  }
  
  func setupFilterScrollView(image original: UIImage?) {
    // Remove all preview filterPreviews.
    for view in self.filterPreviews {
      view.removeFromSuperview()
    }
    
    // Remove any old dependency.
    self.filterNameForPreview = [:]
    
    // Check if image is not nil.
    guard let image = original else {
      return
    }
    
    // Create new filterPreviews.
    for filterName in self.filterNames {
      // Setup filter preview.
      let filterPreview = FilterPreview()
      filterPreview.imageView?.contentMode = .scaleAspectFill
      filterPreview.setImage(original!, for: .normal)
      filterPreview.addTarget(self, action: #selector(didTapOnApplyFilter), for: .touchUpInside)
      
      self.filterNameForPreview[filterPreview] = filterName
      self.filterPreviews.append(filterPreview)
      
      DispatchQueue.global().async {
        // Setup filter.
        let filter = CIFilter(name: filterName)!
        let output = self.applyFilterOn(image, using: filter)
        
        // Set filtered image in main thread.
        DispatchQueue.main.async {
          if let filtered = output {
            filterPreview.setImage(filtered, for: .normal)
          }
        }
      }
    }
    
    // Add then to scrollView.
    var index = 0
    for view in filterPreviews {
      // Setup filterPreview.
      self.contentView.addSubview(view)
      view.snp.makeConstraints { make in
        make.centerY.equalTo(view.superview!)
        make.height.equalTo(AutoLayoutConstants.normalHeight)
        make.width.equalTo(view.snp.height)
        
        if index == 0 {
          make.left.equalTo(view.superview!)
        } else {
          make.left.equalTo(filterPreviews[index-1].snp.right).offset(AutoLayoutConstants.spacing)
        }
        
        if index + 1 == filterPreviews.count {
          make.right.equalTo(view.superview!)
        }
      }
      
      index += 1
    }
  }
  
  func didTapOnApplyFilter(_ sender: Any) {
    print("didTapOnApplyFilter")
    
    guard let sender = sender as? FilterPreview else {
      return
    }
    
    guard let filterName = self.filterNameForPreview[sender] else {
      return
    }
    
    guard let image = self.delegate?.image else {
      return
    }
    
    // Apply Filter on current image.
    let filter = CIFilter(name: filterName)
    if let filter = filter,
      let filtered = self.applyFilterOn(image, using: filter) {
      self.imageView.image = filtered
    }
    
    
    // Change the last selected FilterPreview to normal height.
    if let selected = self.lastSelectedFilterPreview {
      selected.snp.updateConstraints { make in
        make.height.equalTo(AutoLayoutConstants.normalHeight)
        make.centerY.equalTo(selected.superview!)
      }
    }
    
    // Zoom current selected FilterPreview.
    sender.snp.updateConstraints { make in
      make.height.equalTo(AutoLayoutConstants.zoomedHeight)
      make.centerY.equalTo(sender.superview!)
    }
    
    // Update last selected.
    lastSelectedFilterPreview = sender
    
  }
  
  func applyFilterOn(_ image: UIImage, using filter: CIFilter) -> UIImage? {
    guard let cgiImage = image.cgImage else {
      return nil
    }
    
    let ciImage = CIImage(cgImage: cgiImage)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    
    let context = CIContext()
    if let output = filter.outputImage,
      let cgiImage = context.createCGImage(output, from: output.extent) {
      return UIImage(cgImage: cgiImage)
    }
    
    return nil
  }
  
}
