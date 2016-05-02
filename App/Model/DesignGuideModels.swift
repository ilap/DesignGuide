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

enum EnzymeType: Int {
    case WildType
    case Nickase
}
enum Strand: Int8 {
    case Coding = 0 // Coding Leading Sense +
    case Template
}

enum Direction: Int8 {
    case upStream = 0
    case downStream
}

// Define types to model Guide RNA data for exclusivelly transferring data 
// from DAL (Data Access Layer} to the program codes.
//
// These types only used in DAL exclusivelly as these types might be changed
// due to the table structure changes in the database would affect our 
// Business logic layer.
//

protocol CamembertModelType {
    associatedtype T
    static func findAll() -> [T]
}


// Base Tables
class Species: CamembertModel {
    var genus: TEXT = ""
    var species: TEXT = ""
    var descr: TEXT = ""
    class func findAll() -> [Species] {
        return Species.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [Species]
    }

}

class Endonuclease: CamembertModel, CamembertModelType {
    var name: TEXT = ""
    var descr: TEXT = ""
    class func findAll() -> [Endonuclease] {
        return Endonuclease.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [Endonuclease]
    }
}

class Variant: CamembertModel, CamembertModelType {
    var species_id: INTEGER = 0
    var endonuclease_id: INTEGER = 0
    var name: TEXT = ""
    var seed_length: INTEGER = 0
    var spacer_length: INTEGER = 0
    var sense_cut_offset: INTEGER = Int.min
    var antisense_cut_offset: INTEGER = Int.min
    
    // TODO: Make Camambert using enums
    var guide_target_position: BIT = true // true downstream false upstream relatove to PAM
    var descr: TEXT = ""
    class func findAll() -> [Variant] {
        return Variant.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [Variant]
    }
    
    class func printWithOriginEndPAM () {
        let variants = Variant.findAll()// select(selectRequest: Select.Where("endonuclease_id", .EqualsTo, s.id!, .Ascending, "1"))! as! [Variant]

        for variant in variants {
            let pams = PAM.select(selectRequest:  Select.Where("variant_id", .EqualsTo, variant.id!, .Ascending, "1"))! as! [PAM]
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
            print("\t\"\(variant.name)\" - \(spams)")
            
        }
    }
}


class PAM: CamembertModel, CamembertModelType  {
    var variant_id: INTEGER = 0
    var sequence: TEXT = ""
    var survival: REAL =  0.0
    
    class func findAll() -> [PAM] {
        return PAM.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [PAM]
    }
}



// Experimental Tables

class Target: CamembertModel {
    var name: TEXT = ""
    var sequence: TEXT = ""
    var upstream: INTEGER = 0
    var downstream: INTEGER = 0
}


// Guide Tables (generated}
class Guide: CamembertModel {
    var pam_id: INTEGER = 0
    var target_hit_id: INTEGER = 0
    var score: REAL = 0.0
    var pam: TEXT = ""
    var position: INTEGER = 0 // This is the PAM start position and everythings is calculated based on this.
    var closest_guide: INTEGER = 0
}



