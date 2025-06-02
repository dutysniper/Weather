//
//  DailyForecastCell.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 01.06.2025.
//

import UIKit

final class DailyForecastCell: UICollectionViewCell {
	static let identifier = "DailyForecastCell"

	let separator: UIView = {
		let view = UIView()
		view.backgroundColor = .white.withAlphaComponent(0.2)
		return view
	}()

	private let dayLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .white
		label.textAlignment = .left
		return label
	}()

	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private let windLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = .white
		return label
	}()

	private let humidityLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = .white
		return label
	}()

	private let conditionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = .white
		return label
	}()

	private let tempLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .bold)
		label.textColor = .white
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with forecast: ForecastDay, isToday: Bool = false) {
		if isToday {
			dayLabel.text = "Сегодня"
		} else {
			dayLabel.text = formatDay(forecast.date)
		}
		tempLabel.text = "\(Int(forecast.day.avgtemp_c))°"
		windLabel.text = "Ветер: \(Int(forecast.day.maxwind_kph))км/ч"
		humidityLabel.text = "Влажность: \(forecast.day.avghumidity)%"
		conditionLabel.text = forecast.day.condition.text

		if let iconUrl = URL(string: "https:\(forecast.day.condition.icon)") {
			iconImageView.kf.setImage(with: iconUrl)
		}
	}

	private func formatDay(_ dateString: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "ru_RU")

		if let date = formatter.date(from: dateString) {
			formatter.dateFormat = "E"
			return formatter.string(from: date).capitalized
		}
		return dateString
	}

	private func setupViews() {
		let infoStack = UIStackView(arrangedSubviews: [windLabel, humidityLabel, conditionLabel])
		infoStack.axis = .vertical
		infoStack.spacing = 2

		let mainStack = UIStackView(arrangedSubviews: [dayLabel, iconImageView, infoStack, tempLabel])
		mainStack.axis = .horizontal
		mainStack.spacing = 8
		mainStack.alignment = .center
		mainStack.distribution = .fillProportionally

		contentView.addSubview(mainStack)
		mainStack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(separator)
		separator.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			separator.heightAnchor.constraint(equalToConstant: 0.5),

			mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

			dayLabel.widthAnchor.constraint(equalToConstant: 60),
			iconImageView.widthAnchor.constraint(equalToConstant: 30),
			iconImageView.heightAnchor.constraint(equalToConstant: 30),
			tempLabel.widthAnchor.constraint(equalToConstant: 40)
		])
	}
}
