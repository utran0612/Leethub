//
//  UsersViewController.swift
//  Leetcode
//
//  Created by Uyen Thuc Tran on 5/3/22.
//

import UIKit
import Parse
import AlamofireImage

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var users = [PFObject]() //an array of dictionary
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        let username = (PFUser.current()?.username)!
    
        let url = URL(string: "https://leetcode-stats-api.herokuapp.com/"+username)!
        print(url)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                 let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                 
                 let easySolved = dataDictionary["easySolved"] as! Int
                 let mediumSolved = dataDictionary["mediumSolved"] as! Int
                 let hardSolved = dataDictionary["hardSolved"] as! Int
                 let ranking = dataDictionary["ranking"] as! Int
                 let totalSolved = dataDictionary["totalSolved"] as! Int
                 
                 let user = PFUser.current()!
                 user["easySolved"] = easySolved
                 user["mediumSolved"] = mediumSolved
                 user["hardSolved"] = hardSolved
                 user["ranking"] = ranking
                 user["totalSolved"] = totalSolved
                 
                 
                 user.saveInBackground {(success, error) in
                     if success{
                         print("saved!")
                     }else{
                         print("error!")
                     }
                 }
                
                 self.tableView.reloadData()

                 let query = PFQuery(className: "_User")
                 query.limit = 20
                 
                 query.findObjectsInBackground{ [self] users, error in
                     if users != nil {
                         self.users = users!
                         self.tableView.reloadData()
                     }
                 }
                 
             }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let user = users[indexPath.row] as! PFUser
        print(user)
        
        let username = user["username"] as! String
        let rank = user["ranking"] as! Int
        let ranking = String(rank)
        let numTotal = user["totalSolved"] as! Int
        
        var level = "Unknown"
        var color = UIColor.red
        
        if numTotal < 50{
            level = "BEGINNER"
            color = UIColor(red: 0.54, green: 0.85, blue: 0.50, alpha: 1.0)
        }else if numTotal < 200 {
            level = "INTERMEDIATE"
            color = UIColor(red: 0.4, green: 0.63, blue: 0.86, alpha: 1.0)
        }else{
            level = "ADVANCED"
            color = UIColor(red: 0.69, green: 0.113, blue: 0.113, alpha: 1.0)
        }
        
        user["level"] = level
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        
        //set user profile image on Leethub tab
        if user["profileImage"] != nil {
            let file = (user["profileImage"] as! PFFileObject)
            
            let urlString = file.url
            let url = URL(string: urlString!)
            cell.profileImage.af.setImage(withURL: url!)
            cell.profileImage.layer.cornerRadius = 20
            cell.profileImage.clipsToBounds = true
        }
        
        //users.removeFirst()
        
        cell.usernameLabel.text = username ?? "Unknown"
        cell.rankingLabel.text = ranking
        cell.userlevelLabel.text = level
        cell.userlevelLabel.textColor = color
        //}
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        print("Loading the data")
        // Find the selected user
        let cell = sender as! UserCell
        let indexPath = tableView.indexPath(for: cell)!
        
        let user = users[indexPath.row]
    
        //Pass the selected movie to the view controller
        let detailsViewController = segue.destination as! UserDetailsViewController
        detailsViewController.user = (user as? PFUser)!
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name:"Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else{return}
        
        delegate.window?.rootViewController = loginViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        let query = PFQuery(className: "_User")
        //query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground{ [self] users, error in
            if users != nil {
                self.users = users!
                self.tableView.reloadData()
            }
        refreshControl.endRefreshing()
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
