//
//  TarPost.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import FirebaseFirestore

class TarPost: Identifiable, ObservableObject {
    var id = UUID()
    var fileURL: String?
    var timestamp: Date
    var imageURL: String?
    var author: String
    var description: String
    var title: String
    
    init(id: UUID = UUID(), fileURL: String? = nil, timestamp: Date, imageURL: String? = nil, author: String = "", description: String = "", title: String = ""){
        self.id = id
        self.fileURL = fileURL
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.author = author
        self.description = description
        self.title = title
    }
    
    init(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        self.id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        self.fileURL = data["fileURL"] as? String
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.imageURL = data["imageURL"] as? String
        self.author = data["author"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
    }

}

