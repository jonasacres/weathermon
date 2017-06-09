//
//  AppDelegate.swift
//  weathermon
//
//  Created by jonas on 5/12/17.
//  Copyright © 2017 jonas. All rights reserved.
//

// I do not know Swift. At all. I cobbled this together out of random googling. Please don't judge me for not knowing how ! and ? and unwrapping and optionals and whatever other Swift voodoo works. I JUST WANTED TO SEE MY DAMN WEATHER, OK

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength:125)
    let temperatureMenuItem = NSMenuItem(title: "?F", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let windMenuItem = NSMenuItem(title: "?mph ?", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let barometerMenuItem = NSMenuItem(title: "? inHg", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let humidityMenuItem = NSMenuItem(title: "?% humidity", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let dewpointMenuItem = NSMenuItem(title: "?F dewpoint", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let rainfallMenuItem = NSMenuItem(title: "?\" rainfall", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let dailyRainfallMenuItem = NSMenuItem(title: "?\" today", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let photoResistorMenuItem = NSMenuItem(title: "?V photo", action: #selector(pickItem(sender:)), keyEquivalent:"")
    let solarOutputMenuItem = NSMenuItem(title: "?V ?mW solar", action: #selector(pickItem(sender:)), keyEquivalent:"")
    
    var activeItem: NSMenuItem!;
    
    func pickItem(sender:NSMenuItem) {
        activeItem = sender;
        updateMenuLabel();
    }
    
    func updateMenuLabel() {
        statusItem.button?.title = activeItem.title
    }
    
    func convertToDirection(degrees:Int) -> String {
        let names = [ "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" ]
        let index = ((Double(degrees) + 360/(2*16)).truncatingRemainder(dividingBy:360)) / (360/16)
        
        return names[Int(index)]
    }
    
    @objc func getUpdate() {
        Timer.scheduledTimer(timeInterval:15, target: self, selector: #selector(self.getUpdate), userInfo: nil, repeats: false)

        getWeatherUpdate()
        getSolarUpdate()
    }
    
    func getWeatherUpdate() {
        let url = URL(string: "http://owl.lyratarium.com:11000/sensor-00002116")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            if let parsed = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let info = parsed as? [String: Any] {
                    self.updateWeatherData(info:info)
                }
            }
        }
        
        task.resume()
    }
    
    func getSolarUpdate() {
        let url = URL(string: "http://owl.lyratarium.com:11000/solar-sensors")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            if let parsed = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let info = parsed as? [String: Any] {
                    self.updateSolarData(info:info)
                }
            }
        }
        
        task.resume()
    }
    
    func setTemperature(temp:String) {
        temperatureMenuItem.title = temp + "F"
    }
    
    func setWindTemp(speed:String, direction:Int, temp:String) {
        windMenuItem.title = speed + "mph " + convertToDirection(degrees: direction) + " " + temp + "F"
    }
    
    func setBarometer(baromin:String) {
        barometerMenuItem.title = baromin + " inHg"
    }
    
    func setHumidity(humidity:String) {
        humidityMenuItem.title = humidity + "% humidity"
    }
    
    func setDewpoint(dewpoint:String) {
        dewpointMenuItem.title = "Dewpoint: " + dewpoint + "F"
    }
    
    func setRainfall(rainfall:String) {
        rainfallMenuItem.title = rainfall + "\" rainfall"
    }
    
    func setDailyRainfall(dailyRainfall:String) {
        dailyRainfallMenuItem.title = dailyRainfall + "\" today"
    }
    
    func setPhotoResistor(photoResistorVoltage:Float) {
        photoResistorMenuItem.title = photoResistorVoltage.description + "V photo"
    }
    
    func setSolarOutput(solarVoltage:Float, solarWattage:Float) {
        solarOutputMenuItem.title = solarVoltage.description + "V " + solarWattage.description + "mW solar"
    }
    
    func updateWeatherData(info:[String: Any]) {
        if let temp = info["tempf"] as? String {
            setTemperature(temp: temp)
        }
        
        if let speed = info["windspeedmph"] as? String, let directionStr = info["winddir"] as? String, let temp = info["tempf"] as? String {
            if let direction = Int(directionStr)  {
                setWindTemp(speed:speed, direction: direction, temp:temp)
            }
        }
        
        if let baromin = info["baromin"] as? String {
            setBarometer(baromin: baromin)
        }
        
        if let humidity = info["humidity"] as? String {
            setHumidity(humidity: humidity)
        }
        
        if let dewpoint = info["dewptf"] as? String {
            setDewpoint(dewpoint: dewpoint)
        }
        
        if let rainfall = info["rainin"] as? String {
            setRainfall(rainfall: rainfall)
        }
        
        if let dailyRainfall = info["dailyrainin"] as? String {
            setDailyRainfall(dailyRainfall: dailyRainfall)
        }
        
        updateMenuLabel()
    }
    
    func updateSolarData(info:[String: Any]) {
        if let solarVoltage = info["solar_v"] as? Float, let solarWattage = info["solar_power_mw"] as? Float {
            setSolarOutput(solarVoltage: solarVoltage, solarWattage: solarWattage)
        }
        
        if let photoVoltage = info["photo_v"] as? Float {
            setPhotoResistor(photoResistorVoltage: photoVoltage)
        }
        
        updateMenuLabel()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.title = "goats"
            // button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        let menu = NSMenu()
        
        activeItem = windMenuItem;
        // menu.addItem(temperatureMenuItem)
        menu.addItem(windMenuItem)
        menu.addItem(barometerMenuItem)
        menu.addItem(humidityMenuItem)
        menu.addItem(dewpointMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(rainfallMenuItem)
        menu.addItem(dailyRainfallMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(solarOutputMenuItem)
        menu.addItem(photoResistorMenuItem)
        
        statusItem.menu = menu
        getUpdate()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

