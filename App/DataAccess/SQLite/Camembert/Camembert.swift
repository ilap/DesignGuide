//
//  Camembert.swift
//  SwiftSQL
//
//  Created by Remi Robert on 28/08/14.
//  Copyright (c) 2014 remirobert. All rights reserved.
//

import Foundation

typealias INTEGER = Int
typealias REAL = Float
typealias TEXT = String
typealias DATE_TIME = Date
typealias BIT = Bool


enum Operator {
    case largerThan, largerOrEqual, smallerThan, smallerOrEqual, equalsTo, isNull, notNull
}

enum OrderOperator{
    case ascending, descending
}

enum Select {
    case selectAll(OrderOperator, String)
    case customRequest(String)
    case limit(Int, OrderOperator, String)
    case between(Int, Int, OrderOperator, String)
    case `where`(String, Operator, Any, OrderOperator, String)
}

class DataAccess {
    var dataAccess :OpaquePointer? = nil
    var nameDataBase: String? = nil
    private var _dbpath: String? = nil;
    var DbPath: String? {
        get{
            return self._dbpath;
        }
        set (value){
            var isDir = ObjCBool(true)
            if !FileManager.default.fileExists(atPath: value!, isDirectory: &isDir){
                do {
                    try FileManager.default.createDirectory(atPath: value!, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    print("DataAccess function raised an exception")
                }
                
            }
            self._dbpath = value;
        }
    }

    class var access :DataAccess {
    struct Static {
        static let instance : DataAccess = DataAccess()
        }
        return Static.instance
    }
}

class Camembert {
    class var Date_Time_Format:String {
        get
        {
            return "yyyy'-'MM'-'dd hh':'mm':'ss'";
        }
    }
    
    class func initDataBase(_ nameDatabase :String) -> Bool {
        let documentDirectory :String = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true)[0] as String
        
        let pathDatabase = documentDirectory + "/" + nameDatabase
        
        let ret = sqlite3_open(pathDatabase.cString(using: String.Encoding.utf8)!,
            &DataAccess.access.dataAccess)
        
        if ret != SQLITE_OK {
            return createDataBase(nameDatabase)
        }
        DataAccess.access.nameDataBase = nameDatabase
        return true
    }
    
    class func initDataBase(_ databaseFolder: String, nameDatabase :String) -> Bool{
        DataAccess.access.DbPath = databaseFolder;
        
        let ret = sqlite3_open(databaseFolder.cString(using: String.Encoding.utf8)!,
            &DataAccess.access.dataAccess)
        if ret != SQLITE_OK {
            //debugPrint("DATABASE ERROR: cannot open database \(DataAccess.access.DbPath) ")
            return createDataBase(databaseFolder, nameDatabase: nameDatabase)
        }
        DataAccess.access.nameDataBase = nameDatabase
        //print("INFO: \(databaseFolder), \(nameDatabase)")
        return true;
    }

    class func createDataBase(_ nameDatabase: String) -> Bool {
        let documentDirectory :String = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true)[0] as String
        
        let pathDatabase = documentDirectory + "/" + nameDatabase
        
