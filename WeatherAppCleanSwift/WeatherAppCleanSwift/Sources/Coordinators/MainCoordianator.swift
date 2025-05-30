//
//  MainCoordianator.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import UIKit


final class MainCoordinator: BaseCoordinator {

	// MARK: - Dependencies

	private let navigationController: UINavigationController

	// MARK: - Initialization

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	// MARK: - Internal methods

	override func start() {
		showMainScreen()
	}

	func showMainScreen() {
		let viewController = MainScreenViewController()
		navigationController.pushViewController(viewController, animated: true)
	}
}

