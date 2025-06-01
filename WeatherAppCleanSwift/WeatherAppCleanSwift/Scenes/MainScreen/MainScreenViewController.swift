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

	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: 80, height: 120)
		layout.minimumInteritemSpacing = 4

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.layer.cornerRadius = 20
		collectionView.layer.borderWidth = 2
		collectionView.layer.borderColor = CGColor(gray: CGFloat(10), alpha: 1)

		collectionView.delegate = self
		collectionView.dataSource = self

		return collectionView
	}()

	private var hourlyForecast: [HourlyForecast] = []



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
		print(hourlyForecast.count)
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

		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)
		}

	private func setupConstraints() {
		NSLayoutConstraint.activate(
			[
			cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),

			tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tempLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10),

			conditionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 10),
			conditionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),

			feelsLikeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			feelsLikeLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 8),

			humidityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			humidityLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 8),

			windLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			windLabel.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 8),

			collectionView.topAnchor.constraint(equalTo: windLabel.bottomAnchor, constant: 10),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			collectionView.heightAnchor.constraint(equalToConstant: 120)
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

			self?.hourlyForecast = viewModel.hourlyForecast
			self?.collectionView.reloadData()
		}

	}

	func displayError(viewModel: Weather.Error.ViewModel) {
		let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

extension MainScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return hourlyForecast.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: HourlyForecastCell.identifier,
			for: indexPath) as? HourlyForecastCell else {
			return UICollectionViewCell()
		}

		cell.configure(with: hourlyForecast[indexPath.row])
		return cell
	}
}
