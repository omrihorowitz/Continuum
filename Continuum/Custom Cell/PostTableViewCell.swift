//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postCommentsLabel: UILabel!
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews(){
        postImage.image = post?.photo
        postCaption.text = post?.caption
        guard let comments = post?.comments.count else { return }
        postCommentsLabel.text = "Comments: \(comments)"
    }
}
