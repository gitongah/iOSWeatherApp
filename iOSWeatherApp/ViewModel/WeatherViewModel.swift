//
//  WeatherViewModel.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import Foundation
import Combine
import CoreLocation

class WeatherViewModel:  ObservableObject{
    @Published var locationManager = LocationManager()
    let networkManager: Network
    @Published var forecast : ForecastResponse?{
        didSet{
            groupForecast()
            extractDailyForecast()
        }
    }
    @Published var currentWeather: Forecast?
    @Published var isLoading: Bool = false

    @Published var responseError: Error?
    @Published var searchText = ""
    
    private var cancellable = Set<AnyCancellable>()
    
    @Published  var groupForecastByDay = [String: [Forecast]]()
    @Published  var dailyForecast = [String: Forecast]()
    
    init(networkManager: Network) {
        self.networkManager = networkManager

    }
    func bindLocationManager(_ locationManager: LocationManager){
        locationManager.onLocationChange = { [weak self] location in
            Task {
                await self?.getWeatherData(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    func getWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async{
//        let apiKey = ApiKeyManager.valueForKey(key: "WeatherAPIKey")
        let apiKey = "ba0620dee5889ace740c7c86e8f491fd"
        print("api key is\(apiKey)")
        let url = "https://api.openweathermap.org/data/2.5/forecast"
        let queryParams = [
            "lat": "\(latitude)",
            "lon": "\(longitude)",
            "units": "metric",
            "appid": "\(apiKey)"
        ]
        await MainActor.run { [weak self] in
            self?.isLoading = true
            
        }
        do{
            guard let fullUrl = buildURL(baseURL: url, queryParams: queryParams) else{
                throw NetworkError.InvalidURLError
            }
            print("\(fullUrl)")

            let weatherForecast = try await self.networkManager.getDataFromUrl(url: fullUrl, modelType: ForecastResponse.self)
            await MainActor.run { [ weak self ] in
                self?.forecast = weatherForecast
                self?.isLoading = false
                self?.currentWeather = weatherForecast.list.first
            }
            
            
        }catch{
            await MainActor.run { [weak self ] in
                print("Error fetching data \(error.localizedDescription)")
                self?.responseError = error
                switch error{
                case is DecodingError:
                    self?.responseError = NetworkError.parseDataError
                case NetworkError.InvalidDataResponseError:
                    self?.responseError = NetworkError.InvalidDataResponseError
                case NetworkError.InvalidStatusCodeResponse:
                    self?.responseError = NetworkError.InvalidStatusCodeResponse
                case NetworkError.dataNotFoundError:
                    self?.responseError = NetworkError.dataNotFoundError
                case NetworkError.InvalidURLError:
                    self?.responseError = NetworkError.InvalidURLError
                default:
                    self?.responseError = NetworkError.InvalidDataResponseError
                }
            }

        }
    }
    
    private func buildURL(baseURL: String, queryParams: [String: String]) -> String? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url?.absoluteString ?? baseURL
    }
    
    func fetchWeather() {
       guard let coordinate = locationManager.location else {
           print("Location is unavailable")
           locationManager.checkLocationAuthorization()
           return
       }
       Task {
           await getWeatherData(latitude: coordinate.latitude, longitude: coordinate.longitude)
       }
   }
    private func groupForecast() {
        guard let forecastList = forecast?.list else {
            print("No forecast data available")
            return
        }
        var groupedData = [String: [Forecast]]()
        for item in forecastList {
            let date = String(item.dt_txt.prefix(10)) // Extract date
            groupedData[date, default: []].append(item)
        }

        groupForecastByDay = groupedData
    }
    
    private func extractDailyForecast(){
        var dailyData = [String:Forecast]()
        
        for(date, forecasts) in groupForecastByDay{
            if let firstForecast = forecasts.first{
                dailyData[date] = firstForecast
            }
        }
        dailyForecast = dailyData
        
    }
    
    func dailyHighLow(for date: String) -> (high: Double, low: Double) {
        guard let forecastsForDay = groupForecastByDay[date] else {
            // Return default values if the date is not found
            return (0, 0)
        }
        
        let highTemp = forecastsForDay.max { $0.main.tempMax < $1.main.tempMax }?.main.tempMax ?? 0
        let lowTemp = forecastsForDay.min { $0.main.tempMin < $1.main.tempMin }?.main.tempMin ?? 0
        
        return (highTemp, lowTemp)
    }
    // Helper to format date string
    func formattedDate(from dateString: String) -> String {
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "yyyy-MM-dd"

        let calendar = Calendar.current

        // Try full datetime format first
        if let date = fullFormatter.date(from: dateString) ?? shortFormatter.date(from: dateString) {
            if calendar.isDateInToday(date) {
                return "Today"
            } else {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "EEE" // e.g., Mon, Tue, Wed
                return timeFormatter.string(from: date)
            }


        }

        return "N/A"
    }
    func formattedTimeOnly(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "ha" // e.g., "9AM"
            return timeFormatter.string(from: date)
        }
        
        return "N/A"
    }


    
}

struct ApiKeyManager{
    static func valueForKey(key: String) -> String{
        guard let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else{
            return ""
        }
        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            
            return ""
        }
        return plist[key] as? String ?? ""
    }
}

