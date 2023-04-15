//
//  Account.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation

struct Account {
    var id: String
    var email: String
    var profilePicture: URL?

    init(id: String, email: String, subscription: Bool, packageData: [String: Any]?, profilePicture: String?) {
        self.id = id
        self.email = email
        self.profilePicture = profilePicture.flatMap { URL(string: $0) }
    }
}
