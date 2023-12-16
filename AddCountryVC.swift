import UIKit
import CoreData

class AddCountryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)

    var countries: [Country] = [] // Load from Core Data
    var filteredCountries: [Country] = []
    var selectedCountries: [Country] = []

    // Inject the Core Data manager
    let coreDataManager = CoreDataManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Make the search bar visible by default
        navigationItem.hidesSearchBarWhenScrolling = false

        // Set up the table view
        tableView.dataSource = self
        tableView.delegate = self

        // Load countries from Core Data
        fetchCountries()
    }

    // Fetch countries from Core Data
    func fetchCountries() {
        let fetchRequest: NSFetchRequest<Country> = NSFetchRequest(entityName: "Country")

        do {
            countries = try coreDataManager.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching countries: \(error)")
        }
    }

    // MARK: - IBActions

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Handle saving logic here
        // Update the isSelected and imageName attributes in Core Data for selected countries
        for country in selectedCountries {
            updateSelectedStatusForCountry(isSelected: true, isoCode: country.isoCode)
        }

        // Display a pop-up message
        let alertController = UIAlertController(title: "Save Successful", message: "Your visited countries have been saved.", preferredStyle: .alert)

//        // Add an OK button to dismiss the alert
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        // Add a "Go to VisitedVC" button to navigate to the VisitedVC
        let goToWorldVCAction = UIAlertAction(title: "Go to World View", style: .default) { _ in
            // Navigate to VisitedVC
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
       
//            vc?.fetchSelectedCountries()
            self.navigationController?.pushViewController(vc!, animated: true)

        }

//        alertController.addAction(okAction)
        alertController.addAction(goToWorldVCAction)

        // Present the alert
        present(alertController, animated: true, completion: nil)
    }

    func determineImageName(for country: Country) -> String {
        // Implement logic to determine the image name for a country
        // You can use the isoCode or any other property to derive the image name
        return country.isoCode.lowercased()
    }
    
    func updateSelectedStatusForCountry(isSelected: Bool, isoCode: String) {
        let fetchRequest: NSFetchRequest<Country> = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "isoCode == %@", isoCode)
        
        do {
            let existingCountries = try coreDataManager.managedObjectContext.fetch(fetchRequest)
            
            if let existingCountry = existingCountries.first {
                // Update isSelected property for the existing country
                existingCountry.isSelected = isSelected
                try coreDataManager.managedObjectContext.save()
            } else {
                // Country with the specified ISO code not found
                print("Country with ISO code \(isoCode) not found.")
            }
        } catch {
            print("Error updating isSelected status: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource

extension AddCountryVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredCountries.count : countries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)

        let country: Country = isFiltering() ? filteredCountries[indexPath.row] : countries[indexPath.row]

        cell.textLabel?.text = country.name

        // Display image in cell and add ability to resize it
        if let resizedImage = UIImage(named: country.imageName)?.resized(to: CGSize(width: 50, height: 30)) {
            cell.imageView?.image = resizedImage
        }

        // Set the checkmark accessory type based on the selection state
        cell.accessoryType = selectedCountries.contains(country) ? .checkmark : .none

        return cell
    }

}

// MARK: - UITableViewDelegate

extension AddCountryVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let country: Country = isFiltering() ? filteredCountries[indexPath.row] : countries[indexPath.row]

        if let index = selectedCountries.firstIndex(of: country) {
            selectedCountries.remove(at: index)
        } else {
            selectedCountries.append(country)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - UISearchResultsUpdating

extension AddCountryVC: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    func filterContentForSearchText(_ searchText: String) {
        filteredCountries = countries.filter { country in
            return country.name.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

}

// extension added to resize and customize a UIImage
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
