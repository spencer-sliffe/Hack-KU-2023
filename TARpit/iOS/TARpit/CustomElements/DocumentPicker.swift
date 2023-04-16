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
    @State private var selectedFileName: String?
    var onDocumentPicked: (UIDocument) -> Void

    func makeCoordinator() -> Coordinator {
            Coordinator(self, onDocumentPicked: onDocumentPicked)
        }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = false
        context.coordinator.onDocumentPicked = onDocumentPicked
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        var onDocumentPicked: (UIDocument) -> Void
        
        init(_ parent: DocumentPicker, onDocumentPicked: @escaping (UIDocument) -> Void) {
            self.parent = parent
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            let document = UIDocument(fileURL: url)
            onDocumentPicked(document)
        }
    }
}
