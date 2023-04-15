//
//  DocumentPicker.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/15/23.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileData: Data?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = false
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            do {
                let fileData = try Data(contentsOf: url)
                parent.fileData = fileData
            } catch {
                print("Error reading document data: \(error.localizedDescription)")
            }
        }
    }
}
