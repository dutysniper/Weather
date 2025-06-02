//
//  MainScreenInteractor.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation

protocol IMainScreenInteractor {
	func fetchWeather()
	func fetchWeather(for city: String)
	func searchCities(query: String)
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
		checkLocationAuthorization()
	}

	private func checkLocationAuthorization() {
		let status = locationService.authorizationStatus

		switch status {
		case .notDetermined:
			requestLocation()
		case .authorizedWhenInUse, .authorizedAlways:
			requestLocation()
		case .denied, .restricted:
			presenter.showSearchOnly()
		@unknown default:
			presenter.showSearchOnly()
		}
	}

	private func requestLocation() {
		locationService.requestLocation { [weak self] result in
			switch result {
			case .success(let coordinates):
				self?.fetchWeather(latitude: coordinates.latitude, longitude: coordinates.longitude)
			case .failure:
				self?.presenter.showSearchOnly()
			}
		}
	}

	func fetchWeather(for city: String) {
		networkManager.fetchWeather(for: city) { [weak self] result in
			switch result {
			case .success(let response):
				self?.presenter.presentWeather(response: Weather.Fetch.Response(weatherData: response))
			case .failure(let error):
				self?.presenter.presentError(error: error)
			}
		}
	}

	func searchCities(query: String) {
		networkManager.fetchAutocompleteCities(query: query) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .success(let cities):
					self?.presenter.updateSearchResults(cities: cities)
				case .failure:
					self?.presenter.updateSearchResults(cities: [])
				}
			}
		}
	}

	private func fetchWeatherByLocation() {
		locationService.requestLocation { [weak self] result in
			switch result {
			case .success(let coordinates):
				self?.fetchWeather(latitude: coordinates.latitude, longitude: coordinates.longitude)
				self?.presenter.hideSearchField()
			case .failure:
				self?.presenter.showSearchField()
				self?.fetchWeather(for: "Paris")
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
