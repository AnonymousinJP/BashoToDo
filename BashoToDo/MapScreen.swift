//
//  MapScreen.swift
//  BashoToDo
//
//  Created by 櫻井絵理香 on 2024/04/05.
//

import SwiftUI

import MapKit
import CoreLocation //for getting current location

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var mapView = MKMapView() //
    @Published var region: MKCoordinateRegion!
    @Published var permissionDenied = false
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .denied:
            //Alert
            permissionDenied.toggle()
        case .notDetermined:
            //Requesting
            manager.requestWhenInUseAuthorization()
        default:()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

struct MapView: View {
    let locationManager = CLLocationManager()
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.011_665, longitude: 135.768_326),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    var body: some View {
        Map(
          coordinateRegion: $region,
          showsUserLocation: true,
          userTrackingMode: .constant(.follow)
        )
          .edgesIgnoringSafeArea(.all)
          .onAppear {
              locationManager.requestWhenInUseAuthorization()
          }
    }
}
struct MapScreen: View {
    @State private var searchAddress: String = ""
    @State var mapData = MapViewModel()
    @State var locationManager = CLLocationManager()
    var body: some View {
        ZStack(alignment: .top){
            MapView()
            //TextField("検索", text: $searchAddress, onEditingChanged: { _ in})
                //.textFieldStyle(.roundedBorder)
                //.padding()
        }
        .onAppear(perform: {
            locationManager.delegate = mapData
            
        })
    }
}


struct MapScreen_Previews: PreviewProvider {
    static var previews: some View {
        MapScreen()
    }
}

//#Preview {
//    MapScreen()
//}

