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

    let statusItem = NSStatusBar.system().statusItem(withLength:-2)
    let temperatureMenuItem = NSMenuItem(title: "?F", action: #selector(doNothing(sender:)), keyEquivalent:"")
    let windMenuItem = NSMenuItem(title: "?mph ?", action: #selector(doNothing(sender:)), keyEquivalent:"")
    let barometerMenuItem = NSMenuItem(title: "? inHg", action: #selector(doNothing(sender:)), keyEquivalent:"")
    let humidityMenuItem = NSMenuItem(title: "?% humidity", action: #selector(doNothing(sender:)), keyEquivalent:"")
    let dewpointMenuItem = NSMenuItem(title: "?F dewpoint", action: #selector(doNothing(sender:)), keyEquivalent:"")
    let rainfallMenuItem = NSMenuItem(title: "?\" rainfall", action: #selector(doNothing(sender:)), keyEquivalent:"")
    let dailyRainfallMenuItem = NSMenuItem(title: "?\" today", action: #selector(doNothing(sender:)), keyEquivalent:"")
    
    func doNothing(sender:AnyObject) {
    }
    
    func convertToDirection(degrees:Int) -> String {
        let names = [ "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" ]
        let index = ((degrees + 11) % 360) / (360/names.count)
        
        return names[index]
    }
    
    @objc func getUpdate() {
        let url = URL(string: "http://owl.lyratarium.com:11000/sensor-00002116")
        Timer.scheduledTimer(timeInterval:15, target: self, selector: #selector(self.getUpdate), userInfo: nil, repeats: false)

        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let parsed = try! JSONSerialization.jsonObject(with: data, options: [])
            if let info = parsed as? [String: Any] {
                self.updateData(info:info)
            }
        }
        
        task.resume()
    }
    
    func setTemperature(temp:String) {
        temperatureMenuItem.title = temp + "F"
    }
    
    func setWind(speed:String, direction:Int) {
        windMenuItem.title = speed + "mph " + convertToDirection(degrees: direction)
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
    
    func updateData(info:[String: Any]) {
        if let temp = info["tempf"] as? String {
            setTemperature(temp: temp)
        }
        
        if let speed = info["windspeedmph"] as? String, let directionStr = info["winddir"] as? String {
            if let direction = Int(directionStr)  {
                setWind(speed:speed, direction: direction)
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
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.title = "goats"
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        let menu = NSMenu()
        
        menu.addItem(temperatureMenuItem)
        menu.addItem(windMenuItem)
        menu.addItem(barometerMenuItem)
        menu.addItem(humidityMenuItem)
        menu.addItem(dewpointMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(rainfallMenuItem)
        menu.addItem(dailyRainfallMenuItem)
        
        statusItem.menu = menu
        getUpdate()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

