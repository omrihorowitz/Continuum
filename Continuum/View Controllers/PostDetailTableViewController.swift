//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    
    var post: Post? {
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func commentButtonTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Comment", message: "New Comment", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New Comment"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            guard let newCommentText = alertController.textFields?.first?.text,
                  !newCommentText.isEmpty else { return self.presentAlert(reason: "missingComment") }
            guard let post = self.post else { return }
            PostController.shared.addComment(text: newCommentText, post: post) { (result) in
                switch result {
                case .success(_):
                    print("Success")
                case .failure(_):
                    print("Failure")
                }
            }
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        let postCaption = post?.caption ?? ""
        guard let photo = post?.photo else { return }
        
        let activityController = UIActivityViewController(activityItems: [postCaption, photo], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    @IBAction func followPostButtonTapped(_ sender: Any) {
    }
    
    func updateViews(){
        photoImageView.image = post?.photo
        tableView.reloadData()
            
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return 0}
        return post.comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)

        guard let comment = post?.comments[indexPath.row] else { return UITableViewCell()}
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = comment.timestamp.dateToString()

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}

extension Date {
    
    func dateToString() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self)
    }
}

extension UIViewController {
    
    func presentAlert(reason: String){
        
        var reasonString: String
        
        switch reason {
        case "missingComment":
            reasonString = "Please enter a comment"
        case "missingImage":
            reasonString = "Please choose an image"
        case "missingCaption":
            reasonString = "Please enter a caption"
        default:
            reasonString = "Alert"
        }
        
        
        let alertController = UIAlertController(title: "Alert", message: reason, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Ok", style: .destructive, handler: nil)

        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}
