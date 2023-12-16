import UIKit
import MapKit
import CoreData

class WorldVC: UIViewController {
    
    @IBOutlet weak var worldView: MKMapView!
    
    var selectedCountries: [Country] = []
    
    let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        updateMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch selected countries from Core Data
        fetchSelectedCountries()
        updateMapView()
    }
    
    func fetchSelectedCountries() {
        let fetchRequest: NSFetchRequest<Country> = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "isSelected == true")
        
        do {
            selectedCountries = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching selected countries: \(error)")
        }
    }
    
    func updateMapView() {
        worldView.removeAnnotations(worldView.annotations)
        for selectedCountry in selectedCountries {
            let selectedCountryMKAnnotation = CountryMKAnnotation(title: selectedCountry.name, coordinate: CLLocationCoordinate2D(latitude: Double(selectedCountry.latitude)!, longitude: Double(selectedCountry.longitude)!), info: selectedCountry.isoCode)
            worldView.addAnnotation(selectedCountryMKAnnotation)
        }
    }
}
