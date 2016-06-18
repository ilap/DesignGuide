//
//  SwiftSQL.swift
//  SwiftSQL
//
//  Created by Remi Robert on 20/08/14.
//  Copyright (c) 2014 remirobert. All rights reserved.
//

import Foundation

class CamembertModel : NSObject {
    
    private var nameTable :String! = nil
    var id :Int? = nil
    
    func setId(_ id :Int) {
        self.id = id
    }
    
    private class func openConnection() {
        Camembert.closeDataBase()
        if let dbFolder = DataAccess.access.DbPath {
            //debugPrint("DBFOLDER: \(dbFolder)")
            Camembert.initDataBase(dbFolder, nameDatabase: DataAccess.access.nameDataBase!)
        }else{
            Camembert.initDataBase(DataAccess.access.nameDataBase!)
        }
    }
    
    enum OperationResult{
        case success, error_DuplicatedID, error_NoRecordFoundWithID, error_GeneralFailure
    }
    
    func push() -> OperationResult{
        if self.id != nil {
            return OperationResult.error_DuplicatedID;
        }
        CamembertModel.openConnection()
        
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        let lastIndex = children.endIndex
        var requestPush = "INSERT INTO " + self.nameTable + " ("
        
        for i in children.indices
        {
            //if (i.successor() == lastIndex)
            if (children.index(after: i) == lastIndex)
            {
                requestPush += children[i].label! + ")"
            }
            else
            {
                requestPush += children[i].label! + ", "
            }
        }
        
        requestPush += " VALUES ("
        
        for i in children.indices
        {
            let currentValue = children[i].value

            
            switch currentValue
            {
            case _ where (currentValue as? TEXT != nil): requestPush += "\"\(currentValue)\""
            case _ where (currentValue as? DATE_TIME != nil):
                let dateformatter = DateFormatter();
                dateformatter.dateFormat = Camembert.Date_Time_Format;
                let date = (currentValue as! Date)
                _ = dateformatter.date(from: "\(date)")
                requestPush += "\"\(date)\""
                break;
            case _ where (currentValue as? BIT != nil):
                if (currentValue as! Bool)
                {
                    requestPush += "1";
                }
                else
                {
                    requestPush += "0";
                }
                break;
            default: requestPush += "\(currentValue)"
            }
            
            if (children.index(after: i) == lastIndex)
            {
                requestPush += ");"
            }
            else
            {
                requestPush += ", "
            }
        }
        
        //debugPRint ("REQUESTPUSH: \(requestPush)\n DB: \(DataAccess.access.nameDataBase!)")
        let result = camembertExecSqlite3(UnsafeMutablePointer<Void>(DataAccess.access.dataAccess),
            requestPush.cString(using: String.Encoding.utf8)!)
        self.id = Int(sqlite3_last_insert_rowid(DataAccess.access.dataAccess))
        var opResult: OperationResult = OperationResult.success
        if !result{
            opResult = OperationResult.error_GeneralFailure
        }
        return opResult
    }
    
    func update() -> OperationResult
    {
        if self.id == -1
        {
            return OperationResult.error_NoRecordFoundWithID
        }
        CamembertModel.openConnection()
        
        let mirror = Mirror(reflecting: self)
        let children = mirror.children // .dropFirst()
        let lastIndex = children.endIndex
        
        var requestUpdate :String = "UPDATE \(self.nameTable) SET "
        for i in children.indices
        {
            let currentValue = children[i].value
            
            switch currentValue
            {
            case _ where (currentValue as? TEXT != nil): requestUpdate += "\(children[i].label!) = \"\(currentValue)\""
            case _ where (currentValue as? DATE_TIME != nil):
                let dateformatter = DateFormatter();
                dateformatter.dateFormat = Camembert.Date_Time_Format;
                let date = (currentValue as! Date)
                requestUpdate += "\(children[i].label!) = \"\(date)\""
                break;
                
            case _ where (currentValue as? BIT != nil):
                let result = (currentValue as! Bool) ? "1" : "0";
                requestUpdate += "\(children[i].label!) = \"\(result)\""
            default: requestUpdate += "\(children[i].label!) = \(currentValue)"
            }
            
            if (children.index(after: i) == lastIndex)
            {
                requestUpdate += " WHERE id = \(self.id!);"
            }
            else
            {
                requestUpdate += ", "
            }
        }
        
        let result = camembertExecSqlite3(UnsafeMutablePointer<Void>(DataAccess.access.dataAccess),
            requestUpdate.cString(using: String.Encoding.utf8)!)
        var opResult = OperationResult.success
        if !result{
            opResult = OperationResult.error_GeneralFailure
        }
        return opResult;
    }
    
