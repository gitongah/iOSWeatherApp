//
//  WeatherViewCell.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/11/24.
//
import SwiftUI

struct WeatherCellView: View {
    var forecast: Forecast
    @ObservedObject var locationManager: LocationManager
    @StateObject var viewModel = WeatherViewModel(networkManager: NetworkMnager())
        
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Trapezoid
            Trapezoid()
                .fill(Color.weatherWidgetBackground)
                .frame(width: 342, height: 174)
            
            // MARK: Content
            HStack(alignment: .bottom) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.formattedDate(from: forecast.dt_txt))
                        .font(.system(size: 18))
                    // MARK: Forecast Temperature
                    Text("\(Int(forecast.main.temp))°")
                        .font(.system(size: 64))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // MARK: Forecast Temperature Range
                        Text("H:\(Int(forecast.main.tempMax))°  L:\(Int(forecast.main.tempMin))°")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        // MARK: Forecast Location
                        Text(locationManager.locationName ?? "Unknown Location")
                            .font(.body)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    // MARK: Forecast Large Icon
//                    Image(forecast.weather.first?.iconName ?? "default")
//                        .padding(.trailing, 4)
                    if let icon = forecast.weather.first?.icon {
                        let iconUrl = URL(string:"https://openweathermap.org/img/wn/\(icon)@4x.png")
                        AsyncImage(url: iconUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        }placeholder: {
                            ProgressView()
                        }
                        
                    }
                    
                    // MARK: Weather
                    Text(forecast.weather.first?.description.capitalized ?? "N/A")
                        .font(.footnote)
                        .padding(.trailing, 24)
                }
            }
            .foregroundColor(.white)
            .padding(.bottom, 20)
            .padding(.leading, 20)
        }
        .frame(width: 342, height: 184, alignment: .bottom)
    }
}

#Preview {
    WeatherCellView(forecast: Forecast(
        dt: 1672579200,
        main: Main(temp: 25.0, feelsLike: 27.0, tempMin: 20.0, tempMax: 28.0, pressure: 1013, humidity: 80, seaLevel: nil, grndLevel: nil),
        weather: [WeatherData(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
        clouds: Clouds(all: 0),
        wind: Wind(speed: 5.0, deg: 120, gust: nil),
        visibility: 10000,
        pop: 0.2,
        rain: nil,
        dt_txt: "2024-12-11 12:00:00"
    ), locationManager: LocationManager())
}
