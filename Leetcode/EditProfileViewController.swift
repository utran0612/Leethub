//
//  EditProfileViewController.swift
//  Leetcode
//
//  Created by Uyen Thuc Tran on 5/8/22.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var levelSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        bioTextField.isHidden = false
        bioTextView.isHidden = true
        

        // Do any additional setup after loading the view.
    }
        
    @IBAction func onClickButton(_ sender: Any) {
        /*let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground{(isSuccess,error) in
            if (isSuccess){
                print("Saved!")
                self.dismiss(animated: true, completion: nil)
            }else{
                print("error: \(error)")
            }
        }*/
        let bioContent = bioTextField.text!
        bioTextView.text = bioContent
        bioTextView.isHidden = false
        bioTextField.isHidden = true
        
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
