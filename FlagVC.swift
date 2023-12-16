import UIKit
import CoreData

class FlagCell: UICollectionViewCell {
    @IBOutlet weak var flagImageView: UIImageView!

    func configure(with country: Country) {
        // Configure the cell with the country data
        flagImageView.image = UIImage(named: country.imageName)
    }
}

class FlagVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var visitedCountries: [Country] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the collection view
        collectionView.dataSource = self
        collectionView.delegate = self

        // Fetch visited countries from Core Data
        fetchVisitedCountries()
    }

    func fetchVisitedCountries() {
        // Fetch visited countries from Core Data
        let fetchRequest: NSFetchRequest<Country> = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "isSelected == true")

        do {
            visitedCountries = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching visited countries: \(error)")
        }

        // Reload the collection view to display the fetched countries
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visitedCountries.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlagCell", for: indexPath) as? FlagCell else {
            fatalError("Unable to dequeue FlagCell")
        }

        let country = visitedCountries[indexPath.item]
        cell.configure(with: country)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust the size of each item as needed
        return CGSize(width: 100, height: 50)
    }

    // Other UICollectionViewDelegateFlowLayout methods...
}
