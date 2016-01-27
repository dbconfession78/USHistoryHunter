//
//  VCMapView.swift
//  U.S. History Hunter
//
//  Created by Stuart Kuredjian on 1/26/16.
//  Copyright © 2016 s.Ticky Games. All rights reserved.
//

import Foundation
import UIKit	
import MapKit

extension ViewController: MKMapViewDelegate {
 
	// 1
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		if let annotation = annotation as? Landmark {
			let identifier = "pin"
			var view: MKPinAnnotationView
			if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
				as? MKPinAnnotationView { // 2
					dequeuedView.annotation = annotation
					view = dequeuedView
			} else {
				// 3
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				view.canShowCallout = true
				view.calloutOffset = CGPoint(x: -5, y: 5)
				view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
			}
			return view
		}
		return nil
	}
}