    func remove() -> OperationResult{
        if self.id == nil {
            return OperationResult.error_NoRecordFoundWithID;
        }
        CamembertModel.openConnection()
        let requestDelete :String = "DELETE FROM \(self.nameTable) WHERE id=\(self.id!)"
        
        let result = camembertExecSqlite3(UnsafeMutablePointer<Void>(DataAccess.access.dataAccess),
            requestDelete.cString(using: String.Encoding.utf8)!)
        self.id = -1
        if !result{
            return OperationResult.error_GeneralFailure
        }
        return OperationResult.success
    }
    
    func getSchemaTable() -> [String]! {
        CamembertModel.openConnection()
        
        var arrayString :[String] = []
        
        let mirror = Mirror(reflecting: self)
        let children = mirror.children // .dropFirst()
        
        for i in children.indices
        {
            let currentValue = children[i].value
            
            switch currentValue
            {
            case _ where (currentValue as? INTEGER != nil):
                arrayString.append("\(children[i].label!) INTEGER")
            case _ where (currentValue as? REAL != nil):
                arrayString.append("\(children[i].label!) REAL")
            case _ where (currentValue as? TEXT != nil):
                arrayString.append("\(children[i].label!) TEXT")
            case _ where (currentValue as? DATE_TIME != nil):
                arrayString.append("\(children[i].label!) TEXT")
            case _ where (currentValue as? BIT != nil):
                arrayString.append("\(children[i].label!) INTEGER")
            default: return nil
            }
        }
        
        return arrayString
    }
    
    func isTableExist() -> Bool {
        CamembertModel.openConnection()
        
        for currentTable in Camembert.getListTable() {
            if currentTable == self.nameTable {
                return true
            }
        }
        return false
    }
    
    class func getNameTable( _ tmpNameTable :inout String) -> String {
        let parseString = "0123456789"
        
        for currentNumberParse in parseString.characters {
            var parseName = tmpNameTable.components(separatedBy: String(currentNumberParse))
            if parseName.count > 0 {
                tmpNameTable = parseName[parseName.count - 1]
            }
        }
        return tmpNameTable
    }
    
    func _initNameTable() {
        CamembertModel.openConnection()
        
        var tmpNameTable = NSString(cString: object_getClassName(self), encoding: String.Encoding.utf8.rawValue) as! String
        self.nameTable = CamembertModel.getNameTable(&tmpNameTable).components(separatedBy: ".")[1]
    }
    
    func sendRequest(_ ptrRequest :inout OpaquePointer?, request :String) -> Bool {
        CamembertModel.openConnection()
        
        if sqlite3_prepare_v2(DataAccess.access.dataAccess,
            request.cString(using: String.Encoding.utf8)!, -1, &ptrRequest, nil) != SQLITE_OK {
                sqlite3_finalize(ptrRequest);
                return false
        }
        sqlite3_finalize(ptrRequest);
        return true
    }
    
    func createTable() -> Bool {
        CamembertModel.openConnection()
        
        if self.isTableExist() == false {
            var requestCreateTable :String = "CREATE TABLE " + self.nameTable + " (id INTEGER PRIMARY KEY AUTOINCREMENT, "
            if let configurationTable = self.getSchemaTable() {
                for index in 0 ..< configurationTable.count {
                    switch index {
                    case configurationTable.count - 1: requestCreateTable += configurationTable[index]
                    default: requestCreateTable += configurationTable[index] + ", "
                    }
                }
                requestCreateTable += ");"
//                let request :COpaquePointer = nil
                camembertExecSqlite3(UnsafeMutablePointer<Void>(DataAccess.access.dataAccess),
                    requestCreateTable.cString(using: String.Encoding.utf8)!)
            }
        }
        return true
    }
    
