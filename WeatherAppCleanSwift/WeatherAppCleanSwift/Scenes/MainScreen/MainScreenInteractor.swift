//
//  MainScreenInteractor.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation

protocol IMainScreenInteractor {
	func fetchWeather()
}

final class MainScreenInteractor: IMainScreenInteractor {
	private var presenter: IMainScreenPresenter

	private var networkManager: INetworkManager
	private var locationService: ILocationService

	init(
		presenter: IMainScreenPresenter,
		networkService: INetworkManager,
		locationService: ILocationService
	) {
		self.presenter = presenter
		self.networkManager = networkService
		self.locationService = locationService
	}

	func fetchWeather() {
		switch locationService.authorizationStatus {
		case .notDetermined:
			// Если статус не определён, запрашиваем локацию
			// (пользователь увидит системный алерт)
			fetchWeatherByLocation()
		case .denied, .restricted:
			// Если доступ запрещён - сразу показываем дефолтный город
			fetchWeather(for: "Paris")
		case .authorizedAlways, .authorizedWhenInUse:
			// Если доступ разрешён - запрашиваем локацию
			fetchWeatherByLocation()
		@unknown default:
			fetchWeather(for: "Paris")
		}
	}

	private func fetchWeatherByLocation() {
		locationService.requestLocation { [weak self] result in
			switch result {
			case .success(let coordinates):
				self?.fetchWeather(latitude: coordinates.latitude, longitude: coordinates.longitude)
			case .failure:
				// Fallback to default city
				self?.fetchWeather(for: "Paris")
			}
		}
	}

	private func fetchWeather(for city: String) {
		print("fetch weather for paris")
		networkManager.fetchWeather(for: city) { [weak self] result in
			switch result {
			case .success(let response):
				self?.presenter.presentWeather(response: Weather.Fetch.Response(weatherData: response))
			case .failure(let error):
				self?.presenter.presentError(error: error)
			}
		}
	}

	private func fetchWeather(latitude: Double, longitude: Double) {
		networkManager.fetchWeather(latitude: latitude, longitude: longitude) { [weak self] result in
			switch result {
			case .success(let response):
				self?.presenter.presentWeather(response: Weather.Fetch.Response(weatherData: response))
			case .failure(let error):
				self?.presenter.presentError(error: error)
			}
		}
	}
}
