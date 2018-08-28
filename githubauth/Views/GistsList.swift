import UIKit
import SwiftKeychainWrapper
import Magic

class GistsList: UITableViewController {
  
  var gists: [[String : Any]] = [[:]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if (KeychainWrapper.standard.string(forKey: "token") != nil) {
      GithubService.shared.getGists { recievedGistsFromGithub in 
        self.gists = recievedGistsFromGithub
        self.tableView.reloadData()
      }
    }    
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.gists.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "gistCell", for: indexPath)
    
    cell.textLabel?.text        = self.gists[indexPath.row]["id"] as? String
    cell.detailTextLabel?.text  = self.gists[indexPath.row]["description"] as? String
    
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let gist = self.gists[indexPath.row]
    performSegue(withIdentifier: "toGistSegue", sender: gist)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if let destination = segue.destination as? GistScreen {
      
      if let selectedGist = sender as? [String : Any] {
        destination.gist = selectedGist
      }
      
    } 
  }
  
  
}
