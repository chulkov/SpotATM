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

struct Networking {

    let baseURL = "https://api.tinkoff.ru/v1/"
    
    func getPartners(latitude: Double, longitude: Double, radius: Int, compleation: @escaping(Result<Partner, HandlingError>) ->Void){
        
        let destinationURL = baseURL + "deposition_points?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
        let urlString = destinationURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let resourceURL = URL(string: urlString!) else {fatalError()}
        print("\(resourceURL)")
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, _ in
            
            guard let jsonData = data else {
                compleation(.failure(.noDataAvailable))
                return
            }

            do{
                let decoder = JSONDecoder()
                let jobs = try decoder.decode(Partner.self, from: jsonData)
                compleation(.success(jobs))
            }catch{
                print(error)
               // compleation(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    func getJobs(compleation: @escaping(Result<Partner, HandlingError>) ->Void) {
        
        let destinationURL = baseURL + "vacancies"
        let urlString = destinationURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let resourceURL = URL(string: urlString!) else {fatalError()}
        //self.resourceURL = resourceURL
        print("\(resourceURL)")
        
        
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, response, error in
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            guard let jsonData = data else {
                compleation(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let jobs = try decoder.decode(Partner.self, from: jsonData)
                compleation(.success(jobs))
            }catch{
                print(error.localizedDescription)
            }
            
        }
        dataTask.resume()
    }

    
    func getVacancy(vacancyId:String, compleation: @escaping(Result<Partner, HandlingError>) ->Void) {
        
        let destinationURL = baseURL + "vacancies/\(vacancyId)"
        let urlString = destinationURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let resourceURL = URL(string: urlString!) else {fatalError()}
        //self.resourceURL = resourceURL
        print("\(resourceURL)")
        

        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, _ in
            
            guard let jsonData = data else {
                compleation(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let jobs = try decoder.decode(Partner.self, from: jsonData)
                compleation(.success(jobs))
            }catch{
                print(error.localizedDescription)
                compleation(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
    
}
