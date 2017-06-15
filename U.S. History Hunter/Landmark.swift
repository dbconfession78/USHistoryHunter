import MapKit
import UIKit

class Landmark: NSObject, MKAnnotation {
	let title: String?
	let locationName: String
	let discipline: String
	let info: String
	let coordinate: CLLocationCoordinate2D
	
 
	init(title: String, locationName: String, discipline: String, info: String, coordinate: CLLocationCoordinate2D) {
		self.title = title
		self.discipline = discipline
		self.locationName = locationName
		self.info = info
		self.coordinate = coordinate
		//		super.init()
	}
	
	class func fromJSON(_ json: [JSONValue]) -> Landmark? {
		// 1
		var title: String
		if let titleOrNil = json[4].string {
			title = titleOrNil
		} else {
			title = ""
		}
		let discipline = json[5].string
		let locationName = json[6].string
		// 2
		let latitude = (json[7].string! as NSString).doubleValue
		let longitude = (json[8].string! as NSString).doubleValue
		let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		
		let info = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
		
		// 3
		return Landmark(title: title, locationName: locationName!, discipline: discipline!, info: info, coordinate: coordinate)
	}
	var subtitle: String? {
		return locationName
	}
}
