/*-
 *
 * Author:
 *    Pal Dorogi "ilap" <pal.dorogi@gmail.com>
 *
 * Copyright (c) 2016 Pal Dorogi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

///
/// Base tables
///
class PAM: CamembertModel, DataServiceProtocol {
    var nuclease_id: INTEGER = 0
    var sequence: TEXT = ""
    var survival: REAL =  0.0
    
    class func findAll() -> [PAM] {
        return PAM.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [PAM]
    }
    
    class func findByValue(column: String, value: Any) -> [PAM] {
        let records = PAM.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [PAM]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [PAM] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = PAM.select(selectRequest:  Select.CustomRequest(customRequest))! as! [PAM]

        return records
    }

    func save() {
        self.push()
    }

    required override init() {
        super.init()
    }

}


class Nuclease: CamembertModel, DataServiceProtocol  {

    var name: TEXT = ""
    var spacer_length: INTEGER = 0
    var sense_cut_offset: INTEGER = Int.min
    var antisense_cut_offset: INTEGER = Int.min
    
    // TODO: Make Camambert using enums
    var downstream_target: BIT = true // true downstream false upstream relatove to PAM
    var descr: TEXT = ""
    
    class func findAll() -> [Nuclease] {
        return Nuclease.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [Nuclease]
    }

    class func findByValue(column: String, value: Any) -> [Nuclease] {
        let records = Nuclease.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [Nuclease]
        return records
    }


    class func findByValues(queries: [String:Any]) -> [Nuclease] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = Nuclease.select(selectRequest:  Select.CustomRequest(customRequest))! as! [Nuclease]

        return records
    }

    class func findkkkByName(name: String) -> [Nuclease] {
        let nuclease = Nuclease.select(selectRequest:  Select.Where("name", .EqualsTo, name, .Ascending, "1"))! as! [Nuclease]
        return nuclease
    }

    required override init() {
        super.init()
    }
    func save() {
        self.push()
    }
}


class ModelOrganism: CamembertModel, DataServiceProtocol {
    var name: TEXT = ""
    var descr: TEXT = ""
    var path: TEXT = ""
    var sequence_length: INTEGER = -1
    var sequence_hash: INTEGER = 0
    
    class func findAll() -> [ModelOrganism] {
        return ModelOrganism.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [ModelOrganism]
        
    }

    class func findByValue(column: String, value: Any) -> [ModelOrganism] {
        let records = ModelOrganism.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [ModelOrganism]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [ModelOrganism] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = ModelOrganism.select(selectRequest:  Select.CustomRequest(customRequest))! as! [ModelOrganism]

        return records
    }

    class func findHash(hash: Int) -> [ModelOrganism] {
        return ModelOrganism.select(selectRequest:  Select.Where("sequence_hash", .EqualsTo, hash, .Ascending, "1"))! as! [ModelOrganism]
    }
    
    func copySequenceToDatabase(fromPath: String, createNewFile: Bool) throws {
        
        
        if self.path == "", let path = Defaults[.databasePath] , let blobPath = Defaults[.blobFilesPath] {
            self.path = path + "/" + blobPath
        }
        
        let toPath = self.path + "/" + String(UInt(bitPattern:self.sequence_hash), radix:16).uppercaseString + ".fasta"
        
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(toPath) {
            debugPrint("DATABASE ERROR: \"\(toPath)\" \(DataAccess.access.DbPath)")
            throw ModelError.Error ("DATABASE ERROR: Inconsistent database, \"\(toPath)\" already exist without any reference record in the database")
        } else {
            do {
               // print("Copying \(fromPath) to \(toPath)")
                try fileManager.copyItemAtPath(fromPath, toPath: toPath)
                
            }
            catch let error as NSError {
                debugPrint("Cannot copy \(fromPath) to \(toPath): \(error)")
                throw ModelError.Error("Cannot copy \(fromPath) to \(toPath): \(error)")
            }
        }
    }

    required override init() {
        super.init()
    }
    func save() {
        self.push()
    }
}


enum TargetType: String {
    case Location = "L"
    case GuideRNA = "R"
    case Gene = "G"
    case Sequence = "S"
}

class DesignApplication: CamembertModel, DataServiceProtocol {
    var name: TEXT = ""
    var descr: TEXT = ""

    class func findAll() -> [DesignApplication] {
        return DesignApplication.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [DesignApplication]
    }

    class func findByValue(column: String, value: Any) -> [DesignApplication] {
        let records = DesignApplication.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [DesignApplication]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [DesignApplication] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = DesignApplication.select(selectRequest:  Select.CustomRequest(customRequest))! as! [DesignApplication]

        return records
    }

    required override init() {
        super.init()
    }
    func save() {
        self.push()
    }

}

class ModelTarget: CamembertModel, DataServiceProtocol {
    var model_organism_id: INTEGER = 0
    var design_application_id: INTEGER = 0
    var name: TEXT = ""
    
    var location: INTEGER = 0
    var length: INTEGER = 0
    var offset: INTEGER = 0
    var type: TEXT = "L"
    var descr: TEXT = ""
    
    class func findForModelOrganism(column: [String], value: [Any]) -> [ModelTarget] {
        let customRequest = "SELECT * FROM ModelTarget WHERE \(column[0]) = \(value[0]) AND \(column[1]) = \(value[1]) AND \(column[2]) = \(value[2]);"
        let modelTarget = ModelTarget.select(selectRequest:  Select.CustomRequest(customRequest))! as! [ModelTarget]
        return modelTarget
    }

    class func findAll() -> [ModelTarget] {
        return ModelTarget.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [ModelTarget]
    }

    class func findByValue(column: String, value: Any) -> [ModelTarget] {
        let records = ModelTarget.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [ModelTarget]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [ModelTarget] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix
        //print("CUSTOMREQUEST: \(customRequest)")

        let records = ModelTarget.select(selectRequest:  Select.CustomRequest(customRequest))! as! [ModelTarget]

        return records
    }

    required override init() {
        super.init()
    }
    func save() {
        self.push()
    }

}


///
/// On and Off Target tables
///
class OnTarget: CamembertModel, DataServiceProtocol {
    var model_target_id: INTEGER = 0
    var nuclease_id: INTEGER = 0
    var pam: TEXT = ""
    var pam_location: INTEGER = -1
    var score: REAL = 0.0
    var spacer_length: INTEGER = 0
    var seed_length: INTEGER = 0
    var at_offset_position: BIT = false
    var on_sense_strand: BIT = true
    
    required override init() {
        super.init()
    }

    class func findAll() -> [OnTarget] {
        return OnTarget.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [OnTarget]
    }

    class func findByValue(column: String, value: Any) -> [OnTarget] {
        let records = OnTarget.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [OnTarget]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [OnTarget] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = OnTarget.select(selectRequest:  Select.CustomRequest(customRequest))! as! [OnTarget]

        return records
    }

    func save() {
        self.push()
    }
}


class OffTarget: CamembertModel, DataServiceProtocol {
    var on_target_id: INTEGER = 0
    var pam_location: INTEGER = -1
    var score: REAL = 0.0
    var on_sense_strand: BIT = false
    // Off target maybe checked at on target position if it's a KI or single point mutation editing.
    var at_on_target: BIT = false

    class func findAll() -> [OffTarget] {
        return OffTarget.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [OffTarget]
    }

    required override init() {
        super.init()
    }

    class func findByValue(column: String, value: Any) -> [OffTarget] {
        let records = OffTarget.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [OffTarget]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [OffTarget] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = OffTarget.select(selectRequest:  Select.CustomRequest(customRequest))! as! [OffTarget]

        return records
    }

    func save() {
        self.push()
    }
}


///
/// Experimental tables
///
class User: CamembertModel, DataServiceProtocol {
    var login: TEXT = ""
    var first_name: TEXT = ""
    var last_name: TEXT = ""

    class func findAll() -> [User] {
        return User.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [User]
    }

    class func findByValue(column: String, value: Any) -> [User] {
        let records = User.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [User]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [User] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = User.select(selectRequest:  Select.CustomRequest(customRequest))! as! [User]

        return records
    }

    required override init() {
        super.init()
    }
    func save() {
        self.push()
    }
}

class Experiment: CamembertModel, DataServiceProtocol {
    var user_id: INTEGER = 0
    var title: TEXT = ""
    var date: DATE_TIME = NSDate(timeIntervalSince1970: 0)
    var validated: DATE_TIME = NSDate(timeIntervalSince1970: 0)
    var descr: TEXT = ""

    class func findAll() -> [Experiment] {
        return Experiment.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [Experiment]
    }

    class func findByValue(column: String, value: Any) -> [Experiment] {
        let records = Experiment.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [Experiment]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [Experiment] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = Experiment.select(selectRequest:  Select.CustomRequest(customRequest))! as! [Experiment]

        return records
    }

    required override init() {
        super.init()
    }
    func save() {
        self.push()
    }

}

class ExperimentGuideRNA: CamembertModel, DataServiceProtocol {
    var experment_id: INTEGER = 0
    var on_target_id: INTEGER = 0
    var title: TEXT = ""
    var validated: DATE_TIME = NSDate(timeIntervalSince1970: 0)

    class func findAll() -> [ExperimentGuideRNA] {
        return ExperimentGuideRNA.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [ExperimentGuideRNA]
    }

    class func findByValue(column: String, value: Any) -> [ExperimentGuideRNA] {
        let records = ExperimentGuideRNA.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [ExperimentGuideRNA]
        return records
    }

    class func findByValues(queries: [String:Any]) -> [ExperimentGuideRNA] {

        let className = String(self)
        let prefix = "SELECT * FROM \(className) WHERE "
        let postfix = ";"

        var parameters = ""
        var first = true
        for (column, value) in queries {
            if first {
                parameters += "\(column) = \(value)"
                first = false
            } else {
                parameters += " AND \(column) = \(value)"
            }
        }
        let customRequest = prefix + parameters + postfix

        let records = ExperimentGuideRNA.select(selectRequest:  Select.CustomRequest(customRequest))! as! [ExperimentGuideRNA]

        return records
    }

    required override init() {
        super.init()
    }
    func save() {
        self.push()
    }
}



