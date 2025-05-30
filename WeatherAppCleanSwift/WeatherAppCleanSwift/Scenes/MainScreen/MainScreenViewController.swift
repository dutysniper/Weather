//
//  MainScreenViewController.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import UIKit

protocol IMainScreenViewController: AnyObject {

}

final class MainScreenViewController: UIViewController {

	// MARK: - Dependencies

	var interactor: IMainScreenInteractor?

	// MARK: - Private properties
	private let weatherService = WeatherService()

	private let weatherIconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private var cityNameLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var tempratureLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var weatherStatusLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var feelsLikeLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var humidityLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	// MARK: - Initialization

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		print("test")
		view.addSubview(weatherIconImageView)
		view.addSubview(cityNameLabel)
		view.addSubview(tempratureLabel)
		view.addSubview(feelsLikeLabel)
		view.addSubview(weatherStatusLabel)
		view.addSubview(humidityLabel)

		NSLayoutConstraint.activate([
			// Иконка погоды
			weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			weatherIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			weatherIconImageView.widthAnchor.constraint(equalToConstant: 100),
			weatherIconImageView.heightAnchor.constraint(equalToConstant: 100),

			// Название города
			cityNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			cityNameLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 20),
			cityNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
			cityNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

			// Температура
			tempratureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tempratureLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 10),

			// Статус погоды
			weatherStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			weatherStatusLabel.topAnchor.constraint(equalTo: tempratureLabel.bottomAnchor, constant: 10),

			// Ощущается как
			feelsLikeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			feelsLikeLabel.topAnchor.constraint(equalTo: weatherStatusLabel.bottomAnchor, constant: 10),

			// Влажность
			humidityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			humidityLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 10),
			humidityLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
		fetchWeatherForMoscow()
	}

	private func fetchWeatherForMoscow() {
		weatherService.fetchWeather(for: "Moscow") { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .success(let weatherResponse):
					self?.updateUI(with: weatherResponse)
				case .failure(let error):
					self?.showError(error)
				}
			}
		}
	}

	private func updateUI(with weather: WeatherResponse) {
		print("Город: \(weather.location.name)")
		print("Температура: \(weather.current.tempC)°C")
		print("Состояние: \(weather.current.condition.text)")
		print("Ощущается как: \(weather.current.feelslikeC)°C")
		print("Влажность: \(weather.current.humidity)%")
		cityNameLabel.text = weather.location.name
		tempratureLabel.text = String(weather.current.tempC)
		weatherStatusLabel.text = weather.current.condition.text
		feelsLikeLabel.text = String(weather.current.feelslikeC)
		humidityLabel.text = String(weather.current.humidity)
		if let iconUrl = URL(string: "https:\(weather.current.condition.icon)") {
			loadWeatherIcon(from: iconUrl)
		}
	}
	private func loadWeatherIcon(from url: URL) {
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let data = data, error == nil else {
				print("Ошибка загрузки иконки:", error?.localizedDescription ?? "Неизвестная ошибка")
				return
			}

			DispatchQueue.main.async {
				self?.weatherIconImageView.image = UIImage(data: data)
			}
		}.resume()
	}

	private func showError(_ error: Error) {
		let alert = UIAlertController(
			title: "Ошибка",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

}

extension MainScreenViewController: IMainScreenViewController {}

class WeatherService {
	// TODO: refactor API into keychain
	private let apiKey = "8842335e68cf481bb20212303253005"
	private let baseUrl = "https://api.weatherapi.com/v1"

	func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
		// Кодируем название города для URL
		guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			completion(.failure(NetworkError.invalidCityName))
			return
		}

		// Формируем URL
		let urlString = "\(baseUrl)/current.json?key=\(apiKey)&q=\(encodedCity)&aqi=no&lang=ru"
		guard let url = URL(string: urlString) else {
			completion(.failure(NetworkError.invalidURL))
			return
		}

		// Создаем и выполняем запрос
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			// Обработка ошибок
			if let error = error {
				completion(.failure(error))
				return
			}

			// Проверяем наличие данных
			guard let data = data else {
				completion(.failure(NetworkError.noData))
				return
			}

			// Декодируем ответ
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

	enum NetworkError: Error {
		case invalidURL
		case noData
		case invalidCityName
	}
}

//удалить

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
	let cloud: Int
	let feelslikeC: Double

	enum CodingKeys: String, CodingKey {
		case tempC = "temp_c"
		case condition
		case windKph = "wind_kph"
		case humidity, cloud
		case feelslikeC = "feelslike_c"
	}
}

struct WeatherCondition: Codable {
	let text: String
	let icon: String
	let code: Int
	}
