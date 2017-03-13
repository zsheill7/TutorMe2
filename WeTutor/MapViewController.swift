

import UIKit
import MapKit
import SCLAlertView

class MapViewController: UIViewController {

    var locationToShow: CLLocationCoordinate2D!

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var segmentedControl:UISegmentedControl!
    
    var currentRoute:MKRoute?
    let locationManager = CLLocationManager()
    var currentPlacemark:CLPlacemark?
    var currentTransportType = MKDirectionsTransportType.automobile


    
    func displayAlert(_ title: String, message: String) {
        SCLAlertView().showInfo(title, subTitle: message)
        
    }

  override func viewDidLoad() {
    super.viewDidLoad()

    segmentedControl.isHidden = true
    segmentedControl.addTarget(self, action: #selector(showDirection), for: .valueChanged)
    
    // Request for a user's authorization for location services
    locationManager.requestWhenInUseAuthorization()
    let status = CLLocationManager.authorizationStatus()
    
    if status == CLAuthorizationStatus.authorizedWhenInUse {
        print("authorized")
        mapView.showsUserLocation = true
    }
    
    if locationToShow != nil {

        mapView.setCenter(locationToShow, animated: true)
    } else {
        //self.displayAlert(title: "", message: "This address may not be ")
        print("location to show = nil")
    }

    let zoomRegion = MKCoordinateRegionMakeWithDistance(locationToShow, 15000, 15000)
    mapView.setRegion(zoomRegion, animated: true)

    let annotation = MKPointAnnotation()
    annotation.coordinate = locationToShow
    mapView.addAnnotation(annotation)
  }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
       // leftIconView.image = UIImage(named: restaurant.image)
        annotationView?.leftCalloutAccessoryView = leftIconView
        
        // Pin color customization
        if #available(iOS 9.0, *) {
            annotationView?.pinTintColor = UIColor.orange
        }
        
        annotationView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        
        return annotationView
    }
    
    @IBAction func showDirection(_ sender: Any) {
    
        print("inside showDirection")
        switch segmentedControl.selectedSegmentIndex {
        case 0: currentTransportType = MKDirectionsTransportType.automobile
        case 1: currentTransportType = MKDirectionsTransportType.walking
        default: break
        }
        
        segmentedControl.isHidden = false
        
        guard let currentPlacemark = currentPlacemark else {
            return
        }
        
        let directionRequest = MKDirectionsRequest()
        
        // Set the source and destination of the route
        directionRequest.source = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = currentTransportType
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (routeResponse, routeError) -> Void in
            
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                return
            }
            
            let route = routeResponse.routes[0]
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            print("in map")
        }
        
        directionRequest.transportType = MKDirectionsTransportType.automobile
        directionRequest.transportType = currentTransportType
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor.blue : UIColor.orange
        renderer.lineWidth = 3.0
        
        return renderer
    }

  @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
}