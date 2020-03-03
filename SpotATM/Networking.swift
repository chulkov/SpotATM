//
//  Networking.swift
//  SpotATM
//
//  Created by Max on 28/02/2020.
//  Copyright © 2020 chulkov. All rights reserved.
//

import Foundation


enum HandlingError: Error{
    case noDataAvailable
    case canNotProcessData
}

class Networking {
    var dataTask: URLSessionDataTask?
    let baseURL = "https://api.tinkoff.ru/v1/"
    let defaultSession = URLSession(configuration: .default)
    
    
    func getPartners(latitude: Double, longitude: Double, radius: Int, compleation: @escaping(Result<Data, Error>) ->Void){
        dataTask?.cancel()
        if radius > 20000{
            return
        }
        if var urlComponents = URLComponents(string: "\(baseURL)deposition_points") {
            urlComponents.query = "latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
            
            guard let url = urlComponents.url else {
                return
            }
            print("\(urlComponents)")
            
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }

                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {

                    DispatchQueue.main.async {
                        compleation(.success(data))
                    }
                }
            }
            dataTask?.resume()
        }
    }
}
