//
//  UserModel.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import Foundation

struct UserModel: Codable, Identifiable {
    var id = UUID()
    var name: String = ""
    var nim: String = ""
    var email: String = ""
    var password: String = ""
    var phoneNumber: String = ""
}
