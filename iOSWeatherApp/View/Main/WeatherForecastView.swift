//
//  ContentView.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import SwiftUI

struct WeatherForecastView: View {
    @ObservedObject var locationManager = LocationManager()
    @StateObject var viewModel = WeatherViewModel(networkManager: NetworkMnager())
    
    var body: some View {
        ZStack {
            
            Color.background
                .ignoresSafeArea()
            VStack {
                if viewModel.isLoading {
                    ProgressView("Fetching Weather Data...")
                        .padding()
                } else if let error = viewModel.responseError {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    List {
                        let sortedDates = viewModel.dailyForecast.keys.sorted() // Extract sorted keys
                        ForEach(sortedDates, id: \.self) { date in
                            if let forecast = viewModel.dailyForecast[date] {
                                ScrollView{
                                    WeatherCellView(forecast: forecast, locationManager: locationManager)
                                }

                                
                            }
                        }
                    }
                }
            }
            .navigationTitle("Weather Forecast")
            .onAppear {
                viewModel.bindLocationManager(locationManager)
                fetchWeather()
            }
        }
            
        }

    
    
    
     func fetchWeather() {
        guard let coordinate = locationManager.location else {
            print("Location is unavailable")
            locationManager.checkLocationAuthorization()
            return
        }
        Task {
            await viewModel.getWeatherData(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
}

#Preview {
    WeatherForecastView(locationManager: LocationManager())
        
}

