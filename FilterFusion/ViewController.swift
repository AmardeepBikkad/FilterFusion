//
//  ViewController.swift
//  FilterFusion
//
//  Created by Amardeep Bikkad on 26/01/24.
//

import UIKit
import Photos

enum VisibileControls {
    case allVisibleExceptSelectButton, allHideExceptSelectButton, textViewVisible, none
}

class ViewController: UIViewController {
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var clickButton: UIButton!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var filterStackView: UIStackView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var imagePicker: ImagePickerHelper!
    var currentMode: Mode = .none
    var imageViewToPan: UIImageView?
    var textViewTextColor: UIColor = UIColor.white
    var lastPanPoint: CGPoint?
    var isTyping: Bool = false
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var arrLinesModel = [PointModel]()
    var arrEditPhoto = EditPhotoModel(isPhoto: true)
    var visibileControls: VisibileControls = .allHideExceptSelectButton
    let selectedImageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = ImagePickerHelper(presentationController: self, delegate: self)
        visibileControls = .allHideExceptSelectButton
        hideUnhideEditButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func selectImageButtonAction(_ sender: UIButton) {
        imagePicker.present(from: sender)
    }
    
    @IBAction func addtextButton(_ sender: Any) {
        setupTextFeild()
        currentMode = .textMode
        visibileControls = .textViewVisible
        hideUnhideEditButtons()
    }
    
    @IBAction func filterButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            selectedImageView.image = selectedImageView.image?.addFilter(filter: .Transfer)
        } else if sender.tag == 1 {
            selectedImageView.image = selectedImageView.image?.addFilter(filter: .Fade)
        } else {
            selectedImageView.image = selectedImageView.image?.addFilter(filter: .Mono)
        }
        arrEditPhoto.doneImage = selectedImageView.image
    }
    
    @IBAction func onTapShareButton(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [arrEditPhoto.doneImage], applicationActivities: nil)
           activityVC.popoverPresentationController?.sourceView = self.view
           self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapExitButton(_ sender: Any) {
        visibileControls = .allHideExceptSelectButton
        hideUnhideEditButtons()
        self.arrLinesModel = [PointModel]()
        selectedImageView.image = UIImage()
        
    }

    @IBAction func onTapUndoButton(_ sender: Any) {
        if currentMode == .textMode {
            for subview in selectedImageView.subviews.reversed() {
                subview.removeFromSuperview()
                break
            }
        }
    }
    
    @IBAction func onTapDoneButton(_ sender: Any) {
        if currentMode == .textMode {
            selectedImageView.isUserInteractionEnabled = false
            isTyping = false
            currentMode = .none
            //save
            if let tv = self.selectedImageView.subviews as? [UITextView] {
                self.arrEditPhoto.textViews = tv
                self.arrEditPhoto.textViews?.last?.resignFirstResponder()
            }
            selectedImageView.image = canvasView.toImage()
            arrEditPhoto.doneImage = canvasView.toImage()
            for subview in selectedImageView.subviews.reversed() {
                subview.removeFromSuperview()
                break
            }
        }
        visibileControls = .allVisibleExceptSelectButton
        hideUnhideEditButtons()
    }
    
    private func hideUnhideEditButtons() {
        switch visibileControls {
        case .allHideExceptSelectButton:
            exitButton.isHidden = true
            shareButton.isHidden = true
            addTextButton.isHidden = true
            filterStackView.isHidden = true
            selectedImageView.isHidden = true
            canvasView.isHidden = true
            welcomeLabel.isHidden = false
            filterLabel.isHidden = true
            undoButton.isHidden = true
            doneButton.isHidden = true
            clickButton.isHidden = false
        case .allVisibleExceptSelectButton:
            exitButton.isHidden = false
            shareButton.isHidden = false
            addTextButton.isHidden = false
            filterStackView.isHidden = false
            selectedImageView.isHidden = false
            canvasView.isHidden = false
            welcomeLabel.isHidden = false
            filterLabel.isHidden = false
            undoButton.isHidden = true
            doneButton.isHidden = true
            clickButton.isHidden = true
        case .textViewVisible:
            exitButton.isHidden = true
            shareButton.isHidden = true
            addTextButton.isHidden = true
            filterStackView.isHidden = false
            selectedImageView.isHidden = false
            canvasView.isHidden = false
            welcomeLabel.isHidden = true
            filterLabel.isHidden = false
            undoButton.isHidden = false
            doneButton.isHidden = false
            clickButton.isHidden = true
        case .none:
            return
        }
    }
    
    func loadTextView() {
        for subview in selectedImageView.subviews {
            subview.removeFromSuperview()
        }
        
        let model = arrEditPhoto
        if model.isPhoto {
            if let vc = model.textViews {
                for i in vc {
                    selectedImageView.addSubview(i)
                }
                self.selectedImageView.setNeedsDisplay()
            }
        }
    }
    
    func resetView() {
        self.arrLinesModel = [PointModel]()
        self.selectedImageView.image = UIImage()
        for subview in selectedImageView.subviews {
            subview.removeFromSuperview()
        }
    }
}

extension ViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        resetView()
        visibileControls = .allVisibleExceptSelectButton
        hideUnhideEditButtons()
        arrEditPhoto = EditPhotoModel(isPhoto: true, image: image, doneImage: image)
        selectedImageView.image = image
        selectedImageView.contentMode = .scaleToFill
        loadTextView()
    }
}

extension ViewController {
    @objc func keyboardWillShow(notification: Notification) {
        DispatchQueue.main.async { [self] in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                view.layoutIfNeeded()
                view.setNeedsLayout()
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async { [self] in
            if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                view.layoutIfNeeded()
                view.setNeedsLayout()
            }
        }
    }
}
