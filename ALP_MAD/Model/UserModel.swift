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

struct UserResponseModel: Codable { //this is for JSON results in profile view since it doesnt return uid and password
    var email: String = ""
    var name: String = ""
    var nim: String = ""
    var phoneNumber: String = ""
}