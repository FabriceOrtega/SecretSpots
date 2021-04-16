//
//  SpotWebservice.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 15/04/2021.
//

import Foundation
import MapKit

struct SpotWebservice {

    // Session
    var session = URLSession.shared
    
    init(session: URLSession) {
        self.session = session
    }
    
    // Method to send the get request to get all spots
    mutating func getSpotRequest(completion: @escaping(Result<[RequestedSpot], RequestError>) -> Void){
        let request = NSMutableURLRequest(url: NSURL(string: "http://127.0.0.1:8080/getSpots")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)

        request.httpMethod = "GET"
        
        // Create the task
        
        let dataTask = session.dataTask(with: request as URLRequest){data, response, error in
            // check if data is available
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            
            // If data available, convert it thru the decoder
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([RequestedSpot].self, from: jsonData)
                
                completion(.success(response))
                
                // If not ptossible to decode
            } catch {
                completion(.failure(.canNotProcessData))
            }
        }
        dataTask.resume()
    }
    
    //Method to create a new user
    func postNewSpot(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, category: Category){
        
        // prepare json data
        let json: [String: Any] = [
            "title": title,
            "subtitle": subtitle,
            "lat": Double(coordinate.latitude),
            "long": Double(coordinate.longitude),
            "category": category.rawValue
        ]
        
        // Try to transform it in JSON
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: "http://127.0.0.1:8080/createSpot")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        request.setValue("application/json", forHTTPHeaderField:"Accept")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
    }
    
}

enum RequestError: Error {
    case noDataAvailable
    case canNotProcessData
}
