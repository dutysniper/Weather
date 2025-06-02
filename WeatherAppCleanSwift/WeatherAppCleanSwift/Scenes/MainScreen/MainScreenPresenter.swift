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
	func showSearchField()
	func hideSearchField()
	func updateSearchResults(cities: [City])
	func showSearchOnly()
}

final class MainScreenPresenter: IMainScreenPresenter {
	private weak var viewController: IMainScreenViewController?

	init(viewController: IMainScreenViewController?) {
		self.viewController = viewController
	}

	func showSearchOnly() {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displaySearchOnlyState()
		}
	}

	func presentWeather(response: Weather.Fetch.Response) {
		let weather = response.weatherData.current
		let location = response.weatherData.location
		let hourlyForecast = response.weatherData.forecast?.forecastday.first?.hour ?? []
		let dailyForecast = response.weatherData.forecast?.forecastday ?? []

		let viewModel2 = Weather.Fetch.ViewModel(
			cityName: "\(location.name), \(location.country)",
			temperature: "\(Int(weather.tempC))°C",
			condition: weather.condition.text,
			feelsLike: "Ощущается как \(Int(weather.feelslikeC))°C",
			humidity: "Влажность: \(weather.humidity)%",
			windSpeed: "Ветер: \(weather.windKph) км/ч",
			iconURL: URL(string: "https:\(weather.condition.icon)"),
			hourlyForecast: filterHourlyForecast(hourlyForecast, localtime: location.localtime),
			dailyForecast: Array(dailyForecast.prefix(5)))
		print(location.localtime)
		viewController?.displayWeather(viewModel: viewModel2)
	}

	func presentError(error: Error) {
		let viewModel = Weather.Error.ViewModel(
			title: "Error",
			message: error.localizedDescription
		)
		viewController?.displayError(viewModel: viewModel)
	}

	func showSearchField() {
		viewController?.showSearchField()
	}

	func hideSearchField() {
		viewController?.hideSearchField()
	}

	func updateSearchResults(cities: [City]) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.viewController?.updateSearchResults(cities: cities)
		}
	}

	private func filterHourlyForecast(_ forecast: [HourlyForecast], localtime: String) -> [HourlyForecast] {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
		dateFormatter.timeZone = TimeZone(identifier: "UTC")

		guard let localDate = dateFormatter.date(from: localtime) else {
			return Array(forecast.prefix(24))
		}

		let calendar = Calendar.current
		let components = calendar.dateComponents([.year, .month, .day, .hour], from: localDate)

		guard let startOfHour = calendar.date(from: components) else {
			return Array(forecast.prefix(24))
		}

		let filtered = forecast.filter { hourly in
			guard let hourlyDate = dateFormatter.date(from: hourly.time) else { return false }
			return hourlyDate >= startOfHour
		}
		return Array(filtered.prefix(24))
	}
}
