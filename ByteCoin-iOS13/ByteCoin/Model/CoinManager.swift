




import Foundation

protocol CoinManagerDelegate {
    

    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "6DED8909-1F64-4261-8679-91642B4CE7E6"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    
    func getCoinPrice(for currency: String) {
        
        //Use String concatenation to add the selected currency at the end of the baseURL along with the API key.
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        //Use optional binding to unwrap the URL that's created from the urlString
        if let url = URL(string: urlString) {
            
            //Create a new URLSession object with default configuration.
            let session = URLSession(configuration: .default)
            
            //Create a new data task for the URLSession
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                //Format the data we got back as a string to be able to print it.
                if  let dataAsString=data{
                    let bitcoinPrice = self.parseJSON(dataAsString)
                    let priceString = String(format: "%.2f", bitcoinPrice!)
                    
                    //Call the delegate method in the delegate (ViewController) and
                    //pass along the necessary data.
                    self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    
                }
            }
            //Start task to fetch data from bitcoin average's servers.
            task.resume()
        }
    }
    func parseJSON(_ currencyData:Data) -> Double?{
        
        let decoder=JSONDecoder()
        do {
            
            //try to decode the data using the CoinData structure
            let decodedData = try decoder.decode(CoinData.self, from: currencyData)
            
            //Get the last property from the decoded data.
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        }
}

