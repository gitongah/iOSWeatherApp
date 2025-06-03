//
//  ForecastView.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/12/24.
//

import SwiftUI

struct ForecastView: View {
    @State private var selection = 0

    @StateObject var viewModel = WeatherViewModel(networkManager: NetworkMnager())
    var body: some View {
        
        ScrollView {
            VStack(spacing: 2) {
                // MARK: Segmented control
                SegmentedControl(selection: $selection)
                
                // MARK: Forecast cards
                forecastCardsView
            }
        }
        .background(Blur(radius: 25, opaque: true))
        .background(Color.bottomSheetBackground)
        .clipShape(RoundedRectangle(cornerRadius: 44))
        .overlay(alignment: .top) {
            bottomSheetOverlay
        }
        .onAppear {
            viewModel.bindLocationManager(viewModel.locationManager)
            viewModel.fetchWeather()
        }
    }
    

    
    private var forecastCardsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if selection == 1 {
                    ForEach(viewModel.dailyForecast.keys.sorted(), id: \.self) { date in
                        if let forecast = viewModel.dailyForecast[date] {
                            ForecastCards(
                                forecast: forecast,
                                formattedDate: viewModel.formattedDate(from: date),
                                forDisplayType: .daily
                            )
                        }
                    }
                } else {
                    ForEach(viewModel.groupForecastByDay.keys.sorted(), id: \.self) { date in
                        if let forecasts = viewModel.groupForecastByDay[date] {
                            ForEach(forecasts) { forecast in
                                ForecastCards(
                                    forecast: forecast,
                                    formattedDate: viewModel.formattedTimeOnly(from: forecast.dt_txt),
                                    forDisplayType: .grouped
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
    }
    
    private var bottomSheetOverlay: some View {
        ZStack(alignment: .top) {
            // Bottom Sheet Inner shadow
            RoundedRectangle(cornerRadius: 44)
                .stroke(.white, lineWidth: 1)
                .blendMode(.overlay)
                .offset(y: 1)
                .blur(radius: 0)
                .mask { RoundedRectangle(cornerRadius: 44) }
            
            // Bottom sheet separator
            Divider()
                .blendMode(.overlay)
                .background(Color.bottomSheetBorderTop)
                .frame(maxHeight: .infinity, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 44))
            
            // Drag indicator
            RoundedRectangle(cornerRadius: 10)
                .fill(.black.opacity(0.3))
                .frame(width: 48, height: 5)
                .frame(height: 20)
        }
    }
}


#Preview {
    ForecastView()
        .background(Color.background)
    
        .preferredColorScheme(.dark)
}

