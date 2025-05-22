//
//  UserModel.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import Foundation

struct User: Codable, Identifiable {
    var id: UUID
    var email: String
    var password: String
    var Phone_number: String
}
