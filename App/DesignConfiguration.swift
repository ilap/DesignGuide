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

import Foundation
import SwiftCLI

extension DefaultsKeys {
    // Defaults
    static let databasePath = DefaultsKey<String?>("databasePath")
    static let databaseFile = DefaultsKey<String?>("databaseFile")
}

// Singleton for runtime parameters
class RuntimeParameters {
    // The mandatory options are
    // 1. -s: Source sequence (dir including sequence or sequence file) -s "/Users/ilap/sequence/Sources"
    // 2. -t: Target in the source that can be either of:
    //      2.1 Sequence file includes one or more sequences e.g. -t "/tmp/Targers.fasta"
    //      2.2 gene name(s) if the source is annotated  e.g. -t "lacZ" or -t "lacZ dacA"
    //      2.3 start and end position or start and length in the Source sequences.
    //           Length can be 1 for a single point mutation.
    // 3. -e -[-p] or -p: Endonuclease and/or PAM sequence it can be derivated from either of:
    //      3.1 endonuclease e.g. -e "wtCas9" (it has NGG, NAG, NGA and NAA), if database is used
    //      3.2 from explcicite string separated by whitte spaces -p "NAANG NAANGGA" if custom values are used
    //      3.3 combine both of the above -e "wtCas9" -p "NGG" only "NGG" of wtCas9 is considered, if database is used.
    //
    // Semi optional paramterers (based on the the settings from database or users)
    //  1. -c "<sense cut> [antisense cut]": Cut sites to PAMs start (if RNA target is downstream) or end (if RNA target is upstream)
    //      e.g. -c "4" (both sites are cut at the same position), relative to PAM -c "4 5" means cut site on sense strand is 4 and 5 on antisense strain
    //  3. -d "<+|->": RNA target direction, relative to PAM, "-" - Default is "-" (downstream)
    //
    // Others are optional:
    //  1. -L <17-100>: Spacer length - default 20
    //  2. -l <0..spacer lentgth>:Seed length - default 10
    //  3. -o <0..2000>: Target offset, means offset of up/down stream of the target start and and position - default 0
    
    // Custom versus database parameter eamples:
    // cli db -s "/tmp/Sequences" -t "/tmp/Targets.fasta" -n wtCas9 -p "NGG NAG" -o 1000 // Only NGG and NAG is considered of the currently 4 PAMs of wtCas9
    // All the semi optinal parameters (-c) are invalid
    //
    // cli custom -s "/tmp/Sequences" -t "/tmp/Targets.fasta" -p "NGG" -d down -c "4" -n +1 -o 2000
    // -n is invalid if more than one cut sites are given e.g. -c "4 5"
    
    // Mandatory parameters
    var source: String?
    
    var target: String?
    var targetSequence: String?
    var targetLocation: Int?
    var targetStart: Int?
    var targetEnd:  Int?
    
    var endonuclease: String?
    
    var pams: [String]?
    
    //Semi optional parameters
    var senseCutOffset: Int?
    var antisenseCutOffset: Int?
    var nickaseStrand: Bool?
    var RNATargetDirection: Bool? // false downstream, true upstream
    
    
    //Optional parameters
    var spacerLength: Int?
    var seedLength: Int?
    var targetOffset: Int?
    
    
    // NOT HERE: private var considerAlternatePAMsInOffTargets = true
    var useDatabase: Bool = false
    
    static let sharedInstance = RuntimeParameters()

    
    private init() {
    }
    
