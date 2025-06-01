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

		return label
	}()

	private let iconImageView: UIImageView = {
		let imageView = UIImageView()

		imageView.contentMode = .scaleToFill

		return imageView
	}()

	private let temperatureLabel: UILabel = {
		let label = UILabel()

		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.textAlignment = .center

		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with forecast: HourlyForecast) {
		timeLabel.text = formatTime(forecast.time)
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
		let stackView = UIStackView(arrangedSubviews: [timeLabel, iconImageView, temperatureLabel])
		stackView.axis = .vertical
		stackView.spacing = 4
		stackView.alignment = .center

		contentView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

			iconImageView.widthAnchor.constraint(equalToConstant: 30),
			iconImageView.heightAnchor.constraint(equalToConstant: 30)
		])
	}
}
