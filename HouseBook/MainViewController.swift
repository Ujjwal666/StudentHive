//
//  MainViewController.swift
//  HouseBook
//
//  Created by Ujjwal Adhikari on 3/22/23.
//

import UIKit
import Nuke
import CoreLocation
import Alamofire
import AlamofireImage

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var apartmentView: UICollectionView!
    
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var apartmentTableView: UITableView!
    
    @IBOutlet weak var advertView: UIView!
    
    
    
    
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
    var apartmentsList = [ApartmentsList](){
        didSet {
            // Reload table view data any time the posts variable gets updated.
            apartmentTableView.reloadData()
            apartmentView.reloadData()
        }
    }
    
    
    
    let locationManager = CLLocationManager()
    private var imageDataRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
    
        apartmentView.delegate = self
        apartmentView.dataSource = self
        apartmentTableView.dataSource = self
        apartmentTableView.delegate = self
        advertView.layer.cornerRadius = 10.0
        userPic.layer.cornerRadius = 10.0
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.navigationItem.hidesBackButton = true
        queryApartments()
//        displayMultipleLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // battery
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            // Use the location to get the address
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding failed with error: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("No placemarks found.")
                    return
                }

                // Get the address in the format you requested
                let address = "\(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "")"
                print("Address", address)
                self.userAddress.text = address
                
            }
        }
    }
    
    private func queryApartments(){
        let query = ApartmentsList.query()
        query.find { [weak self] result in
            switch result {
            case . success(let apartmentsList):
                self?.apartmentsList = apartmentsList
                print(self?.apartmentsList)
                for apartment in self!.apartmentsList{
                    print("aap", apartment)
                }
            case .failure(let error):
                print("Error while loading the data, ",error)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("hi", apartmentsList)
        return apartmentsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collection = collectionView.dequeueReusableCell(withReuseIdentifier: "apartmentCell", for: indexPath) as! ApartmentCollectionViewCell
        if apartmentsList[indexPath.row].Photos == nil{
            let photo = apartmentsList[indexPath.row].userUploadPhoto?[0]
            if let imageFile = photo,
               let imageUrl = imageFile.url {
                print("Post", imageUrl)
                // Use AlamofireImage helper to fetch remote image from URL
                imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                    switch response.result {
                    case .success(let image):
                        // Set image view image with fetched image
                        collection.apartmentImage.image = image
                    case .failure(let error):
                        print("❌ Error fetching image: \(error.localizedDescription)")
                        break
                    }
                }
            }
        } else{
            let photo = apartmentsList[indexPath.row].Photos?[0]
            Nuke.loadImage(with: URL(string: photo!)!, into: collection.apartmentImage)
        }
        
        collection.apartmentImage.layer.cornerRadius = 30.0
        collection.collectionApartmentName.text = apartmentsList[indexPath.row].Name
        collection.collectionApartmentLocation.text = apartmentsList[indexPath.row].Location
        collection.collectionApartmentPrice.text = apartmentsList[indexPath.row].Rent
        collection.collectionApartmentRating.text = apartmentsList[indexPath.row].Ratings
        collection.layer.cornerRadius = 30.0
        return collection
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        let collectionView = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController
////        collectionView?.apartmentsList = self.apartmentsList[indexPath.row]
//////        print("clicked", apartmentsList[indexPath.row])
////        self.navigationController?.pushViewController(collectionView!, animated: true)
//        performSegue(withIdentifier: "detailSegue", sender: self)
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            if let detailView = segue.destination as? CollectionViewController {
                if let indexPaths = apartmentView.indexPathsForSelectedItems,
                   let indexPath = indexPaths.first{
                    detailView.apartmentsList = apartmentsList[indexPath.row]
                }
            }
        } else if segue.identifier == "detailSegue1"{
            if let detailView = segue.destination as? CollectionViewController {
                if let indexPaths = apartmentTableView.indexPathsForSelectedRows,
                   let indexPath = indexPaths.first{
                    detailView.apartmentsList = apartmentsList[indexPath.row]
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        apartmentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"apartmentTable", for: indexPath) as! ApartmentTableViewCell
        if apartmentsList[indexPath.row].Photos == nil{
            let photo = apartmentsList[indexPath.row].userUploadPhoto?[0]
            if let imageFile = photo,
               let imageUrl = imageFile.url {
                print("Post", imageUrl)
                // Use AlamofireImage helper to fetch remote image from URL
                imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                    switch response.result {
                    case .success(let image):
                        // Set image view image with fetched image
                        cell.apartmentImage.image = image
                    case .failure(let error):
                        print("❌ Error fetching image: \(error.localizedDescription)")
                        break
                    }
                }
            }
        } else{
            let photo = apartmentsList[indexPath.row].Photos?[0]
            Nuke.loadImage(with: URL(string: photo!)!, into: cell.apartmentImage)
        }
//        let photo = photos[indexPath.row]
//        Nuke.loadImage(with: URL(string: photo)!, into: cell.apartmentImage)
        cell.tableApartmentName.text = apartmentsList[indexPath.row].Name
        cell.tableApartmentLocation.text = apartmentsList[indexPath.row].Location
        cell.tableApartmentHousingType.text = apartmentsList[indexPath.row].RoomType
        cell.tableApartmentPrice.text = apartmentsList[indexPath.row].Rent
        cell.tableApartmentRatings.text = apartmentsList[indexPath.row].Ratings
        
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 3
        cell.apartmentImage.layer.cornerRadius = 30.0
        cell.layer.cornerRadius = 30.0

        return cell
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
