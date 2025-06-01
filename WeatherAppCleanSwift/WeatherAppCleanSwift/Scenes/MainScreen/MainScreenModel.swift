//
//  MainScreenModel.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation
import CoreLocation

struct WeatherResponse: Codable {
	let location: Location
	let current: CurrentWeather
}

struct Location: Codable {
	let name: String
	let region: String
	let country: String
	let lat: Double
	let lon: Double
	let tzId: String
	let localtime: String

	enum CodingKeys: String, CodingKey {
		case name, region, country, lat, lon
		case tzId = "tz_id"
		case localtime = "localtime"
	}
}

struct CurrentWeather: Codable {
	let tempC: Double
	let condition: WeatherCondition
	let windKph: Double
	let humidity: Int
	let feelslikeC: Double

	enum CodingKeys: String, CodingKey {
		case tempC = "temp_c"
		case condition
		case windKph = "wind_kph"
		case humidity
		case feelslikeC = "feelslike_c"
	}
}

struct WeatherCondition: Codable {
	let text: String
	let icon: String
}

enum Weather {
	enum Fetch {
		struct Request {
			let cityName: String?
			let coordinates: CLLocationCoordinate2D?
		}

		struct Response {
			let weatherData: WeatherResponse
		}

		struct ViewModel {
			let cityName: String
			let temperature: String
			let condition: String
			let feelsLike: String
			let humidity: String
			let windSpeed: String
			let iconURL: URL?
		}
	}

	enum Error {
		struct ViewModel {
			let title: String
			let message: String
		}
	}
}
