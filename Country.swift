import Foundation
import CoreData

@objc(Country)
class Country: NSManagedObject {
    @NSManaged var isoCode: String
    @NSManaged var name: String
    @NSManaged var isSelected: Bool
    @NSManaged var imageName: String
    @NSManaged var latitude: String
    @NSManaged var longitude: String
}
