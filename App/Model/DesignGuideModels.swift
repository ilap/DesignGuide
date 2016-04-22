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
// Base Tables
class Species: CamembertModel {
    var name: TEXT = ""
    var sequence_file: TEXT = ""
    var length: INTEGER = 0
}

class Target: CamembertModel {
    var name: TEXT = ""
    var sequence: TEXT = ""
    var upstream: INTEGER = 0
    var downstream: INTEGER = 0
}

class TargetHit: CamembertModel {
    var species_id: INTEGER = 0
    var target_id: INTEGER = 0
    var position: INTEGER = 0
    var length: INTEGER = 0
    // TODO: Make Camambert using enums
    var strand: BIT = true
    var score: REAL = 0.0
}

class PAM: CamembertModel {
    var nuclease_name: TEXT = ""
    var nuclease_origin: TEXT = ""
    var pam: TEXT = ""
    
    class func findAll() -> [PAM] {
        return PAM.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [PAM]
    }
}

class Nuclease: CamembertModel {
    var name: TEXT = ""
    var origin: TEXT = ""
    var pam: TEXT = ""
    var type: INTEGER = 0
    var seed_length: INTEGER = 0
    // TODO: Make Camambert using enums for pam direction e.g. up/down stream.
    var pam_direction: INTEGER = 0
    var cut_offset: INTEGER = 0
    
    class func findAll() -> [Nuclease] {
        return Nuclease.select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [Nuclease]
    }
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



