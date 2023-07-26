//
//  Photo.swift
//  GlassyNavigation
//
//  Created by Swarajmeet Singh on 26/07/23.
//

import Foundation
struct Photo: Codable {
    let description: String
    let url: String
    let title: String
    let id: Int
    let user: Int
}

struct PhotosBase : Codable {

    let limit : Int
    let message : String
    let offset : Int
    let photos : [Photo]
    let success : Bool

}
