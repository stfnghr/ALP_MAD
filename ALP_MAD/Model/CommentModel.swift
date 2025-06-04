//
//  CommentModel.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import Foundation

struct CommentModel: Codable, Identifiable {
    var id = UUID()
    var author: UserModel
    var text: String
    var commentDate: Date
}
