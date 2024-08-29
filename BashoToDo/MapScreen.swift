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
    
    @Published var center_: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var mapRegion_: MKCoordinateRegion =  MKCoordinateRegion()
    
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
                
                self.center_ = .init()
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
        
        center_ = CLLocationCoordinate2D()
        mapRegion_ = MKCoordinateRegion()

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
                    
                    self.center_ = CLLocationCoordinate2D(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
                    self.mapRegion_ = MKCoordinateRegion(center: self.center_, latitudinalMeters: 200, longitudinalMeters: 200)
                }
            }
        }
    }
    
    struct MapView: UIViewRepresentable {
        @Binding var center_coord: CLLocationCoordinate2D
        @Binding var scale: Double
        static var prePosition: CLLocationCoordinate2D?

        //ユーザー現在地
        func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
            let view = MKMapView(frame: .zero)
            view.delegate = context.coordinator
            view.showsUserLocation = true
            MapView.self.prePosition = self.center_coord
            return view
        }

        func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
            //ピン追加
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.center_coord
            annotation.title = "pin"
            uiView.addAnnotation(annotation)

            //Region指定
            let span = MKCoordinateSpan(latitudeDelta:self.scale, longitudeDelta:self.scale)
            let region = MKCoordinateRegion(center:self.center_coord, span:span)
            uiView.setRegion(region, animated:true)

            MapView.self.prePosition = self.center_coord
        }

        func makeCoordinator() -> MapView.Coordinator {
            return MapView.Coordinator(parent: self)
        }

        class Coordinator: NSObject, MKMapViewDelegate {
            var parent : MapView!
            init(parent: MapView){
                self.parent = parent
            }

            //annoattionタップ時メソッド(現在は未設定)
            func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            }

            //addOverlay時メソッド
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                if let polyline = overlay as? MKPolyline {
                    let polylineRenderer = MKPolylineRenderer(polyline: polyline)
                    polylineRenderer.strokeColor = .red
                    polylineRenderer.lineWidth = 2.0
                    return polylineRenderer
                }
                return MKOverlayRenderer()
            }
        }
    }

    struct SearchBar: View {
        @StateObject var viewModel = ViewModel()
        @State var locationManager = CLLocationManager()
        @State var scale: Double = 0.2

        //@State var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:35.658577, longitude:139.745451)
        // 移動先の座標
        /*var locations: [CLLocationCoordinate2D] {
            return [viewModel.center_, viewModel.center_, viewModel.center_]
        }*/

        var body: some View {
            ZStack(alignment:.top){
                TextField("検索", text: $viewModel.location)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.location) { newValue in
                        viewModel.onSearchLocation()
                    }
            }
            MapView(center_coord:$viewModel.center_, scale:self.$scale)

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
                        self.move_location()
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
        func move_location(){
            /*DispatchQueue.global(qos: .utility).async{
                for (i, loc) in self.locations.enumerated(){
                    // scaleが0.2 → 0.1になるよう遷移
                    self.scale = 0.2 - Double(i+1) * (0.2 - 0.1) / Double(self.locations.count)
                    self.location = loc
                    Thread.sleep(forTimeInterval: 1.0)
                }
            }*/
        }
    }
}

struct MapScreen: View {
    var body: some View {
        ViewModel.SearchBar()
        //MapView()
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

 /*@State private var region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 35.011_665, longitude: 135.768_326),
         span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
 )*/
 
/*
struct MapView: View {
    @StateObject var viewModel = ViewModel()
    @StateObject var currentView = CurrentView()
    var body: some View {
        Map(
            coordinateRegion: .constant(currentView.region),
          showsUserLocation: true,
          userTrackingMode: .constant(.follow)
        )
          .edgesIgnoringSafeArea(.all)
          .onAppear {
              currentView.locationManager.requestWhenInUseAuthorization()
          }
    }
}
*/
// LocationDataManager
/*class CurrentView : NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion()

    @Published var centre = CLLocationCoordinate2D()
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3.0
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //code to handle location updates
        locations.last.map {
            /*現在の座標*/
            let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            region = MKCoordinateRegion(center: center, span: span)

            //centre = CLLocationCoordinate2DMake($0.coordinate.latitude, $0.coordinate.longitude)
            centre = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}*/

/*
struct MapView: UIViewRepresentable {
    @Binding var center_coord: CLLocationCoordinate2D
    @Binding var scale: Double
    static var prePosition: CLLocationCoordinate2D?

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let view = MKMapView(frame: .zero)
        view.delegate = context.coordinator
        view.showsUserLocation = true
        MapView.self.prePosition = self.center_coord
        return view
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        // ピンの追加
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.center_coord
        annotation.title = "Wow"
        uiView.addAnnotation(annotation)

        // 直線の描画
        let coordinates = [MapView.self.prePosition! , self.center_coord]
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        uiView.addOverlay(polyLine)

        // Regionの指定
        let span = MKCoordinateSpan(latitudeDelta:self.scale, longitudeDelta:self.scale)
        let region = MKCoordinateRegion(center:self.center_coord, span:span)
        uiView.setRegion(region, animated:true)

        MapView.self.prePosition = self.center_coord
    }

    func makeCoordinator() -> MapView.Coordinator {
        return MapView.Coordinator(parent: self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {

        var parent : MapView!
        init(parent: MapView){
            self.parent = parent
        }

        // annoattionタップ時のメソッド(現在は未設定)
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        }

        // addOverlay時のメソッド
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let polylineRenderer = MKPolylineRenderer(polyline: polyline)
                polylineRenderer.strokeColor = .red
                polylineRenderer.lineWidth = 2.0
                return polylineRenderer
            }
            return MKOverlayRenderer()
        }
    }
}


struct SearchBar: View {
    @StateObject var viewModel = ViewModel()
    @State var locationManager = CLLocationManager()
    
    //@StateObject var currentView = CurrentView()

    @State var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:35.658577, longitude:139.745451)
    @State var scale: Double = 0.2
    // 移動する地点の座標
    var locations: [CLLocationCoordinate2D]
        = [CLLocationCoordinate2D(latitude:35.658577, longitude:139.695451),
            CLLocationCoordinate2D(latitude:35.658577, longitude:139.645451),
            CLLocationCoordinate2D(latitude:35.658577, longitude:139.595451)]

    var body: some View {
        ZStack(alignment:.top){
            TextField("検索", text: $viewModel.location)
                .textFieldStyle(.roundedBorder)
                .onChange(of: viewModel.location) { newValue in
                    viewModel.onSearchLocation()
                }
        }
        MapView(center_coord:self.$location, scale:self.$scale)

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
                    self.move_location()
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
    func move_location(){}
}*/

