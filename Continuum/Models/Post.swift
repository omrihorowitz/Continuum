//
//  Post.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

struct PostStrings {
    static let recordTypeKey = "Post"
    static let captionKey = "caption"
    static let photoAssetKey = "photoAsset"
    static let commentsKey = "comments"
    static let timestampKey = "timestamp"
}

struct CommentStrings {
    static let recordTypeKey = "Comment"
    static let timestampKey = "timestamp"
    static let commentTextKey = "commentText"
    static let postReferenceKey = "postReference"
}

class Post {
    var timestamp: Date
    var caption: String
    var comments: [Comment]
    let recordID: CKRecord.ID
    
    var photo: UIImage?{
        get{
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
         }set{
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var photoData: Data?

    var photoAsset: CKAsset? {
        get {
        guard photoData != nil else {return nil}
        
        let tempDirectory = NSTemporaryDirectory()
        let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
        let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        do {
            try photoData?.write(to: fileURL)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return CKAsset(fileURL: fileURL)
    }
}
    
    init(photo: UIImage?, caption: String, timestamp: Date = Date(), comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.recordID = recordID
        self.photo = photo
    }
}

class Comment {
    var text: String
    let timestamp: Date
    let recordID: CKRecord.ID
    weak var post: Post?
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil}
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String, timestamp: Date = Date(), post: Post, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
    }
}

extension Post: SearchableRecord{
    func matches(searchTerm: String) -> Bool {
        return self.caption == searchTerm || self.comments.contains(where: {
            (comment) -> Bool in
            if comment.text == searchTerm {
                return true
            } else {
                return false
            }
        })
    }
}

extension CKRecord {
    convenience init?(post: Post) {
        self.init(recordType: PostStrings.recordTypeKey, recordID: post.recordID)
        
        self.setValuesForKeys([
            PostStrings.captionKey : post.caption,
            PostStrings.timestampKey : post.timestamp,
            PostStrings.photoAssetKey : post.photoAsset
            
        ])
    }
    
    convenience init?(comment: Comment) {
        self.init(recordType: CommentStrings.recordTypeKey, recordID: comment.recordID)
        
        self.setValuesForKeys([
            CommentStrings.commentTextKey : comment.text,
            CommentStrings.timestampKey : comment.timestamp,
            CommentStrings.postReferenceKey : comment.postReference
        ])
    }
}

extension Post {
    convenience init?(ckRecord: CKRecord) {
        guard let caption = ckRecord[PostStrings.captionKey] as? String,
              let timestamp = ckRecord[PostStrings.timestampKey] as? Date else { return nil}
        
        var foundPhoto: UIImage?
        
        if let photoAsset = ckRecord[PostStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset to data")
            }
        }
        self.init(photo: foundPhoto, caption: caption, timestamp: timestamp,
                  comments: [], recordID: ckRecord.recordID)
    }
}

extension Comment {
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let commentText = ckRecord[CommentStrings.commentTextKey] as? String,
              let timestamp = ckRecord[CommentStrings.timestampKey] as? Date
              else {return nil}
        
        self.init(text: commentText, timestamp: timestamp, post: post, recordID: ckRecord.recordID)
    }
}
