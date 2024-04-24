//
//  MapScreen.swift
//  BashoToDo
//
//  Created by 櫻井絵理香 on 2024/04/05.
//

import SwiftUI
import MapKit
import CoreLocation //for getting current location

class ViewModel : NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var completer = MKLocalSearchCompleter()
    @Published var location = ""
    @Published var searchQuery = ""
    @Published var completions: [MKLocalSearchCompletion] = []
    @Published var locationDetail = ""
    
    override init(){
        super.init()
        completer.delegate = self /*initialization*/
        completer.resultTypes = .pointOfInterest /*only point*/
    }
    func onSearchLocation() {
        if searchQuery == location {
            completions = []
            return
        }
        
        searchQuery = location
        
        if searchQuery.isEmpty {
            completions = []
        }
        else {
            if completer.queryFragment != searchQuery {
                completer.queryFragment = searchQuery
            }
        }
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            if self.searchQuery.isEmpty {
                self.completions = .init()
            }
            else {
                self.completions = completer.results
            }
        }
    }
    func onLocationTap(_ completion:MKLocalSearchCompletion){
        DispatchQueue.main.async {
            self.location = completion.title
            self.searchQuery = self.location

            self.onSearch()
        }
    }
    func onSearch(){
        completions = []
        locationDetail = ""
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = self.location
        
        MKLocalSearch(request: request).start { (response, error) in
            if let error = error {
                print("MKLocalSearch Error:\(error)")
                return
            }
            if let mapItem = response?.mapItems.first {
                DispatchQueue.main.async {
                    self.locationDetail += "\n経度" + String(mapItem.placemark.coordinate.longitude)
                    self.locationDetail += "\n緯度" + String(mapItem.placemark.coordinate.latitude)
                }
            }
        }
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

struct SearchBar: View {
    @StateObject var viewModel = ViewModel()
    @State var locationManager = CLLocationManager()
    var body: some View {
        ZStack(alignment:.top){
            TextField("検索", text: $viewModel.location)
                .textFieldStyle(.roundedBorder)
                .onChange(of: viewModel.location) { newValue in
                    viewModel.onSearchLocation()
                }
        }
        if viewModel.completions.count > 0 {
            List(viewModel.completions, id: \.self) { completion in
                HStack{
                    VStack(alignment: .leading){
                        Text(completion.title)
                        Text(completion.subtitle)
                            .foregroundColor(Color.primary.opacity(0.5))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.onLocationTap(completion)
                }
            }
        }
        else {
            HStack {
                Text(viewModel.locationDetail)
                Spacer()
            }
        }
    }
}

struct MapScreen: View {
    var body: some View {
        SearchBar()
        MapView()
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


