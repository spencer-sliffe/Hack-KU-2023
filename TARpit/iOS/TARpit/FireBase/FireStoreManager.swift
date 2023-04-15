//
//  FireStoreManager.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
//
//  FSPostManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23.
//
import Foundation
import FirebaseFirestore
import Firebase
import FirebaseStorage
import SwiftUI

class FireStoreManager {
    private init() {}
    static let shared = FireStoreManager()
    private let db = Firestore.firestore()
    private let postsCollection = "Posts"
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        db.collection(postsCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var posts: [Post] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let post = self.createPostFrom(data: data)
                posts.append(post)
            }
            completion(.success(posts))
        }
    }
    
    func uploadImage(_ image: UIImage, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference().child("post_images/\(postId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }
    
    private func createPostFrom(data: [String: Any]) -> Post {
    }
    
    func addPost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        // Convert the Post struct into a data dictionary
        let data = self.convertPostToData(post)
        db.collection(postsCollection).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func convertPostToData(_ post: TarPost) -> [String: Any] {
        var data: [String: Any] = [
            "id": tarpost.id.uuidString,
            "timestamp": post.timestamp,
        ]
        
        var postTypeString: String
        var marketPostTypeString: String?
        switch post.type {
        case .advertisement(let advertisementPost):
            postTypeString = "advertisement"
            data["poster"] = advertisementPost.poster
            data["title"] = advertisementPost.title
            data["content"] = advertisementPost.content
            data["category"] = advertisementPost.category
        case .help(let helpPost):
            postTypeString = "help"
            data["poster"] = helpPost.poster
            data["question"] = helpPost.question
            data["details"] = helpPost.details
            data["category"] = helpPost.category
        case .news(let newsPost):
            postTypeString = "news"
            data["poster"] = newsPost.poster
            data["headline"] = newsPost.headline
            data["article"] = newsPost.article
            data["category"] = newsPost.category
        case .market(let marketPost):
            postTypeString = "market"
            data["vendor"] = marketPost.vendor
            data["price"] = marketPost.price
            data["category"] = marketPost.category
            
            switch marketPost.type {
            case .hardware(let hardware):
                marketPostTypeString = "hardware"
                data["name"] = hardware.name
                data["condition"] = hardware.condition.rawValue
                data["description"] = hardware.description
            case .software(let software):
                marketPostTypeString = "software"
                data["name"] = software.name
                data["description"] = software.description
            case .service(let service):
                marketPostTypeString = "service"
                data["name"] = service.name
                data["description"] = service.description
            case .other(let other):
                marketPostTypeString = "other"
                data["title"] = other.title
                data["description"] = other.description
            }
            if let marketPostTypeString = marketPostTypeString {
                data["marketPostType"] = marketPostTypeString
            }
        }
        data["postType"] = postTypeString
        if let imageURL = post.imageURL {
            data["imageURL"] = imageURL
        }
        return data
    }
    
    
    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = post.id
        let data = self.convertPostToData(post)
        db.collection(postsCollection).document(id.uuidString).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let postId = post.id
        
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = querySnapshot?.documents.first {
                document.reference.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "No document found with matching id", code: -1, userInfo: nil)))
            }
        }
    }
    
    func addPostWithImage(_ post: Post, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        self.addPost(post) { result in
            switch result {
            case .success:
                self.uploadImage(image, postId: post.id.uuidString) { result in
                    switch result {
                    case .success(let imageURL):
                        self.updateImageURLForPost(post, imageURL: imageURL, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // New function to update the image URL of a post
    private func updateImageURLForPost(_ post: Post, imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = post.id
        let postRef = db.collection(postsCollection).document(id.uuidString)
        postRef.updateData([
            "imageURL": imageURL
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteImage(imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: imageURL)
        
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
