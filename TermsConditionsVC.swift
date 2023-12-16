import UIKit

class TermsConditionsVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var termsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the UITextView to not be editable
        termsTextView.isEditable = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Adjust content size of the scrollView to fit the termsTextView
        scrollView.contentSize = CGSize(width: view.bounds.width, height: termsTextView.frame.maxY)
    }
    

}
