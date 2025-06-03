//
//  DummyNetworkManager.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/18/24.
//

import Foundation

@testable import iOSWeatherApp


class DummyNetworkManager:Network{
    var urlPath = ""
    
    func getDataFromUrl<T>(url: String, modelType: T.Type) async throws -> T where T : Decodable {
        let bundle = Bundle(for: DummyNetworkManager.self)
        let urlObj = bundle.url(forResource: urlPath, withExtension: "json")
        
        guard let urlObj else {
            throw NetworkError.InvalidURLError
        }
        do{
            let data = try Data(contentsOf: urlObj)
            
            let parsedData = try JSONDecoder().decode(modelType, from: data)
            return parsedData
        }catch{
            throw error
        }
        
    }
    
    
}
