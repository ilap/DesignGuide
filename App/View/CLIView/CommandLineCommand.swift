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
    
    let parameters = RuntimeParameters.sharedInstance

    
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
        
        // Mandatory parameters
        options.onKeys(["-s", "--source"], usage: "Direcotry or a sequence file") {(key, value) in
            self.parameters.source = value
        }
        
        options.onKeys(["-t", "--target"], usage: "Start position, sequence file or a gene name (if the source file is annotated).", valueSignature: "target") {(key, value) in
            self.parameters.target = value
        }
        
        options.onKeys(["-T", "--target-length"], usage: "Target length if the \"target\" is a position and not a gene name or sequence file", valueSignature: "length") {(key, value) in
            self.parameters.targetEnd = Int (value)
        }
        
        options.onKeys(["-e", "--endonuclease"], usage: "Available endonucleases - default: \"wtCas9\", use \"see list -n\" command for Cas9 variants", valueSignature: "endonuclease" ) {(key, value) in
           self.parameters.endonuclease = value
        }
        
        options.onKeys(["-p", "--pam"], usage: "PAM sequence - default is \"NGG\"", valueSignature: "PAMs" ) {(key, value) in
            let pams = value.characters.split(" ").map(String.init)
            self.parameters.pams = pams
        }

        
        // Optional/semi optionla parameters
        //
        // Only valid in custom mode e.g. no Sqlite is used for endonuclease parameters.
        options.onKeys(["-c", "--cut-sites"], usage: "Cleavage sites relalive to PAM. Both valid values means DSB on different cleavage sites", valueSignature: "sense [antisense]") {(key, value) in
            
            
            let cuts = value.characters.split(" ").map(String.init)
            
            self.parameters.senseCutOffset = Int(cuts[0])
            // TODO: If nickase is set the first value is used for the cut site.
            if cuts.count > 1 {
                self.parameters.antisenseCutOffset = Int(cuts[1])
            }
        }
        // Optional/semi optionla parameters
        //
        // Only valid in custom mode e.g. no Sqlite is used for endonuclease parameters.
        // Defaults: nil. As it's not valid if the enzyme is not a nickase.
        options.onKeys(["-n", "--nickase-strand"], usage: "Nick strand, if the endonuclease is a Nickase, default is \"sense\" (sense strand)", valueSignature: "sense|antisense") {(key, value) in

            let upperCaseValue = value.uppercaseString
            if  upperCaseValue == "SENSE" {
                self.parameters.nickaseStrand = true
            } else if upperCaseValue == "ANTISENSE" {
                self.parameters.nickaseStrand = false
            }
            
            
        }
        
        options.onKeys(["-d", "-rna-direction"], usage: "RNA target direction relative to PAM. Default: down (downstream)", valueSignature: "up|down") {(key, value) in
            
            // Default is false, means downstream
            var direction = false
            if value == "+" {
                direction = true
            }
            
            self.parameters.RNATargetDirection = direction
        }
        
        options.onKeys(["-L", "--spacer-length"], usage: "RNA Spacer length, default: 17", valueSignature: "10-1000") {(key, value) in
            
            guard let spacer_length = Int(value) else { return }
            
            if spacer_length >= 0 && spacer_length <= 1000 {
                self.parameters.spacerLength = spacer_length
            }
        }
        
        options.onKeys(["-l", "--seed-length"], usage: "Seed length, default: 10", valueSignature: "0-100") {(key, value) in
            
            guard let seed_length = Int(value) else { return }
            
            if seed_length >= 0 && seed_length <= 100 {
                self.parameters.seedLength = seed_length
            }
        }
        
        options.onKeys(["-l", "--seed-length"], usage: "Seed length, default: 10", valueSignature: "0-100") {(key, value) in
            
            guard let seed_length = Int(value) else { return }
            
            if seed_length >= 0 && seed_length <= 100 {
                self.parameters.seedLength = seed_length
            }
        }
        
        options.onKeys(["-o", "--target-offset"], usage: "Extend target sequence size in the genome for design RNA on each sides of the target sequnce - default 0", valueSignature: "0-10000") {(key, value) in
            
            guard let offset = Int(value) else { return }
            
            if offset >= 0 && offset <= 10000 {
                self.parameters.targetOffset = offset
            }
        }

    }

    func execute(arguments: CommandArguments) throws  {
        //ILAP: print ("Starting as CLI Application...")
        
        if let _ = arguments.optionalArgument("db") {
            //ILAP: print("Existing sqlite database is used for parameters")
            self.parameters.useDatabase = true
        }
        
        try self.parameters.validateRuntimeParameters()
        
        
        //ILAP: print("DESC \(parameters.desc())")
        
        
        let view = CommandLineView()
        try view.execute()
        
    }
    
    
}
