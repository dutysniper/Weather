//
//  MainScreenInteractor.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation

protocol IMainScreenInteractor {

}

final class MainScreenInteractor {

	// MARK: - Dependencies

	private var presenter: IMainScreenPresenter?

	// MARK: - Initialization

	init(presenter: IMainScreenPresenter) {
		self.presenter = presenter
	}
}
