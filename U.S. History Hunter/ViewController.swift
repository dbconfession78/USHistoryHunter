//
//  ViewController.swift
//  HonoluluArt2
//
//  Created by Stuart Kuredjian on 1/21/16.
//  Copyright © 2016 s.Ticky Games. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	@IBOutlet weak var mapView: MKMapView!
	
	let locationManager = CLLocationManager()
	var landmarks = [Landmark]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		// Ask for Authorization from user to get current location
		var locationManager = CLLocationManager()
		self.locationManager.requestAlwaysAuthorization()
		self.locationManager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
		}
		
		
		
		var landmarks: [Landmark] = [Landmark]()
		let initialLocation = CLLocation(latitude: 40.961695, longitude: -74.187437)
		
		centerMapOnLocation(initialLocation)
		mapView.delegate = self
		
//		let landmark = Landmark(title: "King David Kalakaua",
//			locationName: "Waikiki Gateway Park",
//			discipline: "Sculpture",
//			coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
//		

		
		loadInitialData()
		
	}
	
	func loadInitialData() {
		// 1
		let fileName = NSBundle.mainBundle().pathForResource("PublicLandmark", ofType: "json");
		
		var data: NSData = NSData()
		do {
			data  = try NSData(contentsOfFile: fileName!, options: [])
		} catch {
			
		}
		
		
		// 2
		var jsonObject: AnyObject!
		do {
			jsonObject = try NSJSONSerialization.JSONObjectWithData(data,
				options: [])
		} catch {
			
		}
		
		// 3
		if let jsonObject = jsonObject as? [String: AnyObject],
	
		// 4
		let jsonData = JSONValue.fromObject(jsonObject)?["data"]?.array {
			for landmarkJSON in jsonData {
				if let landmarkJSON = landmarkJSON.array,
					// 5
					landmark = Landmark.fromJSON(landmarkJSON) {
						landmarks.append(landmark)
					}
			}
		}
		for landmark in landmarks {
			mapView.addAnnotation(landmark)
		}
	}
	
	
	

	
	
	
	let regionRadius: CLLocationDistance = 1000
	func centerMapOnLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
		mapView.setRegion(coordinateRegion, animated: true)
	}
	
	
//	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])  {
//		let location = locations.last
//		let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
//		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
//		
//		self.mapView.setRegion(region, animated: true)
//		
//		self.locationManager.stopUpdatingLocation()
//		
//	}
	
}

