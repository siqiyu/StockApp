//
//  ViewController.swift
//  StockApp
//
//  Created by yusiqi on 3/5/23.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON
import RealmSwift

class ViewController: UIViewController {
     
     var txtField: UITextField?
     var stockSymbol = ""
     let realm = try! Realm()
     
     @IBOutlet weak var txtStockSymbol: UITextField!
     
     @IBOutlet weak var lblStockPrice: UILabel!
     override func viewDidLoad() {
        super.viewDidLoad()
          print(Realm.Configuration.defaultConfiguration.fileURL!)
          //addSampleValueInDB()
    }
     
//     func addSampleValueInDB(){
//          let tsla: StockPrice = StockPrice()
//          tsla.symbol = "TSLA"
//          tsla.price = 149.17
//          tsla.volume = 13435315
//
//          //Add to the Realm
//          do {
//              try realm.write {
//              realm.add(tsla, update: .modified)
//              }
//          } catch let error as NSError {
//              print("Unable to add values to the DB")
//          }
//     }

     @IBAction func getStockPrice(_ sender: Any) {
          guard let symbol = txtStockSymbol.text else {return}
          let url = "\(baseURL)\(symbol)?apikey=\(apiKey)"
          SwiftSpinner.show("Getting Stock price for \(symbol)")
          Alamofire.request(url).responseJSON{ response in
               SwiftSpinner.hide()
               if response.error != nil{
                    print("Error in response")
                    return
               }
               guard let rawData = response.data else {return}
               guard let jsonArray = JSON(rawData).array else {return}
               guard let stock = jsonArray.first else{return}
               //print(stock)
               let symbol = stock["symbol"].stringValue
               let price = stock["price"].doubleValue
               let volume = stock["volume"].intValue
               self.lblStockPrice.text = "Price = \(price) $"
          }
          
     }
    
    
    @IBAction func AddStockToDB(_ sender: Any) {
         let alertController = UIAlertController(title: "Add Stocks", message: "Type Stock Symbol", preferredStyle: .alert)
         
         let OKButton = UIAlertAction(title: "OK", style: .default){action in
              guard let symbol = self.txtField?.text else{return}
              if symbol == "" {return}
              self.findAndAddStocksToLocalDB(symbol: symbol.uppercased())
             
         }
         
         let cancelButton = UIAlertAction(title: "Cancel", style: .cancel){action in
         }
         
         alertController.addTextField{ lblTextField in
             self.txtField = lblTextField
             lblTextField.placeholder = "Type Stock Value"
         }
         
         alertController.addAction(OKButton)
         alertController.addAction(cancelButton)
         self.present(alertController, animated: true)
    }
    
     func findAndAddStocksToLocalDB(symbol : String){
          //if the stock already exists in the DB don't do anything
          //make a network call for the stock symbol
          //if the stock symbol exists then add it to DB
          //otherwise don't do anything
          if doesStockExistInDB(symbol){
               //since Stock has already existed, don't do anything
               return
          }
          getAndAddStockValue(symbol)
     }
     
     func getAndAddStockValue(_ symbol : String){
          let url = "\(baseURL)\(symbol)?apikey=\(apiKey)"
          SwiftSpinner.show("Getting Stock price for \(symbol)")
          Alamofire.request(url).responseJSON{ response in
               SwiftSpinner.hide()
               if response.error != nil{
                    print("Error in response")
                    return
               }
               guard let rawData = response.data else {return}
               guard let jsonArray = JSON(rawData).array else {return}
               guard let stock = jsonArray.first else{return}
               let symbol = stock["symbol"].stringValue
               let price = stock["price"].floatValue
               let volume = stock["volume"].int64Value
               print(symbol)
               print(price)
               print(volume)
               
               let newStock = StockPrice()
               newStock.symbol = symbol
               newStock.price = price
               newStock.volume = volume
               
               //Add to the Realm
               do {
                    try self.realm.write {
                         self.realm.add(newStock, update: .modified)
                   }
               } catch let error as NSError {
                    print("Unable to add values to the DB \(error)")
               }
    
          }
     }
     
     func doesStockExistInDB(_ symbol : String) -> Bool{
          let data = realm.object(ofType: StockPrice.self, forPrimaryKey: symbol)
          if data != nil{
               return true
          }else{
               return false
          }
     }
}

