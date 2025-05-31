//
//  MainScreenViewController.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import UIKit

protocol IMainScreenViewController: AnyObject {
	func displayWeather(viewModel: Weather.Fetch.ViewModel)
	func displayError(viewModel: Weather.Error.ViewModel)
}

final class MainScreenViewController: UIViewController {
	var interactor: IMainScreenInteractor?

	private let iconImageView = UIImageView()
	private let cityLabel = UILabel()
	private let tempLabel = UILabel()
	private let conditionLabel = UILabel()
	private let feelsLikeLabel = UILabel()
	private let humidityLabel = UILabel()
	private let windLabel = UILabel()

	// MARK: - Initialization

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		fetchWeather()
	}

	private func fetchWeather() {
		interactor?.fetchWeather()
	}

	private func setupViews() {
		view.backgroundColor = .systemBackground

		[iconImageView, cityLabel, tempLabel, conditionLabel, feelsLikeLabel, humidityLabel, windLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}

		iconImageView.contentMode = .scaleAspectFit
		cityLabel.font = .systemFont(ofSize: 24, weight: .medium)
		tempLabel.font = .systemFont(ofSize: 48, weight: .bold)

		[conditionLabel, feelsLikeLabel, humidityLabel, windLabel].forEach {
			$0.font = .systemFont(ofSize: 16)
		}
		conditionLabel.numberOfLines = 0
		conditionLabel.textAlignment = .center
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate(
			[
			cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),

			tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tempLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10),

			conditionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 20),
			conditionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),

			feelsLikeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			feelsLikeLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 8),

			humidityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			humidityLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 8),

			windLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			windLabel.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 8)
		]
		)
	}
}

extension MainScreenViewController: IMainScreenViewController {
	func displayWeather(viewModel: Weather.Fetch.ViewModel) {
		DispatchQueue.main.async { [weak self] in
			self?.cityLabel.text = viewModel.cityName
			self?.tempLabel.text = viewModel.temperature
			self?.conditionLabel.text = viewModel.condition
			self?.feelsLikeLabel.text = viewModel.feelsLike
			self?.humidityLabel.text = viewModel.humidity
			self?.windLabel.text = viewModel.windSpeed
		}


//		if let iconURL = viewModel.iconURL {
//			iconImageView.kf.setImage(with: iconURL)
//		}
	}

	func displayError(viewModel: Weather.Error.ViewModel) {
		let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}
