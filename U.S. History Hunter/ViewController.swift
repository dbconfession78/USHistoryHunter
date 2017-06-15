//
//  ViewController.swift
//  HonoluluArt2
//
//  Created by Stuart Kuredjian on 1/21/16.
//  Copyright © 2016 s.Ticky Games. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	@IBOutlet var mapView: MKMapView!

	@IBAction func Current(_ sender: AnyObject) {
		zoomToUserLocation()
	}
	
	var locationManager = CLLocationManager()
	var landmarkToPass: Landmark??
	var landmarkNameToPass: String = String()
	var rowIndex: Int!
	var wikiURL = "https://en.wikipedia.org/wiki/"
	var param = ""
	var error: NSError?
	var isConnecting: Bool = false
	var prevLoc = CLLocation()
	var landmarkURL: String?
	var visibleDistance: Double?
	
	/* */
	struct MyVars {
		static var region = MKCoordinateRegion()
		static var landmarks = [Landmark]()
		static var landmark: Landmark = Landmark(title: String(), locationName: String(), discipline: String(), info: String(), coordinate: CLLocationCoordinate2D())
	}

	/* (1) sets properties of locationManager and loads landmark JSON data from PublicLandmark.json*/
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		self.locationManager = CLLocationManager()
		self.locationManager.delegate = self
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		self.mapView.showsUserLocation = true
		self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
		loadInitialData()
	}
	
	/* (2) Retrives landmark name, type, address and coordinate from PublicLandmark.json */
	func loadInitialData() {
		let fileName = Bundle.main.path(forResource: "PublicLandmark", ofType: "json")
		var data: Data = Data()
		do {
			data = try Data(contentsOf: URL(fileURLWithPath: fileName!), options: [])
		} catch {
			
		}
		
		var jsonObject: Any!
		do {
			jsonObject = try JSONSerialization.jsonObject(with: data,
				options: [])
		} catch {
			
		}
		
		if let jsonObject = jsonObject as? [String: AnyObject],
			let jsonData = JSONValue.fromObject(jsonObject as AnyObject)?["data"]?.array {
				for landmarkJSON in jsonData {
					if let landmarkJSON = landmarkJSON.array, let landmark = Landmark.fromJSON(landmarkJSON) {
						MyVars.landmarks.append(landmark)
					}
				}
		}
	}
	
	/* (3) Creates annotation (pin) and associated properties for Landmark (callout bubble, info button etc.) */
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let identifier = "landmark"
		if annotation.isKind(of: Landmark.self) {
			var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
			
			if annotationView == nil {
				annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				annotationView! .canShowCallout = true
				let showInfoButton = UIButton(type: .detailDisclosure)
				annotationView! .rightCalloutAccessoryView = showInfoButton
				
			} else {
				annotationView! .annotation = annotation
			}
			
			return annotationView
		}
		return nil
	}
	
	func prepareAnnotationCallout(_ landmark: Landmark) {
		landmarkToPass = landmark
		self.landmarkURL = nil
		let urlDomain:String = self.wikiURL
		let urlParam: String = landmark.title!.replacingOccurrences(of: " ", with: "_")
		
		let conn = connectTo(urlDomain, urlParams: urlParam)
		let statusCode = conn.statusCode
		let responseString = conn.responseString
		if statusCode != 200 {
			/* If status code is NOT 200 */
			let statusCodeAsString = String(statusCode)
			let firstChar = statusCodeAsString.substring(with: (statusCodeAsString.startIndex ..< statusCodeAsString.characters.index(statusCodeAsString.startIndex, offsetBy: 1)))
			if firstChar == "4" {
				self.landmarkURL = searchWikipediaFor(urlParam)
			} else {
				print("\(statusCode) status code not handled by coder")
			}
		} else {
			/* If status code is 200 */
			/* check if it is the correct landing page */
			let identifier = "<a href=\"/wiki/Geographic_coordinate_system\" title=\"Geographic coordinate system\">Coordinates</a>"
			if responseString.contains(identifier) {
				/* if it is the correct landing page, print "correct page" */
				self.landmarkURL = self.wikiURL + urlParam
				print("\(urlParam): correct page")
			} else {
				/* if it's not the correct landing page, obtain wiki search results */
				print("\(urlParam): intermediate page.  Searching wiki...")
				self.landmarkURL = searchWikipediaFor(urlParam)
			}
		}
		if (statusCode != 200 && self.landmarkURL == nil) {
			let view = landmark as! MKAnnotationView
			view .rightCalloutAccessoryView = nil
		}
		zoomToLandmark(landmark)
	}
	
	/* (4) When user taps pin:
	- Shows pin's callout bubble
	- adds wiki info link to landmark's callout button (removes button if no link could be found)  */
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		let testLandmark: Landmark = Landmark(title: "Melville,_Herman,_House", locationName: "Holmes Rd., Pittsfield, MASSACHUSETTS", discipline: "", info: "", coordinate: CLLocationCoordinate2D(latitude: 42.420384, longitude: -73.245841))
		
		_ = testLandmark.title
		_ = testLandmark.locationName
