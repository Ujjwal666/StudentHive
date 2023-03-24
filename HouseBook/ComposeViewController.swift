//
//  ComposeViewController.swift
//  RoomBook
//
//  Created by Sanjaya Subedi on 3/23/23.
//

import UIKit
import PhotosUI
import ParseSwift

class ComposeViewController: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var plusOne: UIButton!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var didtapSubmit: UIBarButtonItem!
    
    @IBOutlet weak var apartmentLocation: UITextField!
    @IBOutlet weak var apartmentName: UITextField!
    
    @IBOutlet weak var apartmentDescription: UITextField!
    @IBOutlet weak var apartmentPrice: UITextField!
    @IBOutlet weak var apartmentType: UITextField!
    
    @IBOutlet weak var plusThree: UIButton!
    @IBOutlet weak var plusTwo: UIButton!
    
    @IBOutlet weak var plusFour: UIButton!
    
    @IBOutlet weak var extraImageThree: UIImageView!
    @IBOutlet weak var extraImageTwo: UIImageView!
    @IBOutlet weak var extraImageOne: UIImageView!
    
    
    
    var pickedImage1: UIImage?
    
    var pickedImage2: UIImage?
    var pickedImage3: UIImage?
    var pickedImage4: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func didTapAlbum(sender: UIButton){
            var config = PHPickerConfiguration()

            // Set the filter to only show images as options (i.e. no videos, etc.).
            config.filter = .images

            // Request the original file format. Fastest method as it avoids transcoding.
            config.preferredAssetRepresentationMode = .current

            // Only allow 1 image to be selected at a time.
            config.selectionLimit = 1

            // Instantiate a picker, passing in the configuration.
            let picker = PHPickerViewController(configuration: config)

            // Set the picker delegate so we can receive whatever image the user picks.
            picker.delegate = self
        
            picker.view.tag = sender.tag

            // Present the picker
            present(picker, animated: true)
            
            
        }
        
        @IBAction func didTapShare(sender: UIButton){
            if var currentUser = User.current {
                // The current user is logged in
                print("Current user's username: \(currentUser.username ?? "")")
                guard let image = pickedImage1,
                              // Create and compress image data (jpeg) from UIImage
                              let imageData1 = image.jpegData(compressionQuality: 0.1) else {
                            return
                        }
                guard let image = pickedImage2,
                              // Create and compress image data (jpeg) from UIImage
                              let imageData2 = image.jpegData(compressionQuality: 0.1) else {
                            return
                        }
                guard let image = pickedImage3,
                              // Create and compress image data (jpeg) from UIImage
                              let imageData3 = image.jpegData(compressionQuality: 0.1) else {
                            return
                        }
                guard let image = pickedImage4,
                              // Create and compress image data (jpeg) from UIImage
                              let imageData4 = image.jpegData(compressionQuality: 0.1) else {
                            return
                        }
                
                        // Create a Parse File by providing a name and passing in the image data
                let imageFile1 = ParseFile(name: "image.jpg", data: imageData1)
                let imageFile2 = ParseFile(name: "image.jpg", data: imageData2)
                let imageFile3 = ParseFile(name: "image.jpg", data: imageData3)
                let imageFile4 = ParseFile(name: "image.jpg", data: imageData4)
                
                guard let aptName = apartmentName.text,
                      let aptLocation = apartmentLocation.text,
                      let aptType = apartmentType.text,
                      let aptPrice = apartmentPrice.text,
                      let aptDes = apartmentDescription.text,
                      !aptName.isEmpty,
                      !aptLocation.isEmpty,
                      !aptType.isEmpty,
                      !aptPrice.isEmpty,
                      !aptDes.isEmpty else{
                    return
                }

                var post = ApartmentsList()
                        
                // Set properties
                post.userUploadPhoto = [imageFile1,imageFile2,imageFile3,imageFile4]
                post.Name = aptName
                post.Location = aptLocation
                post.RoomType = aptType
                post.Rent = aptPrice
                post.About = aptDes
                
                // Set the user as the current user
                post.user = User.current?.username
                
                // Save object in background (async)
                post.save { [weak self] result in
                    
                    // Switch to the main thread for any UI updates
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let post):
                            print("✅ Post Saved! \(post)")
//                            
//                            // Return to previous view controller
//                            self?.navigationController?.popViewController(animated: true)
                            
                        case .failure(let error):
                            print("error", error)
                        }
                    }
                }
                
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "UITabBarController") as! UITabBarController
                self.navigationController?.pushViewController(nextVC, animated: true)
                self.navigationItem.hidesBackButton = true
                
                
            } else {
                // No user is logged in
                print("No user is logged in")
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
extension ComposeViewController: PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            // Make sure we have a non-nil item provider
            guard let provider = results.first?.itemProvider,
               // Make sure the provider can load a UIImage
               provider.canLoadObject(ofClass: UIImage.self) else { return }

            // Load a UIImage from the provider
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

               // Make sure we can cast the returned object to a UIImage
               guard let image = object as? UIImage else {

                  // ❌ Unable to cast to UIImage
    //              self?.showAlert()
                  return
               }
                
                
                let tag = picker.view.tag
                switch tag{
                case 1:
                    self?.pickedImage1 = image
                    DispatchQueue.main.async {
                        self?.mainImage.image = image
                    }
                case 2:
                    self?.pickedImage2 = image
                    DispatchQueue.main.async {
                        self?.extraImageOne.image = image
                    }
                case 3:
                    self?.pickedImage3 = image
                    DispatchQueue.main.async {
                        self?.extraImageTwo.image = image
                    }
                case 4:
                    self?.pickedImage4 = image
                    DispatchQueue.main.async {
                        self?.extraImageThree.image = image
                    }
                default:
                    break
                    
                }
                

               // Check for and handle any errors
               if let error = error {
                  print("error", error)
                  return
               }
                
               
            }
        }
        
    
    
}
