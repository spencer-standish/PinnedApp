//
//  PrivacyPolicyVC.swift
//  PinnedApp
//
//  Created by Spencer Standish on 2023-12-11.
//

import UIKit

class PrivacyPolicyVC: UIViewController {

    @IBOutlet weak var PrivacyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the UITextView to not be editable
        PrivacyTextView.isEditable = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