//		prepareAnnotationCallout(testLandmark)
		prepareAnnotationCallout(view.annotation as! Landmark)
	}
	
	func determinePageType(_ responseString: String) -> String {
		var pageType = String()
		if responseString.contains("may refer to") {
			pageType = "may refer to"
			return pageType
			print("pageType: \(pageType)")
		}
		
		return pageType
	}

	/* (4a) Attempts to establish connection with wiki URL when user taps pin  */
	func connectTo(_ urlDomain: String!, urlParams: String) -> (statusCode: Int, responseString: String) {
		var statusCode: Int = Int()
		var responseString: String = String()
		let url: String = urlDomain + urlParams
		let connectThread = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
		self.isConnecting = true
		connectThread.async(execute: {
			let nsURL: URL = URL(string: url)!
			let request: URLRequest = URLRequest(url: nsURL)
			let session: URLSession = URLSession.shared
			let dataTask = session.dataTask(with: request, completionHandler: { (urlData, response, responseError) in
				if let httpResponse = response as? HTTPURLResponse {
					statusCode = httpResponse.statusCode
					do {
						responseString = try (NSString(contentsOf: nsURL, encoding: String.Encoding.utf8.rawValue)) as String
					} catch {
						
					}
				}
				self.isConnecting = false
			}) 
			dataTask.resume()
			
		})
		while isConnecting == true {
			Thread.sleep(forTimeInterval: 0)
		}
		return (statusCode, responseString)

	}
	
	/* (5) called by: searchWikipediaFor(..).  Creates array of words in search request  */
	func constructSearchTermArray(_ urlParams: String) -> ([String]) {
		var searchWords = [String]()
		var searchWord = ""
		
		let stringLength = (urlParams as NSString).length
		
		for i in 0 ..< stringLength {
			let char = urlParams.substring(with: (urlParams.characters.index(urlParams.startIndex, offsetBy: i) ..< urlParams.characters.index(urlParams.startIndex, offsetBy: i+1)))
			
			if char != "," {
				if char != "_" {
					searchWord += char
				} else {
					searchWords.append(searchWord)
					searchWord = ""
				}
				if i == stringLength-1 {
					searchWords.append(searchWord)
				}
			}
			
		}
		
		return searchWords
	}
	
	func parseHyperlinks(_ responseString: String) -> [NSTextCheckingResult] {
//		let searchWords = constructSearchTermArray(urlParams)
		var searchResults = [NSTextCheckingResult]()
		var group0: String = String()
		var group2: String = String()
		
		do {
			let regex = try NSRegularExpression(pattern: "(a href=\"/wiki/)([\"a-zA-Z:/._]+)(\")", options: [])
			let range = NSMakeRange(0, responseString.characters.count)
			
			let matches = regex.matches(in: responseString, options: NSRegularExpression.MatchingOptions(), range: range)
			for match in matches as [NSTextCheckingResult] {
				searchResults.append(match)
				group0 = (responseString as NSString).substring(with: match.rangeAt(0))
				group2 = (responseString as NSString).substring(with: match.rangeAt(2))
			}
		} catch {
			
		}
			return searchResults
	}
	
	/* (6) called by: mapView(..., didSelectAnnotationView, ...) */
	func searchWikipediaFor(_ urlParams: String) -> String {
		var searchParams = urlParams.replacingOccurrences(of: "_", with: "+")
		let searchDomain = "https://en.wikipedia.org"
		searchParams = "/w/index.php?title=Special%3ASearch&profile=default&search=\(searchParams)&fulltext=Search"
		let url = searchDomain + searchParams
		var selectedSearchResult = String()
		
		let conn = connectTo(searchDomain, urlParams: searchParams)
		let statusCode = conn.0
		let responseString = conn.1
		
		if statusCode == 200 {
			var searchResults = parseHyperlinks(responseString)
			
			/* if wiki search results page loads, collect search words into searchWords array */
			let searchWords = constructSearchTermArray(urlParams)
			searchResults = [NSTextCheckingResult]()
			var group0: String = String()
			var group2: String = String()
			do {
				let regex = try NSRegularExpression(pattern: "(a href=\"/wiki/)([\"a-zA-Z:/._]+)(\")", options: [])
				let range = NSMakeRange(0, responseString.characters.count)
				
				/*  collect page hyperlinks and add to matches[NSTextCheckingResult] array  */
				//TODO:  parseHyperlinks
				
				let matches = regex.matches(in: responseString, options: NSRegularExpression.MatchingOptions(), range: range)
				for match in matches as [NSTextCheckingResult] {
					searchResults.append(match)
					group0 = (responseString as NSString).substring(with: match.rangeAt(0))
					group2 = (responseString as NSString).substring(with: match.rangeAt(2))
					//				print(group2)
					var wordCount = Int()
					
					/* for each hyperlink in matches, see if any searcWords exist */
					for word in searchWords {
						let lastChar = word.substring(from: (word.characters.index(before: word.endIndex)))
						
						// test if landmark contains an initial (e.g. Harry F. Sinclair House
						if word.characters.count == 2 && lastChar == "." {
							if group2.contains("_\(word)") {
								wordCount += 1
								continue
							}
						}
						
						if group2.contains(word) {
							wordCount += 1
						}
					}
					

					if wordCount >= 3 {
						/* if 3 or more search request words exist in individual hyperlink
						connect to it */
						selectedSearchResult = self.wikiURL + group2
						let conn = connectTo(self.wikiURL, urlParams: group2)
						let statusCode = conn.0
						let responseString = conn.1
						/* if responseString DOES contain "...Coordinates...", return that url */
						if responseString.contains("<th scope=\"row\" style=\"font-weight:bold; border: 0;\">Coordinates</th>") {
							print("\(urlParams):  search result found")
							return selectedSearchResult
						} else {
							/* if responseString does NOT contain "...Coordinates..." */
							let pageType = determinePageType(responseString)
							switch pageType {
							
							case "may refer to":
								//TODO: landmarks location/address is needed here in order to grab it's State and City
								selectedSearchResult = landmarkUrlByCity(landmarkToPass!!, responseString: urlParams)
								print("TODO: action for case: \"may refer to\"")
								
							case "TODO: case 2 type":
								print("TODO:  action for case 2")
								
							case "TODO: case 3 type":
								print("TODO:  action for case 3")
								
							default:
								print("TODO:  default action")
							}
						}
					}
					
				}
				
			} catch {
				
			}
		} else {
			/* if initial param wiki search results page doesn't load */
			print("Search results page did not loaded")
		}
		return selectedSearchResult
	}
	
	
	//TODO:  complete functionº
	func landmarkUrlByCity(_ landmark: Landmark, responseString: String) -> String {
		let landmarkURL = String()
		let location = landmark.locationName
		print("Location: \(location)")
		let searchResults = parseHyperlinks(responseString)
		//TODO: compare location with states/cities in response string
		// to determine which hyperlink is correct landmark
		
		
		return landmarkURL
	}
	
	/* Centers screen when user taps landmark pin */
	func zoomToLandmark(_ landmark: Landmark) {
		let coordinate = landmark.coordinate
		let span = mapView.region.span
		let region = MKCoordinateRegion(center: coordinate, span: span)
		mapView.setRegion(region, animated: true)
	}
	
	//TODO:  should zoom street level
	func zoomToUserLocation() {
		let coordinate = locationManager.location?.coordinate
		let span = mapView.region.span
		let region = MKCoordinateRegion(center: coordinate!, span: span)
		mapView.setRegion(region, animated: true)
	}
	
	/* (7) Opens landmark's wikipedia entry when user taps info ("i") button in landmark's popup bubble */
	func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		landmarkToPass = annotationView.annotation as? Landmark
		if self.landmarkURL == nil {
			openLandmarkWikiPage(landmarkToPass!!)
		} else {
			openLandmarkWikiPage(self.landmarkURL! as AnyObject)
		}
	}
	
	/* (8) Opens landmark entry in Wikipedia */
	@IBAction func openLandmarkWikiPage(_ sender: AnyObject) {
		if sender is String {
			let URL = sender as! String
			let nsURL = Foundation.URL(string: URL)
			UIApplication.shared.openURL(nsURL!)
		} else {
			self.param = ""
			let landmarkName = (sender as! Landmark).title!
			let param = landmarkName.replacingOccurrences(of: " ", with: "_")
			self.param = param
			
			let URL = self.wikiURL + param
			let nsURL = Foundation.URL(string: URL)
			UIApplication.shared.openURL(nsURL!)
		}
	}

	/* (9) Retrieves URL source code and searches for key identifier strings
	used to confirm correct page */
	func openURLInSafari(_ url: String, identifier: String) {
		let conn = connectTo(url, urlParams: "")
		let statusCode = conn.0
		let responseString = conn.1
		
		if statusCode == 200 {
			if responseString.contains(identifier) {
				let nsURL = URL(string: url)
				UIApplication.shared.openURL(nsURL!)
			}
		}
	}

	/* Visible pins are updated. If user location changes, region is re-focused
	on new coordinate */
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
			var prevLoc = self.prevLoc
			let userLoction: CLLocation = locations[0]
			let distance = calculateDisatnceBetweenTwoLocations(prevLoc, destination: userLoction)
			if prevLoc != userLoction {
				prevLoc = userLoction
				self.prevLoc = userLoction
			
			if distance > 5 {
				let latitude = userLoction.coordinate.latitude
				let longitude = userLoction.coordinate.longitude
				let latDelta: CLLocationDegrees = 0.05
				let lonDelta: CLLocationDegrees = 0.05
				let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
				let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
				MyVars.region = MKCoordinateRegionMake(location, span)
				self.mapView.showsUserLocation = true
				self.mapView.setRegion(MyVars.region, animated: true)
				updateVisiblePins()
			} else {
				let latitude = userLoction.coordinate.latitude
				let longitude = userLoction.coordinate.longitude
				let span = mapView.region.span
				let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
				MyVars.region = MKCoordinateRegionMake(location, span)
				self.mapView.showsUserLocation = true
				updateVisiblePins()
			}
		}
	}

	/* Used to determine: a) if user location has changed and b) if user has travelled 
	outside of visible landmark radius */
	func calculateDisatnceBetweenTwoLocations(_ source:CLLocation,destination:CLLocation) -> Double{
		let distanceMeters = source.distance(from: destination)
		let distanceKM = distanceMeters / 1000
		return distanceKM
	}

	/* resets visible pins within location radius */
	func updateVisiblePins() {

		// **TEST** to see all visible pins, set visibleDistance to 'nil'
		let visibleDistance: Double! = 100
		
		for (index, landmark) in MyVars.landmarks.enumerated() {
			let landmarkLat = landmark.coordinate.latitude
			let landmarkLon = landmark.coordinate.longitude
			let userLocation = locationManager.location
			let landmarkLocation = CLLocation(latitude: landmarkLat, longitude: landmarkLon)
			let landmarkDistance = calculateDisatnceBetweenTwoLocations(userLocation!, destination: landmarkLocation)



			if visibleDistance == nil {
				mapView.addAnnotation(landmark)
			} else {
				self.visibleDistance = visibleDistance
				if landmarkDistance <= visibleDistance {
					mapView.addAnnotation(landmark)
				} else {
					if rowIndex != nil {
						if index == rowIndex{
							mapView.addAnnotation(landmark)
						} else {
							mapView.removeAnnotation(landmark)
							
						}
					}
				}
			}
			
			
		}
	}
	
	/* passes required values from this screen (Landmark map View) in preparation for loading
	another screen (e.g. Landmark List View) */
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showListView" {
			let tvc = segue.destination as! LandmarkTableViewController
			let landmarks = MyVars.landmarks
			
			tvc.userLocation = locationManager.location
			tvc.landmarks = landmarks
			tvc.visibleDistance = self.visibleDistance
		}
	}
	
	/* passes required values from another screen (e.g. Landmark list view) in preparation for
	loading this screen (Landmark map view) .*/
	@IBAction func unwindToMapView(_ sender: UIStoryboardSegue) {
		print(sender)
		
		if sender.source.isKind(of: LandmarkTableViewController.self) {
			MyVars.landmark = MyVars.landmarks[rowIndex]
			mapView.addAnnotation(MyVars.landmark)
			mapView.selectAnnotation(MyVars.landmark, animated: true)
			zoomToLandmark(MyVars.landmark)
		}
	}
	
	/* If locationManager encounters a error, the error's description is printed to the console  */
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Errors: " + error.localizedDescription)
	}
	
	@IBAction func testWikiButtonActionPerformed(_ sender: AnyObject) {
//		print("The following params either don't work or connect to an intermediate page:")
		var landmarkIndex = 0
		var intermediateCount = 0
		var failedToConnectCount = 0
		var houseCount = 0
		var totalCount = 0
		var houseLandmarkTitles = ["Government_House", "Old_State_House", "Gamble_House", "Los_Alamos_Ranch_House", "Stowe,_Harriet_Beecher,_House", "Octagon_House", "Ross,_John,_House", "Willard,_Frances,_House", "Miller_House", "Riley,_James_Whitcomb,_House", "Nation,_Carry_A.,_House", "Oakland_Plantation_House", "Chopin,_Kate,_House", "Acadian_House", "Stowe,_Harriet_Beecher,_House", "Tate_House", "Governor's_House", "Olson_House", "Brice_House", "Poe,_Edgar_Allan,_House", "Carson,_Rachel,_House", "Melville,_Herman,_House", "Boardman_House", "Ward,_John,_House", "Fairbanks_House", "Headquarters_House", "Old_State_House", "Field,_Eugene,_House", "Shelley_House", "Cather_House", "Stanton,_Elizabeth_Cady,_House", "President's_House", "Bunche,_Ralph,_House", "Stanton,_Elizabeth_Cady,_House", "Cupola_House", "Market_House", "Rankin,_John,_House", "Neville_House", "Buchanan,_James,_House", "Taylor,_George,_House", "Johnson,_John,_House", "Hunter_House", "Brown,_John,_House", "Tyler,_John,_House"]
		
		/* ************ TO TEST A SPECIFIC LANDMARK *******************/
//		let landmark: Landmark = Landmark(title: "Melville,_Herman,_House", locationName: "Holmes Rd., Pittsfield, MASSACHUSETTS", discipline: "", info: "", coordinate: CLLocationCoordinate2D(latitude: 42.420384, longitude: -73.245841))
//		prepareAnnotationCallout(landmark)
	
		/* ************ TO TEST THE houseLandmarkTitles *******************/
//		for houseLandmarkTitle in houseLandmarkTitles {
//			var param = houseLandmarkTitle
////			param = param.stringByReplacingOccurrencesOfString(" ", withString: "_")
//			let URL = NSURL(string: wikiURL + param)
//			var responseString: NSString
//			do {
//				if let url = URL {
//					let conn = connectTo(wikiURL, urlParams: param)
//					let statusCode = conn.statusCode
//					let responseString = conn.responseString
//					if statusCode != 200 {
//						/* If response code is NOT 200 */
//						let statusCodeAsString = String(statusCode)
//						let firstChar = statusCodeAsString.substringWithRange(Range<String.Index>(start: statusCodeAsString.startIndex, end: statusCodeAsString.startIndex.advancedBy(1)))
//						if firstChar == "4" {
//							self.landmarkURL = searchWikipediaFor(param)
//						} else {
//							print("\(statusCode) status code not handled by coder")
//						}
//					} else {
//						/* If status code is 200 */
//						/* check if it is the correct landing page */
//						let identifier = "<th scope=\"row\" style=\"font-weight:bold; border: 0;\">Coordinates</th>"
//						if responseString.containsString(identifier) {
//							/* if it is the correct landing page, print "correct page" */
//							self.landmarkURL = wikiURL + param
//							print("\(houseLandmarkTitle): correct page")
//						} else {
//							/* if it's not the correct landing page, obtain wiki search results */
//							print("\(houseLandmarkTitle): intermediate page.  Determining page type...")
//							self.landmarkURL = searchWikipediaFor(param)
//						}
//					}
//				}
//			} catch {
//				
//			}
//		}
	}
}

