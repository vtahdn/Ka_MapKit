//
//  PathFind.swift
//  Ka_MapKit
//
//  Created by Viet Asc on 1/10/19.
//  Copyright © 2019 Viet Asc. All rights reserved.
//

import UIKit
import MapKit

class PathFind: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flag: UIImageView!
    
    var fromLocation: CLLocation?
    var locationManager: CLLocationManager?
    var overlay: MKOverlay?
    var direction: MKDirections?
    var foundPlace: CLPlacemark?
    var geoCoder: CLGeocoder?
    
    // Draw a tracking line on the map.
    lazy var show = { (_ response: MKDirections.Response) in
        
        for route in response.routes {
            self.overlay = route.polyline
            self.mapView.addOverlay(self.overlay!, level: .aboveRoads)
            for step in route.steps {
                print(step.instructions)
            }
        }
        
    }
    
    lazy var routePath = { (_ from: MKPlacemark, _ to: MKPlacemark) in
        
        let request = MKDirections.Request()
        let fromMapItem = MKMapItem(placemark: from)
        request.source = fromMapItem
        let toMapItem = MKMapItem(placemark: to)
        request.destination = toMapItem
        self.direction = MKDirections(request: request)
        self.direction?.calculate(completionHandler: { (response, error) in
            if error == nil {
                self.show(response!)
                self.flag.backgroundColor = .green
            } else {
                self.flag.backgroundColor = .black
            }
        })
        
    }
    
    lazy var address = { (_ string: String) in
        
        if string == "" {
            return
        }
        self.geoCoder?.geocodeAddressString(string, completionHandler: { (placemarks, error) in
            if error == nil {
                self.foundPlace = placemarks?.first
                let toPlace = MKPlacemark(placemark: self.foundPlace!)
                self.routePath(MKPlacemark(coordinate: self.fromLocation!.coordinate, addressDictionary: nil), toPlace)
            }
        })
        
    }
    
    lazy var region = { (_ scale: CGFloat) in
        
        let size: CGSize = self.mapView.bounds.size
        let region = MKCoordinateRegion(center: self.fromLocation!.coordinate, latitudinalMeters: Double(size.height * scale), longitudinalMeters: Double(size.width * scale))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        mapView.delegate = self
        edgesForExtendedLayout = []
        self.geoCoder = CLGeocoder()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }

}

extension PathFind: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .black
        render.lineWidth = 5.0
        return render
        
    }
    
}

extension PathFind: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locationManager?.stopUpdatingLocation()
        self.fromLocation = locations.last
        region(2)
        
    }
    
}

extension PathFind: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if overlay != nil {
            mapView.removeOverlay(overlay!)
        }
        address(textField.text!)
        return true
        
    }
    
}
