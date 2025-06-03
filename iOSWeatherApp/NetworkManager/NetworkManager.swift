//
//  NetworkManager.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 5/15/25.
//

import Foundation
//using enum to handle the diffrent error cases that might happen during the api call
public enum NetworkError: Error{
    case InvalidURLError
    case dataNotFoundError
    case InvalidStatusCodeResponse
    case InvalidDataResponseError
    case parseDataError
}

extension NetworkError: LocalizedError{
    public var errorDescription: String? {
        switch self{
        case .InvalidURLError:
            return "The url on which we are trying to fetch data is invalid"
        case .dataNotFoundError:
            return "Could not get data from the API"
        case .InvalidStatusCodeResponse:
            return "Got invalid status code"
        case .InvalidDataResponseError:
            return "Got invalid data response"
        case .parseDataError:
            return "Could not parse the data"
        }
        
    }
}


import Foundation

protocol Network{
    //creating a generic function
     func getDataFromUrl<T: Decodable>(url:String ,modelType:T.Type) async throws -> T
}

class NetworkMnager{
    
    public let urlSession : URLSession
    
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
}

extension NetworkMnager: Network{
    
    func getDataFromUrl<T>(url: String, modelType: T.Type) async throws -> T where T : Decodable {
        
        guard let urlObject = URL(string: url) else {
            print("❌ Invalid URL")
            throw NetworkError.InvalidURLError
        }
        
        do {
            let (data, response) = try await self.urlSession.data(from: urlObject)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response object")
                throw NetworkError.InvalidDataResponseError
            }

            print("✅ Status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Bad status code. Body: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw NetworkError.InvalidStatusCodeResponse
            }

            // Log raw JSON
            print("📦 Raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            let parsedData = try JSONDecoder().decode(modelType, from: data)
            return parsedData
            
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            throw NetworkError.parseDataError
        } catch {
            print("❌ Unknown error: \(error.localizedDescription)")
            throw error
        }
    }
    
}
