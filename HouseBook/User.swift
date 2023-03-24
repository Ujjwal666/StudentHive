//
//  User.swift
//  RoomBook
//
//  Created by Sanjaya Subedi on 3/22/23.
//
import Foundation

import ParseSwift
import UIKit
struct User: ParseUser {
    // These are required by `ParseObject`.
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // These are required by `ParseUser`.
    var username: String?
    var email: String?
    var studentID: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
    
    var name: String?
    var sessionToken: String?
    
    var profilePhoto: ParseFile?
    
  
}
