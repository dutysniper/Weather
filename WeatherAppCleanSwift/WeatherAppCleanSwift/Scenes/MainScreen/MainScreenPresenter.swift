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

	// MARK: - Initialization
	init(viewController: IMainScreenViewController?) {
		self.viewController = viewController
	}

	// MARK: - Public Methods
	func presentWeather(response: Weather.Fetch.Response) {
		let weather = response.weatherData.current
		let location = response.weatherData.location
		let hourlyForecast = response.weatherData.forecast?.forecastday.first?.hour ?? []
		let dailyForecast = response.weatherData.forecast?.forecastday ?? []

		// Получаем отфильтрованный часовой прогноз
		var filteredHourly = filterHourlyForecast(hourlyForecast, localtime: location.localtime)

		// Если прогноза меньше чем на 24 часа, добавляем из следующего дня
		if filteredHourly.count < 24, let forecastDays = response.weatherData.forecast?.forecastday, forecastDays.count > 1 {
			let remainingHours = 24 - filteredHourly.count
			let nextDayHours = Array(forecastDays[1].hour.prefix(remainingHours))
			filteredHourly += nextDayHours
		}

		let viewModel = Weather.Fetch.ViewModel(
			cityName: "\(location.name), \(location.country)",
			temperature: "\(Int(weather.tempC))°C",
			condition: weather.condition.text,
			feelsLike: "Ощущается как \(Int(weather.feelslikeC))°C",
			humidity: "Влажность: \(weather.humidity)%",
			windSpeed: "Ветер: \(weather.windKph) км/ч",
			iconURL: URL(string: "https:\(weather.condition.icon)"),
			hourlyForecast: filteredHourly,
			dailyForecast: Array(dailyForecast.prefix(5))
		)

		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayWeather(viewModel: viewModel)
		}
	}

	func presentError(error: Error) {
		let viewModel = Weather.Error.ViewModel(
			title: "Error",
			message: error.localizedDescription
		)
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayError(viewModel: viewModel)
		}
	}

	func showSearchField() {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.showSearchField()
		}
	}

	func hideSearchField() {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.hideSearchField()
		}
	}

	func updateSearchResults(cities: [City]) {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.updateSearchResults(cities: cities)
		}
	}

	func showSearchOnly() {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displaySearchOnlyState()
		}
	}

	// MARK: - Private Methods
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

		guard let endDate = calendar.date(byAdding: .hour, value: 24, to: startOfHour) else {
			return Array(forecast.prefix(24))
		}

		let filtered = forecast.filter { hourly in
			guard let hourlyDate = dateFormatter.date(from: hourly.time) else { return false }
			return hourlyDate >= startOfHour && hourlyDate < endDate
		}

		return Array(filtered)
	}
}
