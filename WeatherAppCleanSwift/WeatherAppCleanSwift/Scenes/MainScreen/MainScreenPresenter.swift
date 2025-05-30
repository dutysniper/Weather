//
//  MainScreenPresenter.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import Foundation

protocol IMainScreenPresenter {

}

final class MainScreenPresenter {

	// MARK: - Dependecies

	private weak var viewController: IMainScreenViewController?

	// MARK: - Initialization

	init(viewController: IMainScreenViewController?) {
		self.viewController = viewController
	}
}
