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
    let photos = [
        "https://images1.apartments.com/i2/_V89dQA-MbEHkJKJsx39FprHzLuqSYmyVPt1t45SnUY/116/banner-lane-washington-dc-primary-photo.jpg?p=1",
        "https://images1.apartments.com/i2/y8QuFVveUqwR1uudO7kjnpQF4dsf_qHB5jipuT8T334/111/banner-lane-washington-dc-building-photo.jpg?p=1",
        "https://images1.apartments.com/i2/Cq9BOnYrMuMzICxjV8QNVYiaPznq2Z-h3MRjn2ngX0I/111/banner-lane-washington-dc-building-photo.jpg?p=1",
        "https://images1.apartments.com/i2/_V89dQA-MbEHkJKJsx39FprHzLuqSYmyVPt1t45SnUY/116/banner-lane-washington-dc-primary-photo.jpg?p=1",
        "https://images1.apartments.com/i2/y8QuFVveUqwR1uudO7kjnpQF4dsf_qHB5jipuT8T334/111/banner-lane-washington-dc-building-photo.jpg?p=1",
        "https://images1.apartments.com/i2/Cq9BOnYrMuMzICxjV8QNVYiaPznq2Z-h3MRjn2ngX0I/111/banner-lane-washington-dc-building-photo.jpg?p=1",
        "https://images1.apartments.com/i2/_V89dQA-MbEHkJKJsx39FprHzLuqSYmyVPt1t45SnUY/116/banner-lane-washington-dc-primary-photo.jpg?p=1",
        "https://images1.apartments.com/i2/y8QuFVveUqwR1uudO7kjnpQF4dsf_qHB5jipuT8T334/111/banner-lane-washington-dc-building-photo.jpg?p=1",
        "https://images1.apartments.com/i2/Cq9BOnYrMuMzICxjV8QNVYiaPznq2Z-h3MRjn2ngX0I/111/banner-lane-washington-dc-building-photo.jpg?p=1"
      ]
    
    let users = ["https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg", "https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg", "https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg", "https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg","https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg","https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg", "https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg", "https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg", "https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg","https://sb.kaleidousercontent.com/67418/1920x1545/c5f15ac173/samuel-raita-ridxdghg7pw-unsplash.jpg"]

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
        
        userProfile.layer.cornerRadius = 10.0
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
        return users.count
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
        let photo = users[indexPath.row]
        let collection = collectionView.dequeueReusableCell(withReuseIdentifier: "userCollectionView", for: indexPath) as! UserCollectionViewCell
        Nuke.loadImage(with: URL(string: photo)!, into: collection.userProfile)
        collection.userProfile.layer.cornerRadius = collection.userProfile.frame.width/2
//        collection.userProfile.layer.cornerRadius = 50.0
        return collection
        
    }
}
