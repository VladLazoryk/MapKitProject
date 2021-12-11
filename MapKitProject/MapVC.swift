//
//  MapVC.swift
//  MapKit
//
//  Created by vlad on 8/17/21.
//  Copyright © 2021 Vlad Lazoryk. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapVC: UIViewController {
    
    let addPlaceButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"addAdress"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"route"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let resetButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"reset"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let mapView : MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setConstraints()
        
        addPlaceButton.addTarget(self, action: #selector(addPlaceButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addPlaceButtonTapped() {
        alertAddPlace(name: "Добавить", placeholder: "Введите адрес") { [self] (text) in
            self.setupPlacemark(adressPlace: text)
        }
    }
    
    @objc private func routeButtonTapped() {
        
        for index in 0...annotationsArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc private func resetButtonTapped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }

    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.alertError(name: "Ошибка", message: "Маршрут недоступен")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
    
    private func setupPlacemark(adressPlace: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
            
            if let error = error {
                print(error)
                self.alertError(name: "Ошибка", message: "Сервер недоступен. Попробуйте добавить адрес еще раз")
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.annotationsArray.append(annotation)
            if self.annotationsArray.count > 2 {
                self.routeButton.isHidden = false
                self.resetButton.isHidden = false
            }
            self.mapView.showAnnotations(self.annotationsArray, animated: true)
        }
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
}

extension MapVC {
    
    func setConstraints() {
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addPlaceButton)
        NSLayoutConstraint.activate([
            addPlaceButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addPlaceButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addPlaceButton.heightAnchor.constraint(equalToConstant: 70),
            addPlaceButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
