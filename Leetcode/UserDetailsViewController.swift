//
//  UserDetailsViewController.swift
//  Leetcode
//
//  Created by Uyen Thuc Tran on 5/6/22.
//

import UIKit
import MapKit
import Parse

class UserDetailsViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var profileImage: UIImageView!


    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var easySolvedLabel: UILabel!
    @IBOutlet weak var mediumSolvedLabel: UILabel!
    @IBOutlet weak var hardSolvedLabel: UILabel!
    @IBOutlet weak var userLocation: MKMapView!
    
    var user = PFUser()
    let manager = CLLocationManager()
    var coordinates = [PFGeoPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        if user["profileImage"] != nil {
            let file = (user["profileImage"] as! PFFileObject)
            
            let urlString = file.url
            let url = URL(string: urlString!)
            profileImage.af.setImage(withURL: url!)
            profileImage.layer.cornerRadius = 75
            profileImage.clipsToBounds = true
        }
        
        //Assign user name
        usernameLabel.text = user["username"] as? String
        
        //Assign user's ranking\
        let rank = (user["ranking"] as! Int)
        let ranking = String(rank)
        rankingLabel.text = ranking
        
        //Assign user's level
        let numTotal = user["totalSolved"]
        let level = chooseColor(totalSolved: numTotal as! Int).level
        levelLabel.text = level
        levelLabel.textColor = chooseColor(totalSolved: numTotal as! Int).color
        
        //Assign bio
        let bio = user["bio"] as! String
        bioTextView.text = bio
        
        //Assign progress
        let easy = user["easySolved"] as! Int
        let easySolved = String(easy)
        let medium = user["mediumSolved"] as! Int
        let mediumSolved = String(medium)
        let hard = user["hardSolved"] as! Int
        let hardSolved = String(hard)
        easySolvedLabel.text = easySolved
        mediumSolvedLabel.text = mediumSolved
        hardSolvedLabel.text = hardSolved
    }
    
    func chooseColor(totalSolved:Int) -> (level:String,color:UIColor){
        var level = "Unknown"
        var color = UIColor.red
        if totalSolved < 50{
            level = "BEGINNER"
            color = UIColor(red: 0.54, green: 0.85, blue: 0.50, alpha: 1.0)
        }else if totalSolved < 200 {
            level = "INTERMEDIATE"
            color = UIColor(red: 0.4, green: 0.63, blue: 0.86, alpha: 1.0)
        }else{
            level = "ADVANCED"
            color = UIColor(red: 0.69, green: 0.113, blue: 0.113, alpha: 1.0)
        }
        return (level,color)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest //battery
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        if let location = locations.first{
            manager.stopUpdatingLocation()
            
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        
        //Get current user's location
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        userLocation.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "Find me here!"
        userLocation.addAnnotation(pin)
        
        
        let coordinateDict = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        //Add "coordinate" as a User class's field and save in background
        user["coordinate"] = coordinateDict
        //print("CURRENT COORDINATE",currentUser["coordinate"]!);
        user.saveInBackground {(success, error) in
            if success{
                print("saved!")
            }else{
                print("error!")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
