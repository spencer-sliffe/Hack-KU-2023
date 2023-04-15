//
//  CreatePostView.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct CreatePostView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var tarPitViewModel: TarPitViewModel
    @State private var title = ""
    @State private var username = ""
    @State private var description = ""
    // Additional state variables for market posts
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.yellow, .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            CustomTextField(text: $title, placeholder: "Title")
                            CustomTextField(text: $description, placeholder: "Description")
                        }
                        .padding()
                    }
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
                    let fileURL = "testurl"
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Text("Select Image")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                        ImagePicker(image: $selectedImage)
                    }
                    Spacer()
                    Button(action: {
                        guard let userEmail = Auth.auth().currentUser?.email else {
                            print("Error: User not logged in or email not found")
                            return
                        }
                        let username = userEmail.components(separatedBy: "@")[0]
                        let id = UUID()
                       
                        let timestamp = Date()
                        let tarPost = TarPost(id: id, fileURL: fileURL, timestamp: timestamp, imageURL: nil, author: username, description: description, title: title)
                        
                        if let image = selectedImage {
                            tarPitViewModel.uploadImage(image, postId: id.uuidString) { result in
                                switch result {
                                case .success(let imageURL):
                                    let updatedPost = tarPost
                                    updatedPost.imageURL = imageURL
                                    tarPitViewModel.addPost(updatedPost) { _ in }
                                case .failure(let error):
                                    print("Error uploading image: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            tarPitViewModel.addPost(tarPost) { _ in }
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Post")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
        }
    }
    
    private func loadImage() {
        isImagePickerPresented = false
    }
}
