//
//  MailView.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/15/23.
//

import Foundation
import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let tarPost: TarPost
    let didFinish: (Result<MFMailComposeResult, Error>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(didFinish: didFinish)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
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

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let didFinish: (Result<MFMailComposeResult, Error>) -> Void

        init(didFinish: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
            self.didFinish = didFinish
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                didFinish(.failure(error))
            } else {
                didFinish(.success(result))
            }
            controller.dismiss(animated: true)
        }
    }
}
