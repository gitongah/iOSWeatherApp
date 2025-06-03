//
//  ForecastCards.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/13/24.
//

import SwiftUI

enum DisplayType {
    case daily, grouped
}

struct ForecastCards: View {
    
    let forecast: Forecast 
    let formattedDate : String
    let forDisplayType: DisplayType
    var isActive: Bool {
        if forDisplayType == .daily {
            if let date = forecast.date {
                return Calendar.current.isDateInToday(date)
            }
        }else {
            if forDisplayType == .grouped {
                if let date = forecast.date {
                    return Calendar.current.isDateInToday(date)
                }
            }
        }
        return false
    }
    
    var body: some View {
        ZStack {
            // MARK: Card
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.forecastCardBackground.opacity(isActive ? 1 : 0.25))
                .frame(width: 60, height: 146)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 5, y: 4)
                .overlay {
                    // MARK: Card Border
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(.white.opacity(isActive ? 0.5 : 0.25))
                        .blendMode(.overlay)
                }
            
            // MARK: Content
            VStack(spacing: 16) {
                // MARK: Date or Time
                Text(formattedDate )
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                
                VStack(spacing: -4) {
                    // MARK: Weather Icon
                    if let icon = forecast.weather.first?.icon {
                        let iconUrl = URL(string:"https://openweathermap.org/img/wn/\(icon)@2x.png")
                        AsyncImage(url: iconUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }placeholder: {
                            ProgressView()
                        }
                        
                    }
                    
                    // MARK: Probability
                    if forecast.pop > 0 {
                        Text("\(Int(forecast.pop * 100))%")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(Color.probabilityText)
                            .opacity(forecast.pop > 0 ? 1 : 0)
                    }
                }
                .frame(height: 42)
                
                // MARK: Temperature
                Text("\(Int(forecast.main.temp))°")
                    .font(.title3)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    ForecastCards(forecast: Forecast(
        dt: 1672579200,
        main: Main(temp: 25.0, feelsLike: 27.0, tempMin: 20.0, tempMax: 28.0, pressure: 1013, humidity: 80, seaLevel: nil, grndLevel: nil),
        weather: [WeatherData(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
        clouds: Clouds(all: 0),
        wind: Wind(speed: 5.0, deg: 120, gust: nil),
        visibility: 10000,
        pop: 0.2,
        rain: nil,
        dt_txt: "2024-12-11 12:00:00"
    ), formattedDate: "Wed, Dec 11", forDisplayType: .daily)
}
