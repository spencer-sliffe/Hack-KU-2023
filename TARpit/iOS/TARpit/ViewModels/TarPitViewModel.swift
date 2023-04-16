//
//  TarPost.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Combine
import SwiftUI

class TarPitViewModel: ObservableObject {
    @Published var tarPosts: [TarPost] = []
    private var cancellables: Set<AnyCancellable> = []
    private let postManager = FireStoreManager.shared
    
    init() {
        fetchPosts()
    }
    
    func uploadImage(_ image: UIImage, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.postManager.uploadImage(image, postId: postId, completion: completion)
        }
    }
    
    func fetchPosts() {
        DispatchQueue.global(qos: .background).async {
            self.postManager.fetchPosts { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let tarPosts):
                        self?.tarPosts = tarPosts
                    case .failure(let error):
                        print("Error fetching posts: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func addPost(_ tarPost: TarPost, image: UIImage? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        if let image = image {
            DispatchQueue.global(qos: .background).async {
                self.postManager.uploadImage(image, postId: tarPost.id.uuidString) { [weak self] result in
                    switch result {
                    case .success(let imageURL):
                        let newPost = tarPost
                        newPost.imageURL = imageURL
                        self?.addPostToDatabase(newPost, completion: completion)
                    case .failure(let error):
                        print("Error uploading image: \(error.localizedDescription)")
                        completion?(.failure(error))
                    }
                }
            }
        } else {
            addPostToDatabase(tarPost, completion: completion)
        }
    }
    
    private func addPostToDatabase(_ tarPost: TarPost, completion: ((Result<Void, Error>) -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            self.postManager.addPost(tarPost) { [weak self] result in
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
    }
    
    func updatePost(_ tarPost: TarPost) {
        DispatchQueue.global(qos: .background).async {
            self.postManager.updatePost(tarPost) { [weak self] result in
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
    }
    
    func uploadFile(_ fileData: Data, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.postManager.uploadFile(fileData, postId: postId, completion: completion)
        }
    }
    
    func deletePost(_ tarPost: TarPost) {
        DispatchQueue.global(qos: .background).async {
            self.postManager.deletePost(tarPost) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        if let imageURL = tarPost.imageURL {
                            self?.postManager.deleteImage(imageURL: imageURL) { result in
                                switch result {
                                case .success:
                                    print("Image deleted successfully")
                                case .failure(let error):
                                    print("Error deleting image: \(error.localizedDescription)")
                                }
                            }
                        }
                        if let fileURL = tarPost.fileURL {
                            self?.postManager.deleteFile(fileURL: fileURL) { result in
                                switch result {
                                case .success:
                                    print("File deleted successfully")
                                case .failure(let error):
                                    print("Error deleting file: \(error.localizedDescription)")
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
    
    func fetchUserPosts(userEmail: String, completion: @escaping (Result<[TarPost], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.postManager.fetchUserPosts(userEmail: userEmail) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
