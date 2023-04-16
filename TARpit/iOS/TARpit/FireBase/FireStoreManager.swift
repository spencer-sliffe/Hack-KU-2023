//
//  FireStoreManager.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
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
    
    func uploadFile(_ fileData: Data, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("post_files/\(postId).tar")
        storageRef.putData(fileData, metadata: nil) { metadata, error in
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
                    completion(.failure(NSError(domain: "TARpit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }

    
    func fetchPosts(completion: @escaping (Result<[TarPost], Error>) -> Void) {
        db.collection(postsCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var tarPosts: [TarPost] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let tarPost = self.createPostFrom(data: data)
                tarPosts.append(tarPost)
            }
            completion(.success(tarPosts))
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
                    completion(.failure(NSError(domain: "TARpit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }
    
    private func createPostFrom(data: [String: Any]) -> TarPost {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let author = data["author"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let imageURL = data["imageURL"] as? String
        let fileURL = data["fileURL"] as? String 
        return TarPost(id: id, fileURL: fileURL, timestamp: timestamp, imageURL: imageURL,  author: author, description: description, title: title)


    }
    
    func addPost(_ tarPost: TarPost, completion: @escaping (Result<Void, Error>) -> Void) {
        // Convert the Post struct into a data dictionary
        let data = self.convertPostToData(tarPost)
        db.collection(postsCollection).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func convertPostToData(_ tarPost: TarPost) -> [String: Any] {
        var data: [String: Any] = [
            "id": tarPost.id.uuidString,
            "timestamp": tarPost.timestamp,
            "author": tarPost.author,
            "description": tarPost.description,
            "title": tarPost.title
        ]
        
        if let imageURL = tarPost.imageURL {
            data["imageURL"] = imageURL
        }
        if let fileURL = tarPost.fileURL {
            data["fileURL"] = fileURL
        }
        return data
    }
    
    
    func updatePost(_ tarPost: TarPost, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = tarPost.id
        let data = self.convertPostToData(tarPost)
        db.collection(postsCollection).document(id.uuidString).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deletePost(_ tarPost: TarPost, completion: @escaping (Result<Void, Error>) -> Void) {
        let postId = tarPost.id
        
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
    
    func addPostWithImage(_ tarPost: TarPost, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        self.addPost(tarPost) { result in
            switch result {
            case .success:
                self.uploadImage(image, postId: tarPost.id.uuidString) { result in
                    switch result {
                    case .success(let imageURL):
                        self.updateImageURLForPost(tarPost, imageURL: imageURL, completion: completion)
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
    private func updateImageURLForPost(_ tarPost: TarPost, imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = tarPost.id
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
    
    func deleteFile(fileURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: fileURL)
        
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}
