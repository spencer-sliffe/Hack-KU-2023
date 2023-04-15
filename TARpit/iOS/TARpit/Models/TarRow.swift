//
//  TarRow.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//
import Foundation
import SwiftUI
import MessageUI

struct TarRow: View {
    @EnvironmentObject var viewModel: TarPitViewModel
    let tarPost: TarPost
    @State private var isShowingMailView = false
    
    
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
            if MFMailComposeViewController.canSendMail() {
                isShowingMailView.toggle()
            } else {
                print("Cannot send email")
            }
        }
    
        private func emailComposeVC() -> MFMailComposeViewController {
            let vc = MFMailComposeViewController()
            vc.setSubject("Tar File from TARpit: \(tarPost.title)")
            vc.setMessageBody("Here is the requested tar file from the TARpit post titled: \(tarPost.title)", isHTML: false)
            
            if let fileURL = tarPost.fileURL, let url = URL(string: fileURL) {
                do {
                    let data = try Data(contentsOf: url)
                    vc.addAttachmentData(data, mimeType: "application/x-tar", fileName: "file.tar")
                } catch {
                    print("Error attaching file: \(error.localizedDescription)")
                }
            }
            
            return vc
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
                Text("\(tarPost.timestamp, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Button(action: sendByEmail) {
                           Text("Email File")
                               .foregroundColor(.white)
                               .padding()
                               .background(Color.blue)
                               .cornerRadius(8)
                       }
                       .sheet(isPresented: $isShowingMailView) {
                           MailView(tarPost: tarPost) { result in
                               isShowingMailView = false
                           }
                       }
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 2)
    }
}


