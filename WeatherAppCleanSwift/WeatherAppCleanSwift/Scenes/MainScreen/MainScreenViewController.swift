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
	func showSearchField()
	func hideSearchField()
	func updateSearchResults(cities: [City])
	func displaySearchOnlyState()
}

final class MainScreenViewController: UIViewController {

	//MARK: - Dependencies
	var interactor: IMainScreenInteractor?

	//MARK: - Private properties
	private let iconImageView = UIImageView()
	private let cityLabel = UILabel()
	private let tempLabel = UILabel()
	private let conditionLabel = UILabel()
	private let feelsLikeLabel = UILabel()
	private let humidityLabel = UILabel()
	private let windLabel = UILabel()

	private lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "Введите населенный пункт"
		searchBar.delegate = self
		searchBar.searchBarStyle = .minimal
		searchBar.barTintColor = .white
		searchBar.tintColor = .white
		if let textField = searchBar.value(forKey: "searchField") as? UITextField {
			textField.textColor = .white
			textField.backgroundColor = UIColor.white.withAlphaComponent(0.2)
			textField.attributedPlaceholder = NSAttributedString(
				string: "Поиск города",
				attributes: [.foregroundColor: UIColor.lightText]
			)
		}
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		return searchBar
	}()

	private lazy var searchTableView: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cityCell")
		tableView.backgroundColor = UIColor(named: "DarkPurple")?.withAlphaComponent(0.7)
		tableView.layer.cornerRadius = 10
		tableView.isHidden = true
		tableView.delegate = self
		tableView.dataSource = self
		tableView.isUserInteractionEnabled = true
		tableView.allowsSelection = true
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()

	private lazy var hourlyForecastCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: 80, height: 100)

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
		collectionView.backgroundColor = UIColor(named: "DarkPurple")
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.layer.cornerRadius = 10

		collectionView.delegate = self
		collectionView.dataSource = self

		return collectionView
	}()

	private lazy var dailyForecastCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 4
		layout.itemSize = CGSize(width: view.frame.width - 20, height: 60)

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(DailyForecastCell.self, forCellWithReuseIdentifier: DailyForecastCell.identifier)
		collectionView.backgroundColor = UIColor(named: "DarkPurple")?.withAlphaComponent(0.7)
		collectionView.layer.cornerRadius = 10
		collectionView.showsVerticalScrollIndicator = false
		collectionView.delegate = self
		collectionView.dataSource = self
		return collectionView
	}()

	private var hourlyForecast: [HourlyForecast] = []
	private var dailyForecast: [ForecastDay] = []
	private var searchResults: [City] = []

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
		makeGradient()
		setupViews()
		setupConstraints()
		fetchWeather()
	}

	private func fetchWeather() {
		interactor?.fetchWeather()
	}
}

//MARK: - IMainScreenViewController
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
			self?.hourlyForecastCollectionView.reloadData()

			self?.dailyForecast = Array(viewModel.dailyForecast.prefix(5))
			self?.dailyForecastCollectionView.reloadData()
		}
	}

	func displaySearchOnlyState() {
		cityLabel.text = "Поиск города"
		tempLabel.text = ""
		conditionLabel.text = ""
		feelsLikeLabel.text = ""
		humidityLabel.text = ""
		windLabel.text = ""

		hourlyForecast = []
		dailyForecast = []
		hourlyForecastCollectionView.reloadData()
		dailyForecastCollectionView.reloadData()
		self.hourlyForecastCollectionView.isHidden = true
		self.dailyForecastCollectionView.isHidden = true

		searchBar.isHidden = false
		searchBar.isUserInteractionEnabled = true
		view.bringSubviewToFront(searchBar)
	}

	func updateSearchResults(cities: [City]) {
		searchResults = cities
		searchTableView.reloadData()
		searchTableView.isHidden = cities.isEmpty
	}

	func displayError(viewModel: Weather.Error.ViewModel) {
		let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	func showSearchField() {
		DispatchQueue.main.async { [weak self] in
			self?.searchBar.isHidden = false
			self?.searchTableView.isHidden = true
			UIView.animate(withDuration: 0.3) {
				self?.view.layoutIfNeeded()
			}
		}
	}

	func hideSearchField() {
		DispatchQueue.main.async { [weak self] in
			self?.searchBar.isHidden = true
			self?.searchTableView.isHidden = true
			UIView.animate(withDuration: 0.3) {
				self?.view.layoutIfNeeded()
			}
		}
	}
	
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MainScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == self.hourlyForecastCollectionView {
			return hourlyForecast.count
		} else {
			return dailyForecast.count
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == hourlyForecastCollectionView {
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: HourlyForecastCell.identifier,
				for: indexPath) as? HourlyForecastCell else {
				return UICollectionViewCell()
			}
			let isCurrentHour = indexPath.row == 0
			cell.configure(with: hourlyForecast[indexPath.row], isCurrentHour: isCurrentHour)
			return cell
		} else {
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: DailyForecastCell.identifier,
				for: indexPath) as? DailyForecastCell else {
				return UICollectionViewCell()
			}
			let isToday = indexPath.row == 0
			cell.configure(with: dailyForecast[indexPath.row], isToday: isToday)
			return cell
		}
	}
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension MainScreenViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
		let city = searchResults[indexPath.row]
		cell.textLabel?.text = "\(city.name), \(city.country)"
		cell.textLabel?.textColor = .white
		cell.backgroundColor = .clear
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let city = searchResults[indexPath.row]
		searchBar.text = "\(city.name), \(city.country)"
		searchBar.resignFirstResponder()
		searchBar.isHidden.toggle()

		searchTableView.isHidden = true
		if hourlyForecastCollectionView.isHidden && dailyForecastCollectionView.isHidden {
			hourlyForecastCollectionView.isHidden.toggle()
			dailyForecastCollectionView.isHidden.toggle()
		}
		print("didSelectRow")
		interactor?.fetchWeather(for: city.name)
	}
}

