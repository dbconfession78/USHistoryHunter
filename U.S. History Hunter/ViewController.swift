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
	var passedValue: String = "poopFaceKilla"
	var landmarkToPass: String!
	var rowIndex: Int = Int()
	struct MyVars {
		static var prevLoc = CLLocation()
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
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
			var prevLoc = MyVars.prevLoc
			let userLoction: CLLocation = locations[0]
			let distance = calculateDisatnceBetweenTwoLocations(prevLoc, destination: userLoction)
			if prevLoc != userLoction {
				prevLoc = userLoction
				MyVars.prevLoc = userLoction
			
			//TODO:  change "if distance > 5" back to 1000 if 5 isn't working
			if distance > 5 {
				let latitude = userLoction.coordinate.latitude
				let longitude = userLoction.coordinate.longitude
				let latDelta: CLLocationDegrees = 0.05
				let lonDelta: CLLocationDegrees = 0.05
				let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
				let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
				let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
				self.mapView.showsUserLocation = true
				self.mapView.setRegion(region, animated: true)
				updateVisiblePins(region: region)
			} else {
				let latitude = userLoction.coordinate.latitude
				let longitude = userLoction.coordinate.longitude
				let span = mapView.region.span
				let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
				let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
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


func updateVisiblePins(region region: MKCoordinateRegion) {
		for landmark in landmarks {
			let landmarkLat = landmark.coordinate.latitude
			let landmarkLong = landmark.coordinate.longitude
			let userLocation = locationManager.location
			let landmarkLocation = CLLocation(latitude: landmarkLat, longitude: landmarkLong)
			let distance = calculateDisatnceBetweenTwoLocations(userLocation!, destination: landmarkLocation)
			
			//TODO:  remove if/else and .removeAnnotations to show all pins
			if distance < 30 {
				mapView.addAnnotation(landmark)
			} else {
				mapView.removeAnnotation(landmark)
			}
		}
	}
	

	@IBAction func unwindToMapView(sender: UIStoryboardSegue) {
//		let sourceViewController = sender.sourceViewController
		let landmark = landmarks[rowIndex]
		print(landmark.title)
	}
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
	{
		print("Errors: " + error.localizedDescription)
	}
	
	func loadInitialData() {
		// 1
		let fileName = NSBundle.mainBundle().pathForResource("PublicLandmark", ofType: "json")
		
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

