import Foundation
import Alamofire
import SwiftKeychainWrapper
import Magic

/// Список уровней доступа
enum GithubScope: String {
  case user, gist
}

/// Основной синглтон для обработки авторизационных запросов
class GithubService {
  
  /// Страница авторизации
  static let authorizationURL: URL = URL(string: "https://github.com/login/oauth/authorize")!
  
  /// Так называемый Deeplink для редиректа обратно в приложение после авторизации
  static let redirectURL: URL = URL(string: "githubauth://login.page")!
  
  /// Страница для получения временного токена доступа
  static let accessTokenURL: URL = URL(string: "https://github.com/login/oauth/access_token")!
  
  
  /// Временные переменные для дальнейшей обработки
  private var clientID: String?
  private var clientSecret: String?
  private var accessToken: String? = KeychainWrapper.standard.string(forKey: "token")
  
  // Превращаем класс в Синглтон
  static let shared: GithubService = GithubService()
  private init() {}
  
  // Классовая функция для настройки параметров
  class func configure(clientID: String, clientSecret: String) {
    shared.clientID     = clientID
    shared.clientSecret = clientSecret
  }
  
  // MARK: Страница авторизации
  
  /// Запрос страницы авторизации
  func requestAuthorization(scopes: [GithubScope]) throws {
    guard
      let clientID = self.clientID,
      let _ = self.clientSecret
      else {
        throw NSError(domain: "Client ID/Client Secret not set", code: 1, userInfo: nil)
    }
    
    // Добавляем к строке запроса необходимые параметры
    let clientIDQuery             = URLQueryItem(name: "client_id", value: clientID)
    let redirectURLQuery          = URLQueryItem(name: "redirect_uri", value: GithubService.redirectURL.absoluteString)
    let scopeQuery: URLQueryItem  = URLQueryItem(name: "scope", value: scopes.compactMap { $0.rawValue }.joined(separator: " ") )
    
    
    var components          = URLComponents(url: GithubService.authorizationURL, resolvingAgainstBaseURL: true)
    components?.queryItems  = [clientIDQuery, redirectURLQuery, scopeQuery]
    
    UIApplication.shared.open(components!.url!, options: [:], completionHandler: nil)
  }
  
  // MARK: Получение токена
  
  /// Url, который мы получаем в этой функции должен выглядеть примерно так: githubauth://login.page?code=dsgwergdfbeee
  /// Нас интересует именно последняя часть
  func requestAuthToken(url: URL) {
    
    var accessCode: String = ""
    
    // 1. Создаём URLComponent
    // Парсим только то что нам нужно из полученной ранее ссылки
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
      
      // 2. Проверяем все ключи из ссылки
      for queryItem in components.queryItems! {
        
        // 3. Ищем параметр "code"
        if queryItem.name == "code" {
          accessCode = queryItem.value!
        }
      }
    }
    
    // Подгоавливаем ссылку на получение токена
    var request = URLRequest(url: GithubService.accessTokenURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    // Различные параметры
    let clientIDQuery     = URLQueryItem(name: "client_id", value: self.clientID!)
    let clientSecretQuery = URLQueryItem(name: "client_secret", value: self.clientSecret!)
    let codeQuery         = URLQueryItem(name: "code", value: accessCode)
    let redirectURIQuery  = URLQueryItem(name: "redirect_uri", value: GithubService.redirectURL.absoluteString)
    
    // Добавляем параметры к ссылке
    var components = URLComponents(string: GithubService.accessTokenURL.absoluteString)
    components?.queryItems = [clientIDQuery, clientSecretQuery, codeQuery, redirectURIQuery]
    
    request.url = components?.url
    
    // Запускаем процесс обмена данными
    
    let url = GithubService.accessTokenURL
    let params = [
      "client_id": self.clientID!,
      "client_secret": self.clientSecret!,
      "code": accessCode,
      "redirect_uri": GithubService.redirectURL.absoluteString
      ] as Parameters?
    
    let headers: HTTPHeaders = [
      "Accept": "application/json"
    ]
    
    
    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
      let responseJSON = response.result.value as! [String:Any]
      
      if KeychainWrapper.standard.string(forKey: "token") == nil {
        KeychainWrapper.standard.set((responseJSON["access_token"] as? String)!, forKey: "token")
      }
      
    }
    
  }
  
  /// Информация о пользователе
  func getUserInfo() {
    let url = "https://api.github.com/user"
    
    let params = ["access_token": GithubService.shared.accessToken!] as Parameters?
    
    Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
      if let data = response.result.value {
        magic(data)
      } else {
        magic("Error")
      }
    }
  }
  
  /// Список черновиков пользователя
  func getGists(completion: @escaping ([[String : Any]]) -> Void) {
    let url = "https://api.github.com/gists"
    
    let params = ["access_token": GithubService.shared.accessToken!] as Parameters?
    
    Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
      if let data = response.result.value {
        let responseJSON = data as! [[String : Any]]
        completion(responseJSON)
      } else {
        magic("Error")
      }
    }
  }
}
