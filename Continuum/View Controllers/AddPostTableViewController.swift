//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, ChildViewControllerDelegate {
    
    var selectedImage: UIImage?

    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captionTextField.text = ""
    }
    
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        
        guard let caption = captionTextField.text, !caption.isEmpty else { return presentAlert(reason: "missingCaption")}
        
        guard let selectedImage = selectedImage else { return presentAlert(reason: "missingImage")}
        PostController.shared.addPostWith(image: selectedImage, caption: caption) { (result) in
            switch result {
            case .success(_):
                self.tabBarController?.selectedIndex = 0
                print("Success")
            case .failure(_):
                print("Failure")
            }
        }
        CustomAlbum.createAlbum(withTitle: "Continuum Social") { (success, error) in
            switch success {
            case true:
                CustomAlbum.addNewImage(selectedImage, toAlbum: "Continuum Social") { (message) in
                    print("Saved!")
                } onFailure: { (error) in
                    print(error?.localizedDescription)
                }
            case false:
                print("Could not save")
                }
            }
    }
    
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSelector" {
            guard let destinationVC = segue.destination as?
                    PhotoSelectorViewController else { return }
            destinationVC.delegate = self
        }
    }
}
