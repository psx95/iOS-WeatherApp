//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "02da265122dd181db14ec59347173df3"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var showTemperatureInCelcius: Bool = false

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData (url: String, parameters: [String : String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success !! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!) // if result is Success, the value will not be nil
                // This conversion to JSON is also provided by SwiftyJSON
                self.updateWeatherData(json: weatherJSON)
                self.updateUIWithWeatherData()
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        if let tempResult = json["main"]["temp"].double {
            // this is not through swift libraries, but throught SwiftJSON
            //temperatureLabel.text = tempResult - > This approach is wrong, rather use a Weather DataModel
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatheerIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        if showTemperatureInCelcius == false {
            print("Loading in Farenheight \(convertCelciusToFarenheight(celciusTemp: weatherDataModel.temperature))")
            temperatureLabel.text = "\(convertCelciusToFarenheight(celciusTemp: weatherDataModel.temperature))°F"
        } else {
            print("Loading in Celcius")
            temperatureLabel.text = "\(weatherDataModel.temperature)°C"
        }
        weatherIcon.image = UIImage(named: weatherDataModel.weatheerIconName)
    }
    
    func convertCelciusToFarenheight (celciusTemp : Int) -> Int {
        return Int(celciusTemp * (9/5) + 32)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Mehtods get activated once the location manager gets the location 
        // As we can see this method returns an array of location objects instead of a single location.
        // What this means is that the location gets refined overtime.  This implies that the location we receive at the end of this array is probably the most accurate
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            // location is valid. See quick help for info (command + click on horizontalAccuracy)
            locationManager.stopUpdatingLocation() // This takes some time, does not happen instantly
            locationManager.delegate = nil // this will prevent the ViewController from getting back the results, The stopUpdatingLocation may still take some time to complete
            print("Longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : lat, "lon" : lon, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // This methods activates when the location manager is unable to retrieve the error.
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredNewCityName(city: String, changeToCelcius: Bool) {
        let params : [String : String] = ["q":city, "appid": APP_ID]
        showTemperatureInCelcius = changeToCelcius
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        } 
    }
    
    
    
    
}


