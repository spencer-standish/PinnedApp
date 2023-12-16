import UIKit
import MapKit
import CoreData

class VisitedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var visitedCountriesTableView: UITableView!
    
    var selectedCountries: [Country] = []
    
    // Inject the Core Data manager
    let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visitedCountriesTableView.dataSource = self
        visitedCountriesTableView.delegate = self // Set the delegate for swipe-to-delete functionality
        
        // Reload the table view to display the stored countries
        visitedCountriesTableView.reloadData()
        
        // Update the stats label initially
        updateStatsLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set up the initial region to show the whole world
        let worldRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 180.0, longitudeDelta: 180.0)
        )
        mapView.setRegion(worldRegion, animated: false)
        
        for selectedCountry in selectedCountries {
            let selectedCountryMKAnnotation = CountryMKAnnotation(title: selectedCountry.name, coordinate: CLLocationCoordinate2D(latitude: Double(selectedCountry.latitude)!, longitude: Double(selectedCountry.longitude)!), info: selectedCountry.isoCode)
            mapView.addAnnotation(selectedCountryMKAnnotation)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch selected countries from Core Data
        fetchSelectedCountries()
    }
    
    // Fetch selected countries from Core Data
    func fetchSelectedCountries() {
        let fetchRequest: NSFetchRequest<Country> = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "isSelected == true")
        
        do {
            selectedCountries = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching selected countries: \(error)")
        }
        
        // Reload the table view to display the fetched countries
        visitedCountriesTableView.reloadData()
    }
    
    // method to update the stats label
    func updateStatsLabel() {
        let totalCountriesCount =  countryData.count

        // Calculate the number of visited countries
        let visitedCount = self.selectedCountries.count

        // Update the stats label with the visited count and percentage
        self.statsLabel.text = "\(visitedCount)/\(totalCountriesCount) countries visited (\(calculatePercentage(visitedCount, totalCountriesCount))% of the world)"
    }
    
    // method to calculate the percentage
    func calculatePercentage(_ numerator: Int, _ denominator: Int) -> Int {
        guard denominator != 0 else {
            return 0 // Avoid division by zero
        }

        return Int(Double(numerator) / Double(denominator) * 100)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisitedCountryCell", for: indexPath)
        
        let country = selectedCountries[indexPath.row]
        cell.textLabel?.text = country.name
        
        // Display image in cell and add ability to resize it
        if let resizedImage = UIImage(named: country.imageName)?.resized(to: CGSize(width: 50, height: 30)) {
            cell.imageView?.image = resizedImage
        }
        
        updateStatsLabel()
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Perform your delete operation here

            // Remove the country from the selectedCountries array
            let deletedCountry = selectedCountries.remove(at: indexPath.row)
            deleteCountryFromMKAnnotations(isoCode: deletedCountry.isoCode)
            // Delete the corresponding data from Core Data
            deleteCountryFromCoreData(isoCode: deletedCountry.isoCode)

            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)

            
            
           
            // update stats label after deleting a country
            updateStatsLabel()
        }
    }

    func deleteCountryFromCoreData(isoCode: String) {
        let fetchRequest: NSFetchRequest<Country> = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "isoCode == %@", isoCode)

        do {
            let existingCountries = try coreDataManager.managedObjectContext.fetch(fetchRequest)

            if let existingCountry = existingCountries.first {
                // Mark the country as not selected instead of deleting it
                existingCountry.isSelected = false
                try coreDataManager.managedObjectContext.save()
            } else {
                // Country with the specified ISO code not found
                print("Country with ISO code \(isoCode) not found.")
            }
        } catch {
            print("Error deleting country from Core Data: \(error)")
        }
    }
    
    func deleteCountryFromMKAnnotations(isoCode: String) {
        let fetchRequest: NSFetchRequest<Country> = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "isoCode == %@", isoCode)
        
        do {
            let existingCountries = try coreDataManager.managedObjectContext.fetch(fetchRequest)
            
            if let existingCountry = existingCountries.first {
                // Delete the country from Core Data
                for annotation in self.mapView.annotations {
                   
                   
                    if annotation.title == existingCountry.name {
                       
                        DispatchQueue.main.async {
                            self.mapView.removeAnnotation(annotation)
                        }
                        
                    }
                }
          
            } else {
                // Country with the specified ISO code not found
                print("Country with ISO code \(isoCode) not found.")
            }
        } catch {
            print("Error deleting country from Core Data: \(error)")
        }
    }
    // Other methods...
    
}
