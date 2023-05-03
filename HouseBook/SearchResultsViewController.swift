//
//  SearchResultsViewController.swift
//  HouseBook
//
//  Created by Ujjwal Adhikari on 4/16/23.
//

import UIKit
import CoreLocation
import Alamofire
import AlamofireImage
import Nuke

class SearchResultsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lab: UILabel!
    
    @IBOutlet weak var searchTable: UITableView!
    
    var searchQuery: String?
    var apartmentsList: [ApartmentsList]!
    var nearestApartmentsList:[ApartmentsList] = []
    
    private var imageDataRequest: DataRequest?
    
    func getLatLong(address: String, completion: @escaping (CLLocationCoordinate2D?) -> ()) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemark = placemarks?.first {
                completion(placemark.location?.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    //    function that takes in a zip code and returns a CLLocationCoordinate2D:
    func getCoordinates(forZipCode zipCode: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(location)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let searchQuery = searchQuery{
            print("Search", searchQuery, apartmentsList)
            lab.text = "Search Results for: "+searchQuery
        }
        getCoordinates(forZipCode: searchQuery!) { [weak self] (zipCoordinates) in
            guard let zipCoordinates = zipCoordinates else { return }
            
            var apartmentDistances: [ApartmentsList: Double] = [:]
            
            let dispatchGroup = DispatchGroup()
            
            for apartment in self!.apartmentsList {
                guard let apartmentAddress = apartment.Location else { continue }
                
                dispatchGroup.enter()
                
                self!.getLatLong(address: apartmentAddress) { [weak self] (apartmentCoordinates) in
                    
                    defer {dispatchGroup.leave()}
                    
                    guard let apartmentCoordinates = apartmentCoordinates else { return }
                    
                    let distance = self?.getDistance(fromCoordinate: zipCoordinates, toCoordinate: apartmentCoordinates) ?? 0
                    
                    apartmentDistances[apartment] = distance
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                
                let sortedDistances = apartmentDistances.sorted { $0.value < $1.value }
                let nearestApartments = Array(sortedDistances.prefix(10))
                
                print("Nearest Apartments:", nearestApartments)
                for apartmentList in nearestApartments{
                    self!.nearestApartmentsList.append(apartmentList.0)
                }
                self!.searchTable.dataSource = self
                self!.searchTable.delegate = self
                self!.searchTable.reloadData()
            }
        
        }
        
//        searchTable.dataSource = self
//        searchTable.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearestApartmentsList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"apartmentTable", for: indexPath) as! ApartmentTableViewCell
        if nearestApartmentsList[indexPath.row].Photos == nil{
            let photo = nearestApartmentsList[indexPath.row].userUploadPhoto?[0]
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
            let photo = nearestApartmentsList[indexPath.row].Photos?[0]
            Nuke.loadImage(with: URL(string: photo!)!, into: cell.apartmentImage)
        }
//        let photo = photos[indexPath.row]
//        Nuke.loadImage(with: URL(string: photo)!, into: cell.apartmentImage)
        cell.tableApartmentName.text = nearestApartmentsList[indexPath.row].Name
        cell.tableApartmentLocation.text = nearestApartmentsList[indexPath.row].Location
        cell.tableApartmentHousingType.text = nearestApartmentsList[indexPath.row].RoomType
        cell.tableApartmentPrice.text = nearestApartmentsList[indexPath.row].Rent
        cell.tableApartmentRatings.text = nearestApartmentsList[indexPath.row].Ratings
        
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 3
        cell.apartmentImage.layer.cornerRadius = 30.0
        cell.layer.cornerRadius = 30.0

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue1"{
            if let detailView = segue.destination as? CollectionViewController {
                if let indexPaths = searchTable.indexPathsForSelectedRows,
                   let indexPath = indexPaths.first{
                    detailView.apartmentsList = nearestApartmentsList[indexPath.row]
                }
            }
        }
    }
    
//    Calculate the distance between two locations using the Haversine formula:
    func getDistance(fromCoordinate from: CLLocationCoordinate2D, toCoordinate to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
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
