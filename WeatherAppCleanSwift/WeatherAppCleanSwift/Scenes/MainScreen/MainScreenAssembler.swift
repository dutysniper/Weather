//
//  MainScreenAssembler.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import UIKit

protocol IMainScreenAssembler {
	static func assembleModule() -> UIViewController
}

final class MainScreenAssembler: IMainScreenAssembler {
	static func assembleModule() -> UIViewController {
		let networkManager = NetworkManager()
		let locationService = LocationService()
		let viewController = MainScreenViewController()
		let presenter = MainScreenPresenter(viewController: viewController)
		let interactor = MainScreenInteractor(
			presenter: presenter,
			networkService: networkManager,
			locationService: locationService
		)

		viewController.interactor = interactor

		return viewController
	}
}