    internal func validateRuntimeParameters () throws -> Bool {
        var result : Bool = true
        // Check required parameters and there
        if source == nil || target == nil {
            if !hasValidTarget() {
                throw CLIError.Error ("ERROR: Cannot interpret target parameter \"\(target)\"")
            }
            //throw CLIError.Error ("Source file/directory and Target file are mandatory")
            // TODO: remove if in production...
            source = "/Users/ilap/Developer/Dissertation/Sequences/Source1/sequence.fasta"
        }
        
        if useDatabase {
            if nickaseStrand != nil {
                throw CLIError.Error ("ERROR: -n parameter is not valid in database mode")
            }
            
            if  endonuclease == nil {
                throw CLIError.Error ("ERROR: Nuclease name (-e parameter) is mandatory in database mode.")
            }
            
            let variants = Variant.select(selectRequest: Select.Where("name", .EqualsTo, endonuclease, .Ascending, "1"))! as! [Variant]
                
            if variants.isEmpty {
                   throw CLIError.Error ("ERROR: \"\(endonuclease!)\" endonuclease does not exist in the database.\nTry \"list -n\" for listing eexisting enzymes")
            }

            if variants.count != 1 {
                    throw CLIError.Error ("DATABASE ERROR: More then 1 endonuclease is found in the database (\"\(endonuclease!)\")")
            }
            
            let variant = variants[0]
            let p = PAM.select(selectRequest: Select.Where("variant_id", .EqualsTo, Int(variant.id!), .Ascending, "1"))! as! [PAM]

            let tpams = p.map { $0.sequence }
            if tpams.isEmpty && pams == nil {
                throw CLIError.Error ("DATABASE ERROR: No any associated PAMs in the database for \"\(variant.name)\" endonuclease. Use -p as workaround")
            }
            pams = tpams
                    // Update only the non set parameters.
            try setParametersFromDatabase(variant, force: false)
            
        } else {
            if  endonuclease != nil {
                throw CLIError.Error ("ERROR: Nuclease name (-e parameter) cannot be used in custom mode.")
            }
            
            if nickaseStrand != nil && (senseCutOffset == nil || antisenseCutOffset != nil) {
                print ("ANTI \(antisenseCutOffset) OR  \(senseCutOffset)")
                throw CLIError.Error ("ERROR: in \"cli\" mode use only one valid cut site for a nickase e.g. \"-n sense -c 4\"")
            }
            
        }
        print ("Description:")
        desc()


        
        return result
    }

    internal func desc () {
        print("Source: \(source)")
        print("Target: \(target)")
        print("-----")
        print("Target Start: \(targetStart)")
        print("Target End: \(targetEnd)")
        print("Endonuclease: \(endonuclease)")
        print("PAMs: \(pams)")
        print("-----")
        print("Cut site: +: \(senseCutOffset), - \(antisenseCutOffset)")
        print("Is nickase?: \(nickaseStrand)")
        print("Spacer length: \(spacerLength)")
        print("Seed length: \(seedLength)")
        print("Target offset: \(targetOffset)")
        print("Use database \(useDatabase)")
    }
    
    internal func setParametersFromDatabase (record: Variant, force: Bool) throws {
        //desc()
        if seedLength == nil {
            seedLength = record.seed_length
        }
        
        if spacerLength == nil {
            spacerLength = record.spacer_length
        }
        
        if RNATargetDirection == nil {
            RNATargetDirection  = record.guide_target_position
        }
        
        
        let nickase = record.sense_cut_offset == Int.min || record.antisense_cut_offset == Int.min
        
        if  nickase {
            print("NICKASE")
            if senseCutOffset != nil && antisenseCutOffset != nil  {
                throw CLIError.Error ("ERROR: Only one valid cut site is valid if nickase is used e.g. \"-n sense -c 4\"")
            }
            
            
        } else {
            if antisenseCutOffset == nil {
                antisenseCutOffset = senseCutOffset
            }
        }
        
        if senseCutOffset == nil && record.sense_cut_offset != Int.min {
            senseCutOffset = record.sense_cut_offset
        }
        
        if antisenseCutOffset == nil && record.antisense_cut_offset != Int.min {
            antisenseCutOffset = record.antisense_cut_offset
        }
        
        if senseCutOffset == nil && antisenseCutOffset == nil {
             throw CLIError.Error ("DATABASE ERROR: Inconsistent value for sense/anti sense cut position!")
        }
        
        if antisenseCutOffset != nil {
            nickaseStrand = true
        } else if antisenseCutOffset != nil {
            nickaseStrand = false
        }
        
        
    }
    
    private func hasValidTarget() -> Bool {
        var result: Bool = false
        //Check whetehr it's a gene in the annotated sequencfile
        // Check whether it's a
        
        // Check whether the it's a target position 
        if let _ = target, let start = Int(target!), let _ = targetEnd {
            targetStart = start
            result = true
        }

        return result
    }
    
    internal func reset() {
        
        source = nil
        target = nil
        targetSequence = nil
        targetLocation = nil
        targetStart = nil
        targetEnd =  nil
        
        endonuclease = nil
        
        pams = nil
        
        //Semi optional parameters
        senseCutOffset = nil
        antisenseCutOffset = nil
        nickaseStrand = nil
        RNATargetDirection = false // false downstream, true upstream
        
        
        //Optional parameters
        spacerLength = nil //20
        seedLength = nil
        targetOffset = nil

        useDatabase = false
    }
}