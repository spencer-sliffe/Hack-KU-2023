//
//  AccountViewModel.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Firebase
import SwiftUI

class AccountViewModel: ObservableObject {
    @Published var account: Account?
    @Published var isLoading3 = true
    @Published var userPosts: [TarPost] = []
    
    init() {
        fetchAccount()
    }
    
    func fetchAccount() {
        guard let user = Auth.auth().currentUser else {
            print("Error: No user is currently signed in.")
            return
        }
        // Make API call to fetch account data from backend using the user's ID
        let db = Firestore.firestore()
        let ref = db.collection("Accounts").document(user.uid)
        ref.getDocument { (document, error) in
            guard let document = document, document.exists, error == nil else {
                print("Error fetching account data: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            let data = document.data()!
            let email = user.email ?? ""
            var account = Account(id: user.uid, email: email, profilePicture: nil)
            
            self.account = account
            self.isLoading3 = false

            // Fetch user posts
            let emailComponents = email.split(separator: "@")
            let displayName = String(emailComponents[0])
            FireStoreManager.shared.fetchUserPosts(userEmail: displayName) { [weak self] result in
                switch result {
                case .success(let userPosts):
                    self?.userPosts = userPosts
                case .failure(let error):
                    print("Error fetching user posts: \(error.localizedDescription)")
                }
            }
        }
    }

}
