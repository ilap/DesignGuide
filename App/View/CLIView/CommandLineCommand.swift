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

import SwiftCLI
import SQLite


class CommandLineCommand: OptionCommandType {

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
    //  2. -n "<+|->": Nickase, means only one cut site. - Default is "+", means antisense.
    //      Note: Not valid if two cut sites are given.
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
    private var source: String? = nil
    
    private var target: String? = nil
    private var targetSequence: String? = nil
    private var targetLocation: Int = 0
    private var targetStart: Int = 0
    private var targetEnd:  Int = 0
    
    private var pam: String? = "NGG"

    //Semi optional parameters
    private var senseCutOffset: Int = 0
    private var antisenseCutOffset: Int = 0
    private var isNickase: Bool = false
    
    private var pamDirection: Bool = false // false downstream, true upstream
    
    
    //Optional parameters
    private var spacerLength: Int = 20
    private var seedLength: Int = 10
    private var targetOffset: Int = 0
    

    // NOT HERE: private var considerAlternatePAMsInOffTargets = true
    private var useDatabase: Bool = false
    
    var commandName: String  {
        return "cli"
    }
    
    var commandSignature: String  {
        return "[<db>]"
    }
    
    var commandShortDescription: String  {
        return "Run Design Guide RNA Tool as CLI"
    }
    
    func setupOptions(options: Options) {
        options.onKeys(["-s", "--source"], usage: "Direcotry or a sequence file") {(key, value) in
            self.source = value
        }
        options.onKeys(["-t", "--target"], usage: "Sequence file, gene name or start position and its length.", valueSignature: "start end") {(key, value) in
            self.target = value
        }
        options.onKeys(["-e", "--endonuclease"], usage: "Available endonucleases - default: \"wtCas9\", use \"see list -n\" command for Cas9 variants", valueSignature: "endonuclease" ) {(key, value) in
            //self.spacerLength = Int(value)!
            print("VALUE: \(value)")
        }
        
        options.onKeys(["-p", "--pam"], usage: "PAM sequence - default is \"NGG\"", valueSignature: "PAMs" ) {(key, value) in
            //self.spacerLength = Int(value)!
            print("VALUE: \(value)")
        }


        
        
        options.onKeys(["-s", "--spacer-length"], usage: "Spacer length - default is 20", valueSignature: "length" ) {(key, value) in
            //self.spacerLength = Int(value)!
        }

       
        
        options.onKeys(["-l", "--target-location"], usage: "Target location - StrPosition of ") {(key, value)
            in
            if let location = Int(value) {
                self.targetLocation = location
            }
        }
        
        options.onKeys(["-o", "--target-offset"], usage: "Target offset relative to target location", valueSignature: "0-10000") {(key, value) in
            
            if let offset = Int(value) {
                self.targetOffset = offset
            }
            
        }
    }

    
    func execute(arguments: CommandArguments) throws  {
        print ("Starting as CLI Application...")
        
        if let _ = arguments.optionalArgument("db") {
            useDatabase = true
        }
        
        //let view = CommandLineView()
        //view.execute()
        
    }
    
    
}
