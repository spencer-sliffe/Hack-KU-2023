//
//  AccountView.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import SwiftUI
import Firebase

struct AccountView: View {
    @ObservedObject var viewModel = AccountViewModel()
    @State var isLoggedOut = false
    @StateObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading3 {
                ProgressView()
            } else if let account = viewModel.account {
                let emailComponents = account.email.split(separator: "@")
                let displayName = String(emailComponents[0]).uppercased()
                
                if let profilePicture = account.profilePicture {
                    AsyncImage(url: profilePicture) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 20)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding(.bottom, 20)
                }
                
                Text(displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
            } else {
                Text("Failed to fetch account data")
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: {
                authViewModel.signOut() // Call the signOut method on the injected view model
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [.yellow, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
