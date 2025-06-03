//
//  TabBarView.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/12/24.
//

import SwiftUI

struct TabBarView: View {
    var action: () -> Void
    var body: some View {
        ZStack{
            //MARK: Tab Items
            HStack{
                //MARK: Expand button
                Button{
                    action()
                }label: {
                    Image(systemName: "mappin.and.ellipse")
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                //MARK: Navigation Button
                NavigationLink{
                    WeatherForecastView()
                    
                }label: {
                    Image(systemName: "list.star")
                        .frame(width: 44, height: 44)
                }
            }.font(.title2)
                .foregroundStyle(.white)
                .padding(EdgeInsets(top: 20, leading: 32, bottom: 24, trailing: 32))
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()

    }
}

#Preview {
    TabBarView(action: {})
        .preferredColorScheme(.dark)
}
