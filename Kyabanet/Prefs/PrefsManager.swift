//
//  PrefsManager.swift
//  CIUWApp
//
//  Created by XianHuang on 5/12/20.
//  Copyright © 2020 ciuw. All rights reserved.
//

import Foundation

class PrefsManager:NSObject{
    
    class func set(key:String,value:Bool){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func get(key:String) -> Bool{
        let value = UserDefaults.standard.bool(forKey: key)
        return value
    }
    
    class func setString(key:String,value:String){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getString(key:String) -> String{
        let value = UserDefaults.standard.string(forKey: key) ?? ""
        return value
    }
    
    class func setInt(key:String,value:Int){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getInt(key:String) -> Int{
        let value = UserDefaults.standard.integer(forKey: key)
        return value
    }
    
    
    class func setFCMToken(val : String)
    {
        setString(key: "fcmToken", value: val)
    }
    
    class func  getFCMToken() -> String
    {
        return getString(key: "fcmToken")
    }
    
    class func setUserID(val : String)
    {
        setString(key: "userid", value: val)
    }
    
    class func  getUserID() -> String
    {
        return getString(key: "userid")
    }
    
    
    class func setEmail(val : String)
    {
        setString(key: "email", value: val)
    }
    
    class func setUserType(val : Int)
    {
        setInt(key: "userType", value: val)
    }
    
    class func getUserType() -> Int
    {
        return getInt(key: "userType")
    }
    
    class func  getEmail() -> String
    {
        return getString(key: "email")
    }
    
    class func setAvatar(val : String)
    {
        setString(key: "avatar", value: val)
    }
    
    class func  getAvatar() -> String
    {
        return getString(key: "avatar")
    }
    

    class func setFirstName(val : String)
    {
        setString(key: "firstname", value: val)
    }
    
    class func  getFirstName() -> String
    {
        return getString(key: "firstname")
    }
    class func setLastName(val : String)
    {
        setString(key: "lastname", value: val)
    }
    
    class func  getLastName() -> String
    {
        return getString(key: "lastname")
    }
    class func setPassword(val : String)
    {
        setString(key: "password", value: val)
    }
    
    class func  getPassword() -> String
    {
        return getString(key: "password")
    }

    class func setEULAAgree(val: Bool){
        set(key: "EULA1", value: val)
    }
    
    class func getEULAAgree() -> Bool{
        get(key: "EULA1")
    }
    
    class func setReadEULA(val: Bool){
        set(key: "ReadEULA1", value: val)
    }
    class func getReadEULA() -> Bool{
        get(key: "ReadEULA1")
    }

}
