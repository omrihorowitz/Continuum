//
//  PostController.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    static let shared = PostController()
    
    var posts: [Post] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func addComment(text: String, post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        let newComment = Comment(text: text, post: post)
        guard let newCommentRecord = CKRecord(comment: newComment) else { return completion(.failure(.unableToUnwrap))}
        
        let currentPost = post
        currentPost.commentCount += 1
        
        incrementCommentCountFor(post: currentPost) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("Added comment")
                case .failure(_):
                    print("No comment added")
                }
            }
        }
        
        
        publicDB.save(newCommentRecord) { (record, error) in
            DispatchQueue.main.async {
    
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.thrownError(error)))
            }
            guard let record = record,
                  let newComment = Comment(ckRecord: record, post: post) else { return completion(.failure(.unableToUnwrap))}
                post.comments.append(newComment)
                completion(.success(newComment))
            }
        }
    }
    
    func incrementCommentCountFor(post: Post, completion: @escaping(Result<String, PostError>) -> Void){
        guard let postToChange = CKRecord(post: post) else { return completion(.failure(.unableToUnwrap))}
        let operation = CKModifyRecordsOperation(recordsToSave: [postToChange], recordIDsToDelete: nil)
        
                operation.savePolicy = .changedKeys
                operation.qualityOfService = .userInteractive
                operation.modifyRecordsCompletionBlock = { record, recordIDs, error in
                    if let error = error {
                        print("======== ERROR ========")
                        print("Function: (#function)")
                        print("Error: (error)")
                        print("Description: (error.localizedDescription)")
                        print("======== ERROR ========")
                        return completion(.failure(.thrownError(error)))
                    }
                    guard let record = record?.first else { return completion(.failure(.unableToUnwrap))}
                    completion(.success("Successfully updated post"))
                }
                publicDB.add(operation)
    }
    
    func addPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?, PostError>) -> Void){
        let newPost = Post(photo: image, caption: caption)
        guard let newPostRecord = CKRecord(post: newPost) else { return completion(.failure(.unableToUnwrap))}
        publicDB.save(newPostRecord) { (record, error) in
            DispatchQueue.main.async {
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.thrownError(error)))
            }
            guard let record = record,
                  let newPostFromCloud = Post(ckRecord: record) else { return completion(.failure(.unableToUnwrap))}
            self.posts.append(newPostFromCloud)
            completion(.success(newPost))
            }
        }
    }
    
    func fetchPosts(completion: @escaping(Result<[Post], PostError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: PostStrings.recordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                completion(.failure(.thrownError(error)))
            }
            
            guard let allPostsAsRecords = records else { return completion(.failure(.queryError))}
            
            self.posts = allPostsAsRecords.compactMap({Post(ckRecord: $0)})
            completion(.success(self.posts))
            }
        }
    }
    
    func fetchCommentsFor(post: Post, completion: @escaping(Result<[Comment], CommentError>) -> Void) {
        
        let postRefence = post.recordID
            let predicate = NSPredicate(format: "%K == %@",
                CommentStrings.postReferenceKey, postRefence)
            let commentIDs = post.comments.compactMap({$0.recordID})
            let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
            let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (comments, error) in
            DispatchQueue.main.async {
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.queryError))
            }
            
            guard let commentsAsRecords = comments else { return completion(.failure(.unableToUnwrap))}
            
            let commentsAsComments = commentsAsRecords.compactMap({Comment(ckRecord: $0, post: post)})
            post.comments = commentsAsComments
            completion(.success(commentsAsComments))
            }
        }
    }
}
