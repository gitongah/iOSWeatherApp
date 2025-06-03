//
//  iOSWeatherAppTests.swift
//  iOSWeatherAppTests
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import XCTest
@testable import iOSWeatherApp

final class iOSWeatherAppTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var dummyNetworkManager: DummyNetworkManager!

    override func setUpWithError() throws {
       
        dummyNetworkManager = DummyNetworkManager()
        viewModel = WeatherViewModel(networkManager: dummyNetworkManager)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        dummyNetworkManager = nil
    }
    

    func testGetWeatherWhenExpectingCorrectOutPut() async throws {
        dummyNetworkManager.urlPath = "DummyTestData"
        
        await viewModel.getWeatherData(latitude: 34.0522, longitude: -118.2437)
        XCTAssertNotNil(viewModel.forecast, "Forecast should not be nil")
        
//        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
        
        let forecast1 = viewModel.forecast?.list[0]
        
        XCTAssertEqual(forecast1?.main.temp, 293.15)
        
        XCTAssertEqual(forecast1?.main.humidity, 78)
        
        XCTAssertEqual(forecast1?.wind.speed, 2.06)

        XCTAssertEqual(forecast1?.dt_txt, "2024-12-18 00:00:00")
    }
    
    func testGetWeatherWhenExpectingWrongOutPut() async throws {
        dummyNetworkManager.urlPath = "DummyTestData"
        
        await viewModel.getWeatherData(latitude: 34.0522, longitude: -118.2437)

        
//        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
        
        let forecast1 = viewModel.forecast?.list[0]
        
        XCTAssertNotEqual(forecast1?.main.temp, 29)
        
        XCTAssertNotEqual(forecast1?.main.humidity, 7)
        
        XCTAssertNotEqual(forecast1?.wind.speed, 5)

        XCTAssertNotEqual(forecast1?.dt_txt, "2027-13-18 40:40:011")
    }
    
    
    func testGetWeatherWhenYouHaveWrongURL() async throws {
        dummyNetworkManager.urlPath = "Test"
        
        await viewModel.getWeatherData(latitude: 34.0522, longitude: -118.2437)
        
        XCTAssertNil(viewModel.forecast, "Forecast should be nil when the URL is invalid.")
       
    }
    


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
