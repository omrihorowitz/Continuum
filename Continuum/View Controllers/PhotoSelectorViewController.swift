//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/3/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

protocol ChildViewControllerDelegate: AnyObject {
    func photoSelectorViewControllerSelected(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {

    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    
    weak var delegate: ChildViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageButton.setTitle("Add Image", for: .normal)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        addImageButton.setTitle("Add Image", for: .normal)
        postImageView.image = nil
    }
    
    @IBAction func addImageButtonTapped(_ sender: Any) {
        
        addImageButton.setTitle("", for: .normal)
        presentPhotoAlert()
    }


func presentPhotoAlert(){
    let pickerController = UIImagePickerController()
    
    let alertController = UIAlertController(title: "Hey you!", message: "Upload a Photo", preferredStyle: .actionSheet)

    let cameraButton = UIAlertAction(title: "Take a photo", style: .default) { (_) in
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .camera
        self.present(pickerController, animated: true)
    }

    let libraryButton = UIAlertAction(title: "Choose a photo", style: .default) { (_) in
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true)
        self.present(alertController, animated: true)
    }
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        alertController.addAction(cameraButton)
    }
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        alertController.addAction(libraryButton)
    }
    
    present(alertController, animated: true)
    }
}

extension PhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            postImageView.contentMode = .scaleAspectFill
            postImageView.image = pickedImage
            
            delegate?.photoSelectorViewControllerSelected(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
