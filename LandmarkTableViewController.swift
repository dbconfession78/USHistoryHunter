//
//  LandmarkTableViewController.swift
//  U.S. History Hunter
//
//  Created by Stuart Kuredjian on 2/13/16.
//  Copyright © 2016 s.Ticky Games. All rights reserved.
//

import UIKit

class LandmarkTableViewController: UITableViewController {
	
//	@IBOutlet weak var tableViewCell: UITableViewCell!
	var landmarks = [Landmark]()
	var landmarkNames: [String] = [String]()
	var landmarkAddresses: [String] = [String]()
	
	//TODO: find images for each landmark (try googlemaps)
	var landmarkImages = [""]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		loadInitialData()
		for landmark in landmarks {
			landmarkNames.append(landmark.title!)
			landmarkAddresses.append(landmark.locationName)
		}
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print("test")
	}
	
	
	// Pulls landmark info from JSON file
	func loadInitialData() {
		let fileName = NSBundle.mainBundle().pathForResource("PublicLandmark", ofType: "json")
		var data: NSData = NSData()
		
		do {
			data = try NSData(contentsOfFile: fileName!, options: [])
		} catch {
			
		}
		
		var jsonObject: AnyObject!
		do {
			jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
		} catch {
			
		}
		
		if let jsonObject = jsonObject as? [String: AnyObject],
			let jsonData = JSONValue.fromObject(jsonObject)?["data"]?.array {
				for landmarkJSON in jsonData {
					if let landmarkJSON = landmarkJSON.array,
						landmark = Landmark.fromJSON(landmarkJSON) {
							landmarks.append(landmark)
					}
				}
		}
	}
	
	// populates UI
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cellIndentifier = "Cell"
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIndentifier, forIndexPath: indexPath)
		
		
		// Configure the cell...
		cell.textLabel?.text = landmarkNames[indexPath.row]
		cell.detailTextLabel!.text = landmarkAddresses[indexPath.row]
		
		//TODO:  find images for landmarks (try google maps)
//		cell.imageView?.image = UIImage(named: landmarkImages[indexPath.row])
	
		return cell
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

	// sets the number of sections per row
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

	// sets the number of rows
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return landmarkNames.count
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
