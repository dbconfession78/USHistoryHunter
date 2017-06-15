//
//  LandmarkTableViewController.swift
//  U.S. History Hunter
//
//  Created by Stuart Kuredjian on 2/13/16.
//  Copyright © 2016 s.Ticky Games. All rights reserved.
//

import UIKit
import MapKit

class LandmarkTableViewController: UITableViewController {
	weak var previousVC: UIViewController!
	var landmarks = [Landmark]()
	var landmarkNames = [String]()
	var landmarkAddresses: [String] = [String]()
	var landmarkCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
	var mapView: MKMapView = MKMapView()
	var annotations: [MKAnnotation] = [MKAnnotation]()
	var userLocation: CLLocation!
	var rowIndex: Int!
	var visibleDistance: Double! = nil

	//TODO: find images for each landmark (try googlemaps)
	var landmarkImages = [""]
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		for landmark in self.landmarks {
			landmarkNames.append(landmark.title!)
			landmarkAddresses.append(landmark.locationName)
			landmarkCoordinates.append(landmark.coordinate)
		}
    }
	
	func calculateDisatnceBetweenTwoLocations(_ source:CLLocation,destination:CLLocation) -> Double{
		let distanceMeters = source.distance(from: destination)
		let distanceKM = distanceMeters / 1000
		
		return distanceKM
	}
	
	// populates UI with all landmarks (next func hides cells)
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIndentifier = "Cell"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath)
		
		// Add name and address of landmark
		cell.textLabel?.text = landmarkNames[indexPath.row]
		cell.detailTextLabel!.text = landmarkAddresses[indexPath.row]
		
		//TODO:  find images for landmarks (try google maps)
//		cell.imageView?.image = UIImage(named: landmarkImages[indexPath.row])
	
		return cell
	}
	
	
	// Hides cells whose landmark is over 30 miles from userLocation
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let rowIndex = indexPath.row

		let landmark = landmarks[rowIndex]
		let landmarkLat = landmark.coordinate.latitude
		let landmarkLon = landmark.coordinate.longitude
		let landmarkLocation = CLLocation(latitude: landmarkLat, longitude: landmarkLon)
		let landmarkDistance = calculateDisatnceBetweenTwoLocations(userLocation, destination: landmarkLocation)
		
		if self.visibleDistance == nil {
			return 50.0
		}
		
		if landmarkDistance == visibleDistance {
			return 50.0
		} else {
			return 0.0
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
		
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
		if segue.identifier == "showViewController" {
			let vc = segue.destination as! ViewController
			let row = tableView.indexPathForSelectedRow?.row
			vc.rowIndex = row!
		}
	}
	

    // MARK: - Table view data source

	// sets the number of sections per row
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
	override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
		print("")
	}

	// sets the numrber of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return landmarkNames.count
    }
}
