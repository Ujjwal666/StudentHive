//
//  CollectionViewController.swift
//  HouseBook
//
//  Created by Ujjwal Adhikari on 3/22/23.
//

import UIKit
import Nuke
import Alamofire
import AlamofireImage

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    
    @IBOutlet weak var userView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var detailApartmentName: UILabel!
    @IBOutlet weak var detailApartmentLocation: UILabel!
    @IBOutlet weak var detailApartmentRating: UILabel!
    @IBOutlet weak var detailApartmentType: UILabel!
    @IBOutlet weak var detailApartmentPrice: UILabel!
    @IBOutlet weak var detailApartmentAbout: UILabel!
    @IBOutlet weak var lease: UILabel!
    
    @IBOutlet weak var bubble: UIButton!
    @IBOutlet weak var phone: UIImageView!
    private var imageDataRequest: DataRequest?
    var apartmentsList: ApartmentsList!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("initial", self.apartmentsList)
        collectionView.dataSource = self
        collectionView.delegate = self
        userView.dataSource = self
        userView.delegate = self
        
        detailApartmentName.text = apartmentsList.Name
        detailApartmentLocation.text = apartmentsList.Location
        detailApartmentType.text = apartmentsList.RoomType
        detailApartmentRating.text = apartmentsList.Ratings
        detailApartmentPrice.text = apartmentsList.Rent
        detailApartmentAbout.text = apartmentsList.About
        lease.text = apartmentsList.leaseType
        lease.layer.masksToBounds = true
        lease.layer.cornerRadius = 5
        
        if let currentUser = User.current{
            let initials = String(apartmentsList.user!.prefix(2)).uppercased()
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: userProfile.frame.width, height: userProfile.frame.height))
            label.text = initials
            label.textColor = .white
            label.backgroundColor = .systemBlue
            label.textAlignment = .center
            
            userProfile.contentMode = .center // or .scaleAspectFit
            userProfile.addSubview(label)
            
            UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
            label.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            userProfile.image = image
            userProfile.layer.cornerRadius = 10.0
        }
        
        phone.layer.cornerRadius = 10.0
        bubble.layer.cornerRadius = 10.0

        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("collection", apartmentsList!)
        if collectionView == self.collectionView{
            if apartmentsList.Photos == nil{
                return apartmentsList.userUploadPhoto!.count
            }
            return apartmentsList.Photos!.count
        }
        return apartmentsList.interestedUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView{
            let collection = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionView", for: indexPath) as! CollectionViewCell
            if apartmentsList.Photos == nil{
                let photo = apartmentsList.userUploadPhoto?[indexPath.row]
                if let imageFile = photo,
                   let imageUrl = imageFile.url {
                    print("Post", imageUrl)
                    // Use AlamofireImage helper to fetch remote image from URL
                    imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                        switch response.result {
                        case .success(let image):
                            // Set image view image with fetched image
                            collection.images.image = image
                        case .failure(let error):
                            print("❌ Error fetching image: \(error.localizedDescription)")
                            break
                        }
                    }
                }
            }else{
                let photo = apartmentsList.Photos?[indexPath.row]
                Nuke.loadImage(with: URL(string: photo!)!, into: collection.images)
            }
            collection.images.layer.cornerRadius = 50.0
            return collection
        }
        let initials = String(apartmentsList.interestedUser[indexPath.row].prefix(2)).uppercased()
        let collection = collectionView.dequeueReusableCell(withReuseIdentifier: "userCollectionView", for: indexPath) as! UserCollectionViewCell
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: collection.userProfile.frame.width, height: collection.userProfile.frame.height))
        label.text = initials
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.textAlignment = .center
        
        collection.userProfile.contentMode = .center // or .scaleAspectFit
        collection.userProfile.addSubview(label)
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        collection.userProfile.image = image
        
//        Nuke.loadImage(with: URL(string: photo)!, into: collection.userProfile)
        collection.userProfile.layer.cornerRadius = collection.userProfile.frame.width/2
//        collection.userProfile.layer.cornerRadius = 50.0
        return collection
        
    }
    
    @IBAction func interestedClicked(_ sender: Any) {
        if var currentUser = User.current{
            if apartmentsList.interestedUser.contains(currentUser.username!) {
                // Display a success message
                let alert = UIAlertController(title: "❌", message: "User is already interested", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                apartmentsList.interestedUser.append(currentUser.username!)
                currentUser.interestedProperty.append(apartmentsList.objectId ?? "nil")
            }
            print("❌",apartmentsList.objectId,currentUser.objectId)
            print("❌", currentUser.interestedProperty, currentUser.objectId)
            do {
                try currentUser.save()
                try apartmentsList.save()
                print("User saved successfully.")
                print("❌", currentUser.interestedProperty)
                
                // Display a success message
                let alert = UIAlertController(title: "Success", message: "Added to list successfully!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } catch {
                print("Error saving user: \(error.localizedDescription)")
            }
        }
    }
    
}
