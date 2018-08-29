import UIKit
import Magic

class GistScreen: UIViewController {
  
  @IBOutlet weak var gistIdLabel: UILabel!
  
  var gist: [String : Any] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    
    filesOfGist(recievedGist: gist)
    
    
  }
  
  /// Обработка полученных данных о конкретном Gist
  func filesOfGist(recievedGist: [String : Any]) -> [String : String]{
    
    /// Обработанный список файлов из Gist
    var gistFiles: [String : String] = [:]
    
    // Перебираю все пары ключей и значений из необработанного Gist (кортэж)
    for pairs in recievedGist {
      
      // Если в кортеже встречается ключ "files", то его и обрабатываем
      if pairs.key == "files" {
        
        /// Все данные касаемо файлов внутри Gist (чаще всего это один файл)
        let files = pairs.value as? [String : Any]
        
        magic(files)
        
        let some = files?.first?.value as? [String : Any]
        
        
        
        
        for another in some! {
          if another.key == "filename" {
            gistFiles["filename"] = another.value as? String
          } else if another.key == "raw_url" {
            gistFiles["rawValue"] = another.value as? String
          }
          
        }
        
        
        
        
        
        
      }
    }
    
    return gistFiles
    
  }
}
