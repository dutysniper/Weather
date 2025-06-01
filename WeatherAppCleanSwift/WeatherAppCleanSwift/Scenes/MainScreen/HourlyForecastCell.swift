//
//  HoulyForecastCell.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 01.06.2025.
//

import UIKit
import Kingfisher

final class HourlyForecastCell: UICollectionViewCell {
	static let identifier = "HourlyForecastCell"

	private let timeLabel: UILabel = {
		let label = UILabel()

		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textAlignment = .center
		label.textColor = .white

		return label
	}()

	private let iconImageView: UIImageView = {
		let imageView = UIImageView()

		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit

		return imageView
	}()

	private let temperatureLabel: UILabel = {
		let label = UILabel()

		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.textAlignment = .center
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

	func configure(with forecast: HourlyForecast, isCurrentHour: Bool = false) {
		if isCurrentHour {
			timeLabel.text = "Сейчас"
		} else {
			timeLabel.text = formatTime(forecast.time)
		}
		temperatureLabel.text = "\(Int(forecast.temp_c))°"

		if let iconUrl = URL(string: "https:\(forecast.condition.icon)") {
			iconImageView.kf.setImage(with: iconUrl)
		}
	}

	private func formatTime(_ timeString: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		if let date = formatter.date(from: timeString) {
			formatter.dateFormat = "HH:mm"
			return formatter.string(from: date)
		}
		return timeString
	}

	private func setupViews() {
		contentView.addSubview(timeLabel)
		contentView.addSubview(iconImageView)
		contentView.addSubview(temperatureLabel)

		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		temperatureLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
			timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
			timeLabel.heightAnchor.constraint(equalToConstant: 16),

			iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
			iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: 30),
			iconImageView.heightAnchor.constraint(equalToConstant: 30),

			temperatureLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 2),
			temperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
			temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
			temperatureLabel.heightAnchor.constraint(equalToConstant: 18)
		])
	}
}