    class func numberElement() -> Int {
        CamembertModel.openConnection()
        
        var tmpNameTable = NSString(cString: class_getName(self), encoding: String.Encoding.utf8.rawValue) as! String
        tmpNameTable = tmpNameTable.components(separatedBy: ".")[1]
        let requestNumberlement :String = "SELECT COUNT(*) FROM \(CamembertModel.getNameTable(&tmpNameTable));"
        var ptrRequest :OpaquePointer? = nil
        
        if sqlite3_prepare_v2(DataAccess.access.dataAccess,
            requestNumberlement.cString(using: String.Encoding.utf8)!, -1, &ptrRequest, nil) != SQLITE_OK {
                sqlite3_finalize(ptrRequest);
                return 0
        }
        if sqlite3_step(ptrRequest) == SQLITE_ROW {
            let number = Int(sqlite3_column_int(ptrRequest, 0))
            sqlite3_finalize(ptrRequest);
            return number
        }
        return 0
    }
    
    func _initWithId(_ id :Int) {
        CamembertModel.openConnection()
        
        let requestInit :String = "SELECT * FROM \(self.nameTable) WHERE id=\(id);"
        var ptrRequest :OpaquePointer? = nil
        
        if sqlite3_prepare_v2(DataAccess.access.dataAccess,
            requestInit.cString(using: String.Encoding.utf8)!, -1, &ptrRequest, nil) != SQLITE_OK {
                sqlite3_finalize(ptrRequest);
                return Void()
        }
        
        if sqlite3_step(ptrRequest) == SQLITE_ROW
        {
            self.setId(Int(sqlite3_column_int(ptrRequest, 0)))
            for index in 1 ..< Int(sqlite3_column_count(ptrRequest)) {
                let columName :String = NSString(cString: sqlite3_column_name(ptrRequest,
                    CInt(index)), encoding: String.Encoding.utf8.rawValue)! as String
                
                switch sqlite3_column_type(ptrRequest, CInt(index)) {
                case SQLITE_INTEGER:
                    self.setValue((Int(sqlite3_column_int(ptrRequest,
                        CInt(index))) as AnyObject), forKey: columName)
                case SQLITE_FLOAT:
                    self.setValue((Float(sqlite3_column_double(ptrRequest,
                        CInt(index))) as AnyObject), forKey: columName)
                case SQLITE_TEXT:
                    let stringValue = String(cString: UnsafePointer<CChar>(sqlite3_column_text(ptrRequest, CInt(index))))
                    self.setValue(stringValue, forKey: columName)
                default: Void()
                }
            }
        }
        sqlite3_finalize(ptrRequest);
    }
    
    class func getRawClassName() -> String? {
        let name = NSStringFromClass(self)
        let components = name.components(separatedBy: ".")
        return components.last
    }
    
    class func select(selectRequest select: Select) -> [AnyObject]? {
        let camembert = Camembert()
        let table = getRawClassName()
        var requestSelect: String? = nil
        var m_OrderBy = "1";