        if sqlite3_open_v2(pathDatabase.cString(using: String.Encoding.utf8)!,
            &DataAccess.access.dataAccess, (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE), nil) != SQLITE_OK {

                DataAccess.access.dataAccess = nil
                return false
        }
        DataAccess.access.nameDataBase = nameDatabase
        return true
    }
    
    class func createDataBase(_ databaseFolder: String, nameDatabase: String) -> Bool {
        if DataAccess.access.DbPath == nil {
            DataAccess.access.DbPath = databaseFolder;
        }
        
        if sqlite3_open_v2((databaseFolder + "/" + nameDatabase).cString(using: String.Encoding.utf8)!,
            &DataAccess.access.dataAccess, (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE), nil) != SQLITE_OK {
                
                DataAccess.access.dataAccess = nil
                return false
        }
        DataAccess.access.nameDataBase = nameDatabase
        return true
    }
    
    class func closeDataBase() -> Bool {
        if sqlite3_close(DataAccess.access.dataAccess) == SQLITE_OK {
            DataAccess.access.dataAccess = nil
            return true
        }
        DataAccess.access.dataAccess = nil
        return false
    }

    func getObjectsWithQuery(_ query :String, table :String) -> [AnyObject]! {
        var ptrRequest :OpaquePointer? = nil
        var objects :Array<AnyObject> = []
        
        if sqlite3_prepare_v2(DataAccess.access.dataAccess,
            query.cString(using: String.Encoding.utf8)!, -1, &ptrRequest, nil) != SQLITE_OK {
                sqlite3_finalize(ptrRequest);
                return nil
        }
        while (sqlite3_step(ptrRequest) == SQLITE_ROW) {
            let currentObject :AnyObject! = camembertCreateObject(table) as AnyObject
            
            (currentObject as! CamembertModel).setId(Int(sqlite3_column_int(ptrRequest, 0)))
            for index in 1 ..< Int(sqlite3_column_count(ptrRequest)) {
                let columName :String = NSString(cString: sqlite3_column_name(ptrRequest,
                    CInt(index)), encoding: String.Encoding.utf8.rawValue)! as String
                

                let casev = sqlite3_column_type(ptrRequest, CInt(index))
                //ILAP:  print ("FORKEY: \(columName) \(query) \(ptrRequest) Type value: \(casev)")
                
                switch  casev {
                case SQLITE_INTEGER:
                    let A = (Int(sqlite3_column_int(ptrRequest,
                        CInt(index))) as AnyObject)
                    //debugPrint ("AAAAAA \(columName) \(A) \(currentObject.getValue)")
                    let _ = currentObject.getValue
                    currentObject.setValue(A, forKey: columName)
                case SQLITE_FLOAT:
                    currentObject.setValue((Float(sqlite3_column_double(ptrRequest,
                        CInt(index))) as AnyObject), forKey: columName)
                case SQLITE_TEXT:
                    let stringValue = String(cString: UnsafePointer<CChar>(sqlite3_column_text(ptrRequest, CInt(index))))
                    if let boolValue = stringValue.toBool() {
                        currentObject.setValue(boolValue, forKey: columName)
                    } else {
                        currentObject.setValue(stringValue, forKey: columName)
                    }
                case SQLITE_NULL:
                    Void()
                    //print("NUUUUUUULLLLLL")
                    
                default: Void()
                    

                }
            }
            objects.append(currentObject)
        }
        sqlite3_finalize(ptrRequest);
        return objects
    }
    
    class func execQuery(_ query :String) -> OpaquePointer? {
        var ptrRequest :OpaquePointer? = nil
        
        if sqlite3_prepare_v2(DataAccess.access.dataAccess,
            query.cString(using: String.Encoding.utf8)!, -1, &ptrRequest, nil) != SQLITE_OK {
                sqlite3_finalize(ptrRequest);
                return nil
        }
        sqlite3_finalize(ptrRequest);
        return ptrRequest!
    }
    
    class func getListTable() -> [String] {
        var tables :[String] = []
        var ptrRequest :OpaquePointer? = nil
        let requestListTables :String = "SELECT name FROM sqlite_master WHERE type='table';"
        
        if sqlite3_prepare_v2(DataAccess.access.dataAccess,
            requestListTables.cString(using: String.Encoding.utf8)!, -1, &ptrRequest, nil) != SQLITE_OK {
                sqlite3_finalize(ptrRequest);
                return tables
        }
        while sqlite3_step(ptrRequest) == SQLITE_ROW {
            tables.append(String(cString: UnsafePointer<CChar>(sqlite3_column_text(ptrRequest, 0))))
        }
        sqlite3_finalize(ptrRequest);
        return tables
    }
}
