//
//  ImageMapper.swift
//  miniBootcampChallenge
//
//  Created by Marco Alonso Rodriguez on 28/03/23.
//

import Foundation

struct ImageMapper {
    func map(objectImage: [Result]) -> [String] {
        var urlImages: [String] = []
        for imageUrl in objectImage {
            let url = imageUrl.urls.small
            urlImages.append(url)
        }
        
        return urlImages
    }
}
