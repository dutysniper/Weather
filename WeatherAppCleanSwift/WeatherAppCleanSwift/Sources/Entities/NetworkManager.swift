//
//  NetworkManager.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation

protocol INetworkManager {
	func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
	func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
}

final class NetworkManager {
	private let apiKey = "8842335e68cf481bb20212303253005"
	private let baseUrl = "https://api.weatherapi.com/v1"

	func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
		guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			completion(.failure(NetworkError.invalidCityName))
			return
		}

		performRequest(urlString: "\(baseUrl)/current.json?key=\(apiKey)&q=\(encodedCity)&aqi=no&lang=ru", completion: completion)
	}

	func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
		performRequest(urlString: "\(baseUrl)/current.json?key=\(apiKey)&q=\(latitude),\(longitude)&aqi=no&lang=ru", completion: completion)
	}

	private func performRequest(urlString: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
		guard let url = URL(string: urlString) else {
			completion(.failure(NetworkError.invalidURL))
			return
		}

		URLSession.shared.dataTask(with: url) { data, _, error in
			if let error = error {
				completion(.failure(error))
				return
			}

			guard let data = data else {
				completion(.failure(NetworkError.noData))
				return
			}

			do {
				let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
				completion(.success(response))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}

	enum NetworkError: Error {
		case invalidURL
		case noData
		case invalidCityName
		case decodingError
	}
}

extension NetworkManager: INetworkManager {}
