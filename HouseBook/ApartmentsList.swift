//
//  ApartmentsList.swift
//  HouseBook
//
//  Created by Ujjwal Adhikari on 3/21/23.
//

import Foundation
import ParseSwift

struct ApartmentsList: ParseObject {
    // These are required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var Name: String?
    var Location: String?
    var RoomType: String?
    var Ratings: String?
    var Rent: String?
    var About: String?
    var Photos: [String]?
    var spec: String?
    var user:String?
    var userUploadPhoto: [ParseFile]?
    var leaseType: String?
    var interestedUser: [String] = []
}
