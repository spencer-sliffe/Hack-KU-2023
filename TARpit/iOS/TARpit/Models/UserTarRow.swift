//
//  UserTarRow.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/16/23.
//


import Foundation
import SwiftUI
import MessageUI
import Foundation
import SwiftUI
import MessageUI

struct UserTarRow: View {
    @EnvironmentObject var viewModel: TarPitViewModel
    let tarPost: TarPost
    @State private var isShowingMailView = false
    @State private var showingDeleteAlert = false
    
    private func deletePost() {
        showingDeleteAlert = true
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }
    
    private func sendByEmail() {
        isShowingMailView = true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(tarPost.title)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            if let imageURL = tarPost.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.55)
                .cornerRadius(10)
                .padding(.bottom, 4)
            }
            
            Text(tarPost.description)
                .font(.body)
                .padding(.bottom, 4)
            
            HStack {
                Text("By \(tarPost.author)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: sendByEmail) {
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $isShowingMailView) {
                    MailView(tarPost: tarPost) { result in
                        isShowingMailView = false
                    }
                }
                Button(action: deletePost) {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(title: Text("Delete Post"),
                          message: Text("Are you sure you want to delete this post?"),
                          primaryButton: .destructive(Text("Delete")) {
                        viewModel.deletePost(tarPost)
                    },
                          secondaryButton: .cancel())
                }
                
                Text("\(tarPost.timestamp, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 2)
    }
}

