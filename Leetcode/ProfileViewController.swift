//
//  ProfileViewController.swift
//  Leetcode
//
//  Created by Uyen Thuc Tran on 5/5/22.
//

import UIKit
import Parse
import AlamofireImage
import MapKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    
    @IBOutlet weak var easyLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var hardLabel: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentUser = PFUser.current()
    
    let currentUserId = PFUser.current()?.objectId
    let manager = CLLocationManager()
    var users = [PFObject]()
    var coordinates = [PFGeoPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        usernameLabel.text = currentUser?.username
        
        //fetch profile image
        if currentUser?["profileImage"] != nil {
            let file = (currentUser!["profileImage"] as! PFFileObject)
            
            file.getDataInBackground { (imageData: Data?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let imageData = imageData {
                    let image = UIImage(data: imageData)
                    self.profileImage.image = image
                }
            }
        }
        //Round image
        profileImage.layer.cornerRadius = 75
        profileImage.clipsToBounds = true
        
        //Assign current user's ranking and level
        let rank = (currentUser?["ranking"] as! Int)
        let ranking = String(rank)
        
        let numTotal = currentUser?["totalSolved"] as! Int
        let level = chooseColor(totalSolved: numTotal).level
        let color = chooseColor(totalSolved: numTotal).color
        rankingLabel.text = ranking
        levelLabel.text = level
        levelLabel.textColor = color
        
        //Assign current user's bio
        let bio = currentUser?["bio"]
        bioTextView.text = bio as! String
        
        //Assgin current user's progress
        let easy = currentUser?["easySolved"] as! Int
        let easySolved = String(easy)
        let medium = currentUser?["mediumSolved"] as! Int
        let mediumSolved = String(medium)
        let hard = currentUser?["hardSolved"] as! Int
        let hardSolved = String(hard)
        easyLabel.text = easySolved
        mediumLabel.text = mediumSolved
        hardLabel.text = hardSolved
        
        
        bioTextField.isHidden = true
        updateButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // fetch user name
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest //battery
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        

    }
    
    @IBAction func onEditButton(_ sender: Any) {
        bioTextView.isHidden = true
        bioTextField.isHidden = false
        editButton.isHidden = true
        updateButton.isHidden = false
    }
    @IBAction func onUpdateButton(_ sender: Any) {
        let bioContent = bioTextField.text
        bioTextField.isHidden = true
        
        bioTextView.isHidden = false
        bioTextView.text = bioContent
        
        updateButton.isHidden = true
        editButton.isHidden = false
        currentUser?["bio"] = bioContent
        currentUser?.saveInBackground {(success, error) in
            if success{
                print("saved!")
            }else{
                print("error!")
            }
        }
        
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
        mapView.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "Find me here!"
        mapView.addAnnotation(pin)
        
        
        let coordinateDict = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        //Add "coordinate" as a User class's field and save in background
        currentUser?["coordinate"] = coordinateDict
        //print("CURRENT COORDINATE",currentUser["coordinate"]!);
        currentUser?.saveInBackground {(success, error) in
            if success{
                print("saved!")
            }else{
                print("error!")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width:150,height:150 )
        let scaledImage = image.af.imageScaled(to: size)
        
        //round profile image
        profileImage.image = scaledImage
        profileImage.layer.cornerRadius = 75
        profileImage.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)

        let profileImage = profileImage.image!.pngData()
        let file = PFFileObject(name: "profile.png", data: profileImage!)
        
        currentUser?["profileImage"] = file
        
        currentUser?.saveInBackground {(success, error) in
            if success{
                print("saved!")
            }else{
                print("error!")
            }
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
