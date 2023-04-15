//
//  TarPost.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import Combine
import SwiftUI

class TarPitViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        fetchPosts()
    }
    
    func uploadImage(_ image: UIImage, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        postManager.uploadImage(image, postId: postId, completion: completion)
    }
    
    func fetchPosts() {
        postManager.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self?.posts = posts
                case .failure(let error):
                    print("Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addPost(_ post: Post, image: UIImage? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        if let image = image {
            postManager.uploadImage(image, postId: post.id.uuidString) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    let newPost = post
                    newPost.imageURL = imageURL
                    self?.addPostToDatabase(newPost, completion: completion)
                case .failure(let error):
                    print("Error uploading image: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        } else {
            addPostToDatabase(post, completion: completion)
        }
    }
    
    private func addPostToDatabase(_ post: Post, completion: ((Result<Void, Error>) -> Void)? = nil) {
        postManager.addPost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPosts()
                    completion?(.success(()))
                case .failure(let error):
                    print("Error adding post: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func updatePost(_ post: Post) {
        postManager.updatePost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPosts()
                case .failure(let error):
                    print("Error updating post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deletePost(_ post: Post) {
        postManager.deletePost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let imageURL = post.imageURL {
                        self?.postManager.deleteImage(imageURL: imageURL) { result in
                            switch result {
                            case .success:
                                print("Image deleted successfully")
                            case .failure(let error):
                                print("Error deleting image: \(error.localizedDescription)")
                            }
                        }
                    }
                    self?.fetchPosts()
                case .failure(let error):
                    print("Error deleting post: \(error.localizedDescription)")
                }
            }
        }
    }
}