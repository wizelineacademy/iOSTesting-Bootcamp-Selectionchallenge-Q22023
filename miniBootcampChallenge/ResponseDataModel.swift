//
//  ResponseDataModel.swift
//  miniBootcampChallenge
//
//  Created by Marco Alonso Rodriguez on 28/03/23.
//

import Foundation

struct ResponseDataModel: Codable {
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let urls: Urls
}

struct Urls : Codable {
    let raw: String
    let small: String
}


