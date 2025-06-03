//
//  WeatherData.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//


import Foundation

// MARK: - WeatherCondition Enum
/// Enum for weather conditions with their corresponding icons.
enum WeatherCondition: String {
    case clear = "Clear Sky"
    case clouds = "Overcast Clouds"
    case rain = "Rain"
    case storm = "Storm"
    case sunny = "Sunny"
    case tornado = "Tornado"
    case wind = "Wind"
    
    var iconName: String {
        switch self {
        case .clear: return "Moon"
        case .clouds: return "Cloud"
        case .rain: return "Moon cloud mid rain"
        case .storm: return "Sun cloud angled rain"
        case .sunny: return "Sun"
        case .tornado: return "Tornado"
        case .wind: return "Moon cloud fast wind"
        }
    }
}

// MARK: - WeatherData
/// Weather conditions such as description and icon.
struct WeatherData: Decodable {
    let id: Int // Weather condition ID
    let main: String // Group of weather parameters (e.g., Rain, Snow, Clear)
    let description: String // Weather condition within the group
    let icon: String // Icon code for the weather condition
    
    // MARK: - Computed property to get the icon based on weather condition
    var weatherCondition: WeatherCondition? {
        return WeatherCondition(rawValue: main.lowercased())
    }
    
    var iconName: String {
        return weatherCondition?.iconName ?? "Default"
    }
}

// MARK: - ForecastResponse
/// The top-level response model for the forecast API.
struct ForecastResponse: Decodable {
    let list: [Forecast] // Array of forecast data entries
    let city: City // Metadata about the city
}

// MARK: - Forecast
/// Represents a single forecast entry.
struct Forecast: Decodable, Identifiable {
    var id: Int { dt } 
    let dt: Int // Forecast timestamp (Unix time)
    let main: Main // Temperature and pressure information
    let weather: [WeatherData] // Array of weather conditions
    let clouds: Clouds // Cloudiness details
    let wind: Wind // Wind speed and direction
    let visibility: Int // Visibility in meters
    let pop: Double // Probability of precipitation
    let rain: Rain? // Rain details if present
    let dt_txt: String // Date and time of the forecast (text format)

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain
        case dt_txt = "dt_txt"
    }
}

// MARK: - City
/// Metadata about the city for which the forecast is provided.
struct City: Decodable {
    let id: Int // City ID
    let name: String // City name
    let coord: Coord // City coordinates (latitude and longitude)
    let country: String // Country code
    let timezone: Int // Timezone offset in seconds
    let sunrise: Int // Sunrise time (Unix timestamp)
    let sunset: Int // Sunset time (Unix timestamp)
}

// MARK: - Clouds
/// Details about cloud coverage.
struct Clouds: Decodable {
    let all: Int // Cloudiness in percentage
}

// MARK: - Coord
/// Geographical coordinates of the city.
struct Coord: Decodable {
    let lon: Double // Longitude
    let lat: Double // Latitude
}

// MARK: - Main
/// Temperature, pressure, and humidity details.
struct Main: Decodable {
    let temp: Double // Current temperature
    let feelsLike: Double // Feels-like temperature
    let tempMin: Double // Minimum temperature for the day
    let tempMax: Double // Maximum temperature for the day
    let pressure: Int // Atmospheric pressure at sea level (hPa)
    let humidity: Int // Humidity percentage
    let seaLevel: Int? // Atmospheric pressure at sea level (optional)
    let grndLevel: Int? // Atmospheric pressure at ground level (optional)

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

// MARK: - Rain
/// Rain information, if available.
struct Rain: Decodable {
    let the3H: Double? // Rain volume for the last 3 hours (mm)

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

// MARK: - Wind
/// Wind details.
struct Wind: Decodable {
    let speed: Double // Wind speed in meters/second
    let deg: Int // Wind direction in degrees
    let gust: Double? // Wind gust speed (optional)
}

extension Forecast {
    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: dt_txt)
    }
}
