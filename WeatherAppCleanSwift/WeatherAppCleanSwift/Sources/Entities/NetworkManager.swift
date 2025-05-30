//
//  NetworkManager.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation

final class NetworkManager {
	private let apiKey = "8842335e68cf481bb20212303253005"
	private let baseUrl = "https://api.weatherapi.com/v1"

	/// Fetch data from API
	/// - Returns weatherRespons or Network error
	func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
		guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			completion(.failure(NetworkError.invalidCityName))
			return
		}

		let urlString = "\(baseUrl)/current.json?key=\(apiKey)&q=\(encodedCity)&aqi=no&lang=ru"
		guard let url = URL(string: urlString) else {
			completion(.failure(NetworkError.invalidURL))
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}

			guard let data = data else {
				completion(.failure(NetworkError.noData))
				return
			}

			do {
				let decoder = JSONDecoder()
				let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
				completion(.success(weatherResponse))
			} catch {
				completion(.failure(error))
			}
		}

		task.resume()
	}

	/// Network Errors
	enum NetworkError: Error {
		case invalidURL
		case noData
		case invalidCityName
	}
}
