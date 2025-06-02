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
	func fetchAutocompleteCities(query: String, completion: @escaping (Result<[City], Error>) -> Void)
}
/// Class for API Requests
final class NetworkManager {
	private let apiKey = "8842335e68cf481bb20212303253005"
	private let baseUrl = "https://api.weatherapi.com/v1"

	func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
		guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			completion(.failure(NetworkError.invalidCityName))
			return
		}
		let urlString = "\(baseUrl)/forecast.json?key=\(apiKey)&q=\(encodedCity)&days=5&aqi=no&lang=ru"

		performRequest(urlString: urlString, completion: completion)
	}

	func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
		performRequest(urlString: "\(baseUrl)/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=5&aqi=no&lang=ru", completion: completion)
	}

	func fetchAutocompleteCities(query: String, completion: @escaping (Result<[City], Error>) -> Void) {
		guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			completion(.failure(NetworkError.invalidCityName))
			return
		}
		let urlString = "\(baseUrl)/search.json?key=\(apiKey)&q=\(encodedQuery)"

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
				let cities = try JSONDecoder().decode([City].self, from: data)
				completion(.success(cities))
			} catch {
				completion(.failure(error))
			}
		}.resume()
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

struct City: Codable {
	let id: Int
	let name: String
	let region: String
	let country: String
	let lat: Double
	let lon: Double
}
