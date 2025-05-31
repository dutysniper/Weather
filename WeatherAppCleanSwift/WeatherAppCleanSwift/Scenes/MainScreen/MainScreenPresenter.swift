//
//  MainScreenPresenter.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation

protocol IMainScreenPresenter {
	func presentWeather(response: Weather.Fetch.Response)
	func presentError(error: Error)
}

final class MainScreenPresenter: IMainScreenPresenter {
	private weak var viewController: IMainScreenViewController?

	init(viewController: IMainScreenViewController?) {
		self.viewController = viewController
	}

	func presentWeather(response: Weather.Fetch.Response) {
		let weather = response.weatherData.current
		let location = response.weatherData.location

		let viewModel = Weather.Fetch.ViewModel(
			cityName: "\(location.name), \(location.country)",
			temperature: "\(Int(weather.tempC))°C",
			condition: weather.condition.text,
			feelsLike: "Feels like \(Int(weather.feelslikeC))°C",
			humidity: "Humidity: \(weather.humidity)%",
			windSpeed: "Wind: \(weather.windKph) km/h",
			iconURL: URL(string: "https:\(weather.condition.icon)")
		)

		viewController?.displayWeather(viewModel: viewModel)
	}

	func presentError(error: Error) {
		let viewModel = Weather.Error.ViewModel(
			title: "Error",
			message: error.localizedDescription
		)
		viewController?.displayError(viewModel: viewModel)
	}
}
