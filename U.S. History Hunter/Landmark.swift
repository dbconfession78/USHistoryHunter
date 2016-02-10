import MapKit

class Landmark: NSObject, MKAnnotation {
	let title: String?
	let locationName: String
	let discipline: String
	let coordinate: CLLocationCoordinate2D
 
	init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
		self.title = title
		self.discipline = discipline
		self.locationName = locationName
		self.coordinate = coordinate
		
		super.init()
		
		
	}
 class func fromJSON(json: [JSONValue]) -> Landmark? {
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
 
	// 3
	return Landmark(title: title, locationName: locationName!, discipline: discipline!, coordinate: coordinate)
	}
	var subtitle: String? {
		return locationName
	}
}