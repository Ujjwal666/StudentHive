//
//  ProfileViewController.swift
//  HouseBook
//
//  Created by Ujjwal Adhikari on 4/16/23.
//

import UIKit
import Alamofire
import Nuke
import ParseSwift


class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var apartmentsList: [ApartmentsList]!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var listedView: UICollectionView!
    
    @IBOutlet weak var interestedView: UICollectionView!
    
    private var imageDataRequest: DataRequest?
    var allApartmentsList = [ApartmentsList]()
    var interestedApartmentList = [ApartmentsList](){
        didSet {
            // Reload table view data any time the posts variable gets updated.
            interestedView.reloadData()
            listedView.reloadData()
        }
    }
    
    var listedApartmentList = [ApartmentsList](){
        didSet {
            // Reload table view data any time the posts variable gets updated.
            interestedView.reloadData()
            listedView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listedView.dataSource = self
        listedView.delegate = self
        interestedView.dataSource = self
        interestedView.delegate = self
        
        if let currentUser = User.current {
            username.text = "Username: "+currentUser.username!
            if (currentUser.email != nil){
                email.text = "Email: "+currentUser.email!
            } else {
                email.text = ""
            }
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        queryApartments()
    }
    
    private func queryApartments(){
        let query = ApartmentsList.query()
        query.find { [weak self] result in
            switch result {
            case . success(let apartmentsList):
                self?.allApartmentsList = apartmentsList
                
                for apartment in self!.allApartmentsList{
                    if apartment.user == User.current?.username{
                        self!.listedApartmentList.append(apartment)
                    }
                }
                self?.listedView.reloadData()
                
                for apartmendId in User.current!.interestedProperty{
                    for apartment in self!.allApartmentsList{
                        if apartmendId == apartment.objectId{
                            self!.interestedApartmentList.append(apartment)
                        }
                    }
                }
                
                self?.interestedView.reloadData()
            case .failure(let error):
                print("Error while loading the data, ",error)
            }
        }
    }
    
    @IBAction func tapLogOutButton(_ sender: Any) {
        do {
            try User.logout()
            UserDefaults.standard.removeObject(forKey: "session_token")
            UserDefaults.standard.synchronize()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginNav")
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController,animated: true) {
                self.navigationController?.setViewControllers([], animated: false)
            }
        } catch let error{
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.listedView{
            return listedApartmentList.count
        } else {
            return interestedApartmentList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.listedView {
            let collection = collectionView.dequeueReusableCell(withReuseIdentifier: "apartmentCell", for: indexPath) as! ApartmentCollectionViewCell
            if listedApartmentList[indexPath.row].Photos == nil{
                let photo = listedApartmentList[indexPath.row].userUploadPhoto?[0]
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
                let photo = listedApartmentList[indexPath.row].Photos?[0]
                Nuke.loadImage(with: URL(string: photo!)!, into: collection.apartmentImage)
            }
            
            collection.apartmentImage.layer.cornerRadius = 30.0
            collection.collectionApartmentName.text = listedApartmentList[indexPath.row].Name
            collection.collectionApartmentLocation.text = listedApartmentList[indexPath.row].Location
            collection.collectionApartmentPrice.text = listedApartmentList[indexPath.row].Rent
            collection.collectionApartmentRating.text = listedApartmentList[indexPath.row].Ratings
            collection.layer.cornerRadius = 30.0
            return collection
        }
//        interested
        let collection = collectionView.dequeueReusableCell(withReuseIdentifier: "apartmentCell", for: indexPath) as! ApartmentCollectionViewCell
        print("Hell", interestedApartmentList)
        if interestedApartmentList[indexPath.row].Photos == nil{
            let photo = interestedApartmentList[indexPath.row].userUploadPhoto?[0]
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
            let photo = interestedApartmentList[indexPath.row].Photos?[0]
            Nuke.loadImage(with: URL(string: photo!)!, into: collection.apartmentImage)
        }
        
        collection.apartmentImage.layer.cornerRadius = 30.0
        collection.collectionApartmentName.text = interestedApartmentList[indexPath.row].Name
        collection.collectionApartmentLocation.text = interestedApartmentList[indexPath.row].Location
        collection.collectionApartmentPrice.text = interestedApartmentList[indexPath.row].Rent
        collection.collectionApartmentRating.text = interestedApartmentList[indexPath.row].Ratings
        collection.layer.cornerRadius = 30.0
        return collection
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            if let detailView = segue.destination as? CollectionViewController {
                if let indexPaths = listedView.indexPathsForSelectedItems,
                   let indexPath = indexPaths.first{
                    detailView.apartmentsList = listedApartmentList[indexPath.row]
                }
            }
        }
        else if segue.identifier == "detailSegue1"{
            if let detailView = segue.destination as? CollectionViewController {
                if let indexPaths = interestedView.indexPathsForSelectedItems,
                   let indexPath = indexPaths.first{
                    detailView.apartmentsList = interestedApartmentList[indexPath.row]
                }
            }
        }
        
    }


}