//MARK: - UISearchBarDelegate
extension MainScreenViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard !searchText.isEmpty else {
			searchResults = []
			searchTableView.isHidden = true
			return
		}
		interactor?.searchCities(query: searchText)
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		if !searchResults.isEmpty {
			searchTableView.isHidden = false
		}
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		guard let cityName = searchBar.text else { return }
		searchTableView.isHidden = true
		print("textDidendEditing")
		interactor?.fetchWeather(for: cityName)
	}
}

//MARK: - Setup UI
private extension MainScreenViewController {
	private func setupViews() {
		view.backgroundColor = .systemBackground

		[
			iconImageView,
			cityLabel,
			tempLabel,
			conditionLabel,
			feelsLikeLabel,
			humidityLabel,
			windLabel,
			searchBar,
			searchTableView
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}

		iconImageView.contentMode = .scaleAspectFit
		cityLabel.font = .systemFont(ofSize: 24, weight: .medium)
		cityLabel.textAlignment = .center
		cityLabel.textColor = .white
		cityLabel.numberOfLines = 2
		cityLabel.lineBreakMode = .byWordWrapping
		cityLabel.adjustsFontSizeToFitWidth = true
		cityLabel.minimumScaleFactor = 0.7
		cityLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		tempLabel.textColor = .white
		tempLabel.font = .systemFont(ofSize: 48, weight: .bold)

		[conditionLabel, feelsLikeLabel, humidityLabel, windLabel].forEach {
			$0.font = .systemFont(ofSize: 16)
			$0.textAlignment = .center
			$0.textColor = .white
		}

		hourlyForecastCollectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(hourlyForecastCollectionView)

		dailyForecastCollectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(dailyForecastCollectionView)

		searchBar.isHidden = true
	}

	func makeGradient() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = view.bounds
		gradientLayer.colors = [UIColor.black.cgColor, UIColor(red: 0.5, green: 0.2, blue: 0.5, alpha: 1).cgColor]
		gradientLayer.locations = [0, 1]
		gradientLayer.startPoint = CGPoint(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint(x: 0, y: 1)

		view.layer.insertSublayer(gradientLayer, at: 0)
	}
}

//MARK: - Layout
private extension MainScreenViewController {
	func setupConstraints() {
		NSLayoutConstraint.activate(
			[
				cityLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
				cityLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
				cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
				cityLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 60),

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

				hourlyForecastCollectionView.topAnchor.constraint(equalTo: windLabel.bottomAnchor, constant: 10),
				hourlyForecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
				hourlyForecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
				hourlyForecastCollectionView.heightAnchor.constraint(equalToConstant: 90),

				dailyForecastCollectionView.topAnchor.constraint(equalTo: hourlyForecastCollectionView.bottomAnchor, constant: 16),
				dailyForecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
				dailyForecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
				dailyForecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

				searchBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
				searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
				searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

				searchTableView.bottomAnchor.constraint(equalTo: searchBar.topAnchor, constant: -8),
				searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
				searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
				searchTableView.heightAnchor.constraint(equalToConstant: 200)
			])
	}
}
