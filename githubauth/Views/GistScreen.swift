import UIKit
import Magic

class GistScreen: UIViewController {
  
  @IBOutlet weak var gistIdLabel: UILabel!
  
  var gist: [String : Any] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    magic(gist["files"])
    gistIdLabel.text = String("ID: \(String(describing: gist["id"]!))")
  }
}
