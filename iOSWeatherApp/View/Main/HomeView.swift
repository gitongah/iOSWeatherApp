//
//  HomeView.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/12/24.
//

import SwiftUI
import BottomSheet

enum BottomSheetPosition: CGFloat, CaseIterable {
    case top = 0.83
    case middle = 0.385
}

struct HomeView: View {
    @State var bottomSheetPosition: BottomSheetPosition = .middle
    @StateObject private var locationManager = LocationManager()
    @StateObject var viewModel = WeatherViewModel(networkManager: NetworkMnager())
    @State var hasDragged: Bool = false
    @State var bottomSheetTranslation: CGFloat = BottomSheetPosition.middle.rawValue
    var bottomSheetTranslationProrated: CGFloat {
        (bottomSheetTranslation - BottomSheetPosition.middle.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.middle.rawValue)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                let imageOffset = screenHeight + 36
                ZStack {
                    // MARK: Background color
                    Color.background
                        .ignoresSafeArea()
                    
                    Image("Background")
                        .resizable()
                        .ignoresSafeArea()
                        .offset(y: -bottomSheetTranslationProrated * imageOffset)
                    
                    Image("House")
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.top, 257)
                        .offset(y: -bottomSheetTranslationProrated * imageOffset)
                    
                    VStack {
                        if viewModel.isLoading {
                            ProgressView("Fetching Weather Data...")
                                .padding()
                        } else if let error = viewModel.responseError {
                            Text("Error: \(error.localizedDescription)")
                                .foregroundStyle(.gray)
                                .padding()
                        } else if let currentWeather = viewModel.currentWeather {
                            // Display current weather data
                            Text(locationManager.locationName ?? "Unknown Location")
                                .font(.largeTitle)
                            
                            VStack {
                                Text("\(currentWeather.main.temp, specifier: "%.0f")°")
                                    .font(.system(size: 96, weight: .thin))
                                    .foregroundStyle(.primary)
                                +
                                Text("\n")
                                +
                                Text(currentWeather.weather.first?.description.capitalized ?? "N/A")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                
                                if let today = viewModel.groupForecastByDay.keys.sorted().first {
                                    let dailyTemps = viewModel.dailyHighLow(for: today)
                                    
                                    Text("H: \(dailyTemps.high, specifier: "%.0f")°  L: \(dailyTemps.low, specifier: "%.0f")°")
                                        .font(.title3.weight(.semibold))
                                }
                            }
                        } else {
                            Text("No weather data available")
                                .foregroundStyle(.gray)
                                .padding()
                            Button("Get Weather") {
                                fetchWeather()                        }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 51)
                    
                    // MARK: Bottom Sheet
                    BottomSheetView(position: $bottomSheetPosition) {
                        ForecastView()
      
                    }content: {
                        
                        
                    }
                    .onBottomSheetDrag { translation in
                        bottomSheetTranslation = translation / screenHeight
                        withAnimation(.easeInOut) {
                            if bottomSheetPosition == BottomSheetPosition.top {
                                hasDragged = true
                            } else {
                                hasDragged = false
                            }
                        }
                    }
                    
                    // MARK: Tab Bar
                    TabBarView(action: {
                        bottomSheetPosition = .top
                    })
                    .offset(y: bottomSheetTranslationProrated * 115)                }
                .onAppear {
                    viewModel.bindLocationManager( locationManager)
                    fetchWeather()

            }


            }
        }
    }
    
    private func fetchWeather() {
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
    HomeView()
        .preferredColorScheme(.dark)
}
