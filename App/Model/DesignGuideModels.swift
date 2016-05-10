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

// Define types to model Guide RNA data for exclusivelly transferring data 
// from DAL (Data Access Layer} to the program codes.
//
// These types only used in DAL exclusivelly as these types might be changed
// due to the table structure changes in the database would affect our 
// Business logic layer.
//

import Foundation

protocol CamembertModelType {
    associatedtype T
    static func findAll() -> [T]
}

public enum ModelError: ErrorType {
    case Error(String)
    case FileError(String)
    case DatabaseError(String)
    case ParameterError(String)
    case EmptyError
}


///
/// Base tables
///
class PAM: CamembertModel, CamembertModelType  {
    var nuclease_id: INTEGER = 0
    var sequence: TEXT = ""
    var survival: REAL =  0.0
    
    class func findAll() -> [PAM] {
        return PAM.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [PAM]
    }
    
    class func findByValue(column: String, value: Any) -> [PAM] {
        let pam = PAM.select(selectRequest:  Select.Where(column, .EqualsTo, value, .Ascending, "1"))! as! [PAM]
        return pam
    }
}


class Nuclease: CamembertModel, CamembertModelType {
    //var species_id: INTEGER = 0
    //var endonuclease_id: INTEGER = 0
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
    
    class func printWithOriginEndPAM () {
        let Nucleases = Nuclease.findAll()// select(selectRequest: Select.Where("endonuclease_id", .EqualsTo, s.id!, .Ascending, "1"))! as! [Nuclease]

        for Nuclease in Nucleases {
            let pams = PAM.select(selectRequest:  Select.Where("nuclease_id", .EqualsTo, Nuclease.id!, .Ascending, "1"))! as! [PAM]
            if pams.isEmpty {
                continue
            }
            var spams: String = ""
            for pam in pams {
                spams += " "
                spams += pam.sequence
                spams += "("
                spams += String(pam.survival*100)
                spams += "%)"
            }
            print("\t\"\(Nuclease.name)\" - \(spams)")
            
        }
    }
    
    class func findByName(name: String) -> [Nuclease] {
        let nuclease = Nuclease.select(selectRequest:  Select.Where("name", .EqualsTo, name, .Ascending, "1"))! as! [Nuclease]
        return nuclease
    }
}


class ModelOrganism: CamembertModel {
    var name: TEXT = ""
    var descr: TEXT = ""
    var path: TEXT = ""
    var sequence_hash: INTEGER = 0
    
    class func findAll() -> [ModelOrganism] {
        return ModelOrganism.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [ModelOrganism]
        
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
                print("Copying \(fromPath) to \(toPath)")
                try fileManager.copyItemAtPath(fromPath, toPath: toPath)
                
            }
            catch let error as NSError {
                throw ModelError.Error("Cannot copy \(fromPath) to \(toPath): \(error)")
            }
        }
    }
}


enum TargetType: String {
    case Location = "L"
    case GuideRNA = "R"
    case Gene = "G"
    case Sequence = "S"
}


class ModelTarget: CamembertModel {
    var model_organism_id: INTEGER = 0
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
}


///
/// On and Off Target tables
///
class OnTarget: CamembertModel {
    var model_target_id: INTEGER = 0
    var nuclease_id: INTEGER = 0
    var pam: TEXT = ""
    var pam_location: INTEGER = -1
    var score: REAL = 0.0
    var spacer_length: INTEGER = 0
    var seed_length: INTEGER = 0
    var at_offset_position: BIT = false
    var on_sense_strand: BIT = true
    
}


class OffTarget: CamembertModel {
    var on_target_id: INTEGER = 0
    var pam_location: INTEGER = -1
    var score: REAL = 0.0
    var on_sense_strand: BIT = false
    // Off target maybe checked at on target position if it's a KI or single point mutation editing.
    var at_on_target: BIT = false
}

///
/// Experimental tables
///
class User: CamembertModel {
    var login: TEXT = ""
    var first_name: TEXT = ""
    var last_name: TEXT = ""
}

class Experiment: CamembertModel {
    var user_id: INTEGER = 0
    var title: TEXT = ""
    var date: DATE_TIME = NSDate(timeIntervalSince1970: 0)
    var validated: DATE_TIME = NSDate(timeIntervalSince1970: 0)
    var descr: TEXT = ""
}

class ExperimentGuideRNA: CamembertModel {
    var experment_id: INTEGER = 0
    var on_target_id: INTEGER = 0
    var title: TEXT = ""
    var validated: DATE_TIME = NSDate(timeIntervalSince1970: 0)
}



