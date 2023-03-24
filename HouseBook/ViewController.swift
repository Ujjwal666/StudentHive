//
//  ViewController.swift
//  HouseBook
//
//  Created by Ujjwal Adhikari on 3/21/23.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var searchTextLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [String]()
    var apartmentsList = [ApartmentsList]()
    var searchText:String?
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            render(location)
        }
    }
    
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
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "user"
        mapView.addAnnotation(pin)
        
        
    }
    
    private func queryApartments(){
        let query = ApartmentsList.query()
        query.find { [weak self] result in
            switch result {
            case . success(let apartmentsList):
                self?.apartmentsList = apartmentsList
                print("GotIt ", self?.apartmentsList)
                for apartment in self!.apartmentsList{
                    let annotation = MKPointAnnotation()
                    self!.getLatLong(address: apartment.Location!) { [self] (coordinate) in
                        if let coordinate = coordinate {
//                            print("Location", apartment.Location!)
//                            print("Latitude: \(coordinate.latitude)")
//                            print("Longitude: \(coordinate.longitude)")
//                            mapView.delegate
                            let loc = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                            mapView.delegate = self
                            annotation.coordinate = loc
                            annotation.title = apartment.objectId!
//                            if let annotationView = self!.mapView.view(for: annotation) as? MKPinAnnotationView {
//                                annotationView.pinTintColor = .blue // set the pin color to red
//                            }

                            self!.mapView.addAnnotation(annotation)
                        }
                    }
                }
            case .failure(let error):
                print("Error while loading the data, ",error)
            }
        }
    }
    
    @objc(mapView:viewForAnnotation:) func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        }
        else {
            annotationView?.annotation = annotation
        }
        switch annotation.title {
        case "user":
            let pinImage = UIImage(named: "user")
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()

            annotationView?.image = resizedImage
        default:
            // Resize image
            let pinImage = UIImage(named: "home")
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()

            annotationView?.image = resizedImage

//            annotationView?.image = UIImage(named: "home")
            
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("clicked",view.annotation?.title)
        guard let annotation = view.annotation, let objectID = annotation.title else {
            return
        }
        performSegue(withIdentifier: "mapSegue", sender: objectID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailView = segue.destination as? CollectionViewController, let objectID = sender as? String {
            for apartment in self.apartmentsList{
                if apartment.objectId == objectID{
                    detailView.apartmentsList = apartment
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchTextLabel.text = "Search results for:  "+searchText
            // Do something with the search text
            self.searchText = searchText
            
//            print("Search text: \(searchText)")
            for item in self.apartmentsList {
                self.locations.append(item.Location!)
            }
            print("location", self.locations)

            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchText) { (postalCodePlacemarks, error) in
                guard let postalCodeLocation = postalCodePlacemarks?.first?.location else {
                    // Handle error
                    return
                }

                let maxDistance: CLLocationDistance = 10 * 1609.34 // 10 miles in meters
                
                for locationString in self.locations {
                    geocoder.geocodeAddressString(locationString) { (locationPlacemarks, error) in
                        guard let location = locationPlacemarks?.first?.location else {
                            // Handle error
                            return
                        }
                        
                        let distance = location.distance(from: postalCodeLocation)
                        if distance <= maxDistance {
                            // This location is within the 10-mile radius
                            print(locationString)
                        }
                    }
                }
            }

        }
    }

}

