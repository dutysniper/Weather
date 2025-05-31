//
//  LocationManager.swift
//  WeatherAppCleanSwift
//
//  Created by Константин Натаров on 31.05.2025.
//

import CoreLocation

protocol ILocationService {
	func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
	var authorizationStatus: CLAuthorizationStatus { get }
}

final class LocationService: NSObject, ILocationService, CLLocationManagerDelegate {
	private let locationManager = CLLocationManager()
	private var locationCompletion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

	override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
	}

	var authorizationStatus: CLAuthorizationStatus {
		return locationManager.authorizationStatus
	}

	func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
		self.locationCompletion = completion

		switch locationManager.authorizationStatus {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .authorizedWhenInUse, .authorizedAlways:
			locationManager.requestLocation()
		default:
			completion(.failure(LocationError.unauthorized))
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else { return }
		locationCompletion?(.success(location.coordinate))
		locationCompletion = nil
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		locationCompletion?(.failure(error))
		locationCompletion = nil
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
		case .authorizedWhenInUse, .authorizedAlways:
			manager.requestLocation()
		case .denied, .restricted:
			// Если доступ запретили - вызываем completion с ошибкой
			locationCompletion?(.failure(LocationError.unauthorized))
			locationCompletion = nil
		default:
			break
		}
	}

	enum LocationError: Error {
		case unauthorized
	}
}