        switch select {
        case .selectAll(let OrderOperator, let OrderBy):
            var op: String;
            if !OrderBy.isEmpty {
                m_OrderBy = OrderBy
            }
            switch OrderOperator{
            case .ascending:
                op = "asc"
            default:
                op = "desc"
            }
            requestSelect = "SELECT * FROM \(table!) ORDER BY \(m_OrderBy) \(op)"
        case .limit(let value, let OrderOperator, let OrderBy):
            var op: String;
            if !OrderBy.isEmpty {
                m_OrderBy = OrderBy
            }
            switch OrderOperator{
            case .ascending:
                op = "asc"
            default:
                op = "desc"
            }
            requestSelect = "SELECT * FROM \(table!) LIMIT \(value) ORDER BY \(m_OrderBy) \(op)"
        case .between(let startValue, let endValue, let OrderOperator, let OrderBy):
            var op: String;
            if !OrderBy.isEmpty {
                m_OrderBy = OrderBy
            }
            switch OrderOperator{
            case .ascending:
                op = "asc"
            default:
                op = "desc"
            }
            requestSelect = "SELECT * FROM \(table!) WHERE ID BETWEEN \(startValue) AND \(endValue) ORDER BY \(m_OrderBy) \(op)"
        case .customRequest(let request):
            requestSelect = request
        case .where(let Field, let Operator, let value, let OrderOperator, let OrderBy):
            var op: String;
            if !OrderBy.isEmpty {
                m_OrderBy = OrderBy
            }
            switch OrderOperator{
            case .ascending:
                op = "asc"
            default:
                op = "desc"
            }
            switch Operator{
            case .equalsTo:
                var resultValue = String();
                
                if let _ = value as? BIT{
                    return nil
                }else if let x = value as? TEXT {
                    resultValue = "\"\(x)\""
                }else if let x = value as? DATE_TIME{
                    resultValue = "\"\(x)\""
                }else{
                    resultValue = "\(value)";
                }
                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) = \(resultValue) ORDER BY \(m_OrderBy) \(op)"
            case .isNull:
                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) IS NULL"
                break;
            case .largerOrEqual:
                var resultValue = String();
                if let _ = value as? BIT{
                    return nil
                }else if let x = value as? TEXT {
                    resultValue = "\"\(x)\""
                }else if let x = value as? DATE_TIME{
                    resultValue = "\"\(x)\""
                }else{
                    resultValue = "\(value)";
                }
                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) >= \(resultValue) ORDER BY \(m_OrderBy) \(op)"
            case .largerThan:
                var resultValue = String();
                if let _ = value as? BIT{
                    return nil
                }else if let x = value as? TEXT {
                    resultValue = "\"\(x)\""
                }else if let x = value as? DATE_TIME{
                    resultValue = "\"\(x)\""
                }else{
                    resultValue = "\(value)";
                }
                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) > \(resultValue) ORDER BY \(m_OrderBy) \(op)"
            case .notNull:
                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) IS NOT NULL ORDER BY \(m_OrderBy) \(op)"
            case .smallerOrEqual:
                var resultValue = String();
                if let _ = value as? BIT{
                    return nil
                }else if let x = value as? TEXT {
                    resultValue = "\"\(x)\""
                }else if let x = value as? DATE_TIME{
                    resultValue = "\"\(x)\""
                }else{
                    resultValue = "\(value)";
                }
                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) <= \(resultValue) ORDER BY \(m_OrderBy) \(op)"
            case .smallerThan:
                var resultValue = String();
                if let _ = value as? BIT{
                    return nil
                }else if let x = value as? TEXT {
                    resultValue = "\"\(x)\""
                }else if let x = value as? DATE_TIME{
                    resultValue = "\"\(x)\""
                }else{
                    resultValue = "\(value)";
                }
                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) < \(resultValue) ORDER BY \(m_OrderBy) \(op)"
//            case .IsNull:
//                requestSelect = "SELECT * FROM \(table!) WHERE \(Field) IS NULL ORDER BY \(m_OrderBy) \(op)"
            }
            break;
        }

       // debugPrint ("REQUEST SELECT: \(requestSelect) \(table!)")
        CamembertModel.openConnection()

        
        if let ret = camembert.getObjectsWithQuery(requestSelect!, table: table!) {
            //ILAP: print ("RET: \(ret)")
            return ret
            
        }
        return nil
    }
    
    class func removeTable() {
        CamembertModel.openConnection()
        let table = getRawClassName()
        let requestRemove :String = "DROP TABLE IF EXISTS \(table!);"
        
        camembertExecSqlite3(UnsafeMutablePointer<Void>(DataAccess.access.dataAccess),
            requestRemove.cString(using: String.Encoding.utf8)!)
    }
    
    override init() {
        super.init()
        self._initNameTable()
        self.createTable()
    }
    
    convenience init(id :Int) {
        /*super.init()
        self._initNameTable()
        self.createTable()*/
        self.init()
        self._initWithId(id)
    }
}
