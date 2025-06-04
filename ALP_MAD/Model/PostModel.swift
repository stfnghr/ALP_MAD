//
//  PostModel.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import Foundation

struct PostModel: Codable, Identifiable {
    var id = UUID()
    var author: UserModel
    var itemName: String
    var description: String
    var location: String
    var postDate: Date
    var status: Bool
}
