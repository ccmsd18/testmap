import SwiftUI
import MapKit
//test
struct ContentView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.3352, longitude: -122.0096), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    private let startPoint = CLLocationCoordinate2D(latitude: 37.3352, longitude: -122.0096)
    private let endPoint = CLLocationCoordinate2D(latitude: 37.3524, longitude: -122.0411)
    
    var body: some View {
        MapView(region: $region, annotations: createAnnotations(), polyline: createPolyline())
    }
    
    private func createAnnotations() -> [CustomAnnotation] {
        let startAnnotation = CustomAnnotation(coordinate: startPoint, title: "Start Point", subtitle: "Subtitle for Start Point")
        let endAnnotation = CustomAnnotation(coordinate: endPoint, title: "End Point", subtitle: "Subtitle for End Point")
        return [startAnnotation, endAnnotation]
    }
    
    private func createPolyline() -> MKPolyline {
        let coordinates = [startPoint, endPoint]
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}

class CustomAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
   
    var annotations: [CustomAnnotation]
    var polyline: MKPolyline
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        // Add annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        
        // Add polyline
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyline)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? CustomAnnotation {
                let detailsView = AnnotationDetailsView(annotation: annotation)
                if let viewController = UIApplication.shared.windows.first?.rootViewController {
                    viewController.present(UIHostingController(rootView: detailsView), animated: true, completion: nil)
                }
            }
        }
    }
}

struct AnnotationDetailsView: View {
    let annotation: CustomAnnotation
    
    var body: some View {
        VStack {
            Text(annotation.title ?? "")
                .font(.title)
            Text(annotation.subtitle ?? "")
                .font(.subheadline)
            Text("Latitude: \(annotation.coordinate.latitude), Longitude: \(annotation.coordinate.longitude)")
                .font(.subheadline)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

