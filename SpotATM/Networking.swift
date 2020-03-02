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
        //let destinationURL = baseURL + "deposition_points?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
        
        if var urlComponents = URLComponents(string: "\(baseURL)deposition_points") {
            urlComponents.query = "latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
            
            guard let url = urlComponents.url else {
                return
            }
            
            
            //let urlString = urlComponents.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            //        guard let resourceURL = URL(string: urlString!) else {fatalError()}
                    print("\(urlComponents)")
            //
            //        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, error in
            //
            //            guard let jsonData = data else {
            //                print(error.debugDescription)
            //                return
            //            }
            //
            //            do{
            //                //let decoder = JSONDecoder()
            //                //let jobs = try decoder.decode(PartnerModel.self, from: jsonData)
            //                compleation(.success(jsonData))
            //            }catch{
            //                print(error)
            //               // compleation(.failure(.canNotProcessData))
            //            }
            //
            //        }
            
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                
                // 5
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    
                    // 6
                    DispatchQueue.main.async {
                        compleation(.success(data))
                    }
                }
            }
            dataTask?.resume()
        }
    }
}
