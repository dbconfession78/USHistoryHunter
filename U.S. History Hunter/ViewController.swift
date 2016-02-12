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
import Foundation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	@IBOutlet weak var mapView: MKMapView!
	var locationManager = CLLocationManager()
	var landmarks = [Landmark]()
	
	struct MyVars {
		static var prevLoc = CLLocation()
		
		// TODO:  USE THIS TO TEST SIMULATED MOVEMENT ON MAP
		
		static var lats = [40.759211, 40.859211, 40.959211, 41.059211, 41.159211]
		static var longs =  [-73.984638, -73.984638, -73.984638, -73.984638, -73.784638]
		// TODO:  USE THIS TO TEST SIMULATED MOVEMENT ON MAP
	}
	
	var coordIndex = 0
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.locationManager = CLLocationManager()
		self.locationManager.delegate = self
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		self.mapView.showsUserLocation = true
//		self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

		var landmarks: [Landmark] = [Landmark]()
		loadInitialData()
//		locationManager.request
	}
	

	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//		if coordIndex == 3 {
//			locationManager.stopUpdatingLocation()
//		} else {
			var prevLoc = MyVars.prevLoc
			let userLoction: CLLocation = locations[0]
			
			let distance = calculateDisatnceBetweenTwoLocations(prevLoc, destination: userLoction)
			if prevLoc != userLoction {
				prevLoc = userLoction
				MyVars.prevLoc = userLoction
//			}
			
			//TODO:  change back to 1000 if 5 isn't working
			if distance > 5 {
			//TODO:  change back to 1000 if 5 isn't working
				
				let latitude = userLoction.coordinate.latitude
				let longitude = userLoction.coordinate.longitude
				
				//TODO:  UNHIDE TO SIMULATE MOVEMENT
				
//				let latitude = MyVars.lats[coordIndex]
//				let longitude = MyVars.longs[coordIndex]
//				coordIndex++
				
				//TODO:  UNHIDE TO SIMULATE MOVEMENT
				
				let latDelta: CLLocationDegrees = 0.05
				let lonDelta: CLLocationDegrees = 0.05
				//			let span = mapView.region.span
				let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
				let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
				let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
				self.mapView.showsUserLocation = true
				self.mapView.setRegion(region, animated: true)
				updateVisiblePins(region: region)
			} else {
				let latitude = userLoction.coordinate.latitude
				let longitude = userLoction.coordinate.longitude
				
				//TODO:  UNHIDE TO SIMULATE MOVEMENT
				
//				let latitude = MyVars.lats[coordIndex]
//				let longitude = MyVars.longs[coordIndex]
//				coordIndex++
				
				//TODO:  UNHIDE TO SIMULATE MOVEMENT
				
				let span = mapView.region.span
				let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
				let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//				self.mapView.setRegion(region, animated: false)
				self.mapView.showsUserLocation = true
				updateVisiblePins(region: region)
			}
		}
	}

	
	func calculateDisatnceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double{
		var distanceMeters = source.distanceFromLocation(destination)
		var distanceKM = distanceMeters / 1000
		
		return distanceKM
	}
	
	//*** DONT REMOVE THESE AS THEY MAY BE USEFUL AT SOME POINT ****
//	func startLocationServices() {
//		if locationManager.delegate == nil {
//			self.locationManager = CLLocationManager()
//		}
//		
//		self.locationManager = CLLocationManager()
//		self.locationManager.delegate = self
//		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//		self.locationManager.requestWhenInUseAuthorization()
//		self.locationManager.startUpdatingLocation()
//	}
//	
//	func stopLocationServices() {
//		self.locationManager.stopUpdatingLocation()
//		self.locationManager.delegate = nil
//	}

//	let regionRadius: CLLocationDistance = 5000
//	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//		let location = locations.last
//		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location!.coordinate, regionRadius * 2.0, regionRadius * 2.0)
//		mapView.setRegion(coordinateRegion, animated: true)
//		updateVisiblePins(region: coordinateRegion)
//		
////		41.0605059, -74.265722
//		
//	}

	
//	locationManager(locationManager(manager, didUpdateLocations: [locations])


func updateVisiblePins(region region: MKCoordinateRegion) {
//	let region = MKCoordinateRegion(center: <#T##CLLocationCoordinate2D#>, span: <#T##MKCoordinateSpan#>)
		for landmark in landmarks {
			let regionLat = region.center.latitude
			let regionLong = region.center.longitude
			
//			print("Region: \(regionLat), \(regionLong)")
			
			let userLat = locationManager.location?.coordinate.latitude
			let userLong = locationManager.location?.coordinate.longitude
			
//			print("User Loc.: \(userLat), \(userLong)")
			
			let landmarkLat = landmark.coordinate.latitude
			let landmarkLong = landmark.coordinate.longitude
			
//			print("Landmark Loc.: \(landmarkLat), \(landmarkLong)")
			
			
//			let userLocation = CGPoint(x: (userLat)!, y: (userLong)!)
			let userLocation = locationManager.location
			let landmarkLocation = CLLocation(latitude: landmarkLat, longitude: landmarkLong)
//			let landmarkLocation = CGPoint(x: landmark.coordinate.latitude, y: landmark.coordinate.longitude)
//			let distance = distanceBetweenPoints(startPoint: userLocation, endPoint: landmarkLocation)
			let distance = calculateDisatnceBetweenTwoLocations(userLocation!, destination: landmarkLocation)
			
			//TODO:  remove if/else and .removeAnnotations to show all pins
			//TODO: replace if/else and .removeAnnotaions to show local pins
//			if distance < 30 {
				mapView.addAnnotation(landmark)
//			} else {
//				mapView.removeAnnotation(landmark)
//			}
			//TODO:  remove if/else and .removeAnnotations to show all pins
			//TODO: replace if/else and .removeAnnotaions to show local pins
			
		}
	}
	
	
//	func locationManager(manager: CLLocationManager, didUpdateLocation locations: [CLLocation]) {
//		
//		// set last location in locations array
//		let userLocation: CLLocation = locations[0]
//		
//		// get and set current lat and long from userLocation
//		let latitude = userLocation.coordinate.latitude
//		let longitude = userLocation.coordinate.longitude
//		
//		// get and set current latDelta degrees and longDelta degrees from mapView
//		let latDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
//		let lonDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
//		
//		// set current span using set degree variables above
//		let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
//		
//		// set current location using current lat and long variables above
//		let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
//		
//		// set current region using location and span variables above
//		let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//		
//		// uset current region above to set the mapView region
//		self.mapView.setRegion(region, animated: true)
//		
//		// allow the map to show the blue dot current location
//		mapView.showsUserLocation = true
//		
//		startLocationServices()
//	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
	{
		print("Errors: " + error.localizedDescription)
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
				if let landmarkJSON = landmarkJSON.array,landmark = Landmark.fromJSON(landmarkJSON) {
						landmarks.append(landmark)
				}
			}
		}
	}
	
	
	func distanceBetweenPoints(startPoint startPoint: CGPoint, endPoint endPoint: CGPoint) -> Int {
		let distance = Int(CGPointDistance(from: startPoint, to: endPoint) * 100)
		return distance
	}
	
	func CGPointDistanceSquared(from from: CGPoint, to: CGPoint) -> CGFloat {
		return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
	}
	
	func CGPointDistance(from from: CGPoint, to: CGPoint) -> CGFloat {
		return sqrt(CGPointDistanceSquared(from: from, to: to));
	}

	
//	func centerMapOnLocation(location: CLLocation) {
//		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
//		mapView.setRegion(coordinateRegion, animated: true)
//	}
	
	
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

