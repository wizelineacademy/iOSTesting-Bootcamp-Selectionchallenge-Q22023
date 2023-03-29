//
//  ImagesManager.swift
//  miniBootcampChallenge
//
//  Created by Marco Alonso Rodriguez on 28/03/23.
//

import Foundation

enum Errors: Error {
    case badRequest
    case badUrl
    case decodingData
    case badResponseServer
}

protocol ImageManagerDelegate {
    func showImages(listOfImages: [String])
    func showError(wichError: Errors)
}

struct ImagesManager {
    ///- Option 1 using async - await and delegation pattern
    var delegate: ImageManagerDelegate?
    
    func getImages() async {
        
        do {
            guard let url = URL(string: "https://api.unsplash.com/search/photos?page=1&per_page=50&query=mac&client_id=cNtxMzMLT8_GFa8TE8ACB5MWVJFOILOE57YRviGQxuI") else {
                
                /// - Delegate send the error to ViewController
                delegate?.showError(wichError: Errors.badUrl)
                return
            }
            
            let urlRequest = URLRequest(url: url)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                /// - Delegate send the error to ViewController
                delegate?.showError(wichError: Errors.badResponseServer)
                return
            }
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(ResponseDataModel.self, from: data)
            let listOfImages = decodedData.results
            
            /// - Use a mapper to conver into a urlString all images
            let mapper = ImageMapper()
            let urlImages = mapper.map(objectImage: listOfImages)
            
            ///- Send the list of objects to ViewController
            delegate?.showImages(listOfImages: urlImages)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    ///- Option 2 using escaping closure
    func getImagesClosure(completion: @escaping (_ listOfImages: [String]?, _ error: Error?) -> ()) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=50&query=animals&client_id=cNtxMzMLT8_GFa8TE8ACB5MWVJFOILOE57YRviGQxuI"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedData = try JSONDecoder().decode(ResponseDataModel.self, from: data)
                    
                    /// - Use a mapper to conver into a urlString all images
                    let mapper = ImageMapper()
                    let urlImages = mapper.map(objectImage: decodedData.results)
                    
                    completion(urlImages, nil)
                } catch {
                    completion(nil, error)
                }
            }.resume()
        }
    }
}
