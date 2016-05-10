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
 *  vars program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import SwiftCLI


class CommandLineCommand: DesignGuideCommand, OptionCommandType {
    
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
        options.onKeys(["-s", "--source"], usage: "Direcotry includes sequence files or a sequence file") {(key, value) in self
            self.parameters.source = value
        }
        
        options.onKeys(["-t", "--target"], usage: "Start position, sequence file or a gene name (if the source genome/file is annotated).", valueSignature: "target") {(key, value) in self
            self.parameters.target = value
        }
        
        options.onKeys(["-T", "--target-length"], usage: "Only valid if the target is a location.", valueSignature: "length") {(key, value) in self
            self.parameters.targetLength =  Int (value)
        }
        
        options.onKeys(["-e", "--endonuclease"], usage: "Available endonucleases - default is \"wtCas9\". Only valid with \"db\" parameter, use \"list -n\" command for Cas9/Cpf1 variants", valueSignature: "endonuclease" ) {(key, value) in self
            self.parameters.endoNuclease = value
        }
        
        options.onKeys(["-p", "--pam"], usage: "PAM sequence(s) e.g. \"NGG NAG\" - default is \"NGG\"", valueSignature: "PAMs" ) {(key, value) in self
            let pams = value.characters.split(" ").map(String.init)
            
            self.parameters.pams = pams
        }
        
        /*// Optional/semi optionla parameters
        //
        // Only valid in custom mode e.g. no Sqlite is used for endonuclease parameters.
        options.onKeys(["-c", "--cut-sites"], usage: "Cleavage sites relalive to PAM. Both valid values means DSB on different cleavage sites", valueSignature: "sense [antisense]") {(key, value) in self

            //TODO:  Value Checks...
            
            let sites = value.characters.split(" ").map { Int(String($0)) }
            if sites.count <= 2 {
                self.parameters.cutSites = sites
                for site in sites {
                    if site == nil {
                        self.parameters.cutSites = []
                    }
                }
            }
        }
        
        // Optional/semi optionla parameters
        //
        // Only valid in custom mode e.g. no Sqlite is used for endonuclease parameters.
        // Defaults: nil. As it's not valid if the enzyme is not a nickase.
        options.onKeys(["-n", "--nickase-strand"], usage: "Nick strand, if the endonuclease is a Nickase, default is \"sense\" (sense strand)", valueSignature: "sense|antisense") {(key, value) in self
            
            let upperCaseValue = value.uppercaseString
            if  upperCaseValue == "SENSE" {
                self.parameters.nickaseStrand = true
            } else if upperCaseValue == "ANTISENSE" {
                self.parameters.nickaseStrand = false
            } else {
               self.errorMessage = "ERROR: Nisckase strand (-n) must be either \"sense\" or \"antisense\""
            }
            
            
        }
        
        options.onKeys(["-d", "--rna-direction"], usage: "RNA target direction relative to PAM. Default: down (downstream)", valueSignature: "up|down") {(key, value) in self
            if value.uppercaseString == "UP" {
               self.parameters.rnaDirection = true
            } else if value.uppercaseString == "DOWN" {
                self.parameters.rnaDirection = false
            }  else {
               self.errorMessage = "ERROR: RNA direction (-d) must be either \"up\" or \"down\"!"
            }
        }*/
        
        options.onKeys(["-L", "--spacer-length"], usage: "RNA Spacer length, default: 17", valueSignature: "10-100") {(key, value) in self
            
            guard let spacer_length = Int(value) else { return }
            
            if spacer_length >= 0 && spacer_length <= 1000 {
                self.parameters.spacerLength = spacer_length
            } else {
                self.errorMessage = "ERROR: Spacer length (-L) must be between 10 and 100"
            }
        }
        
        options.onKeys(["-l", "--seed-length"], usage: "Seed length, default: 10", valueSignature: "0-100") {(key, value) in self

            guard let seedLength = Int(value) else { return }
            
            if seedLength >= 0 && seedLength <= 100 {
                self.parameters.seedLength = seedLength
            } else {
                self.errorMessage = "ERROR: Seed length (-l) must be between 0 and 100"
            }
        }
        
        options.onKeys(["-o", "--target-offset"], usage: "Extend target sequence size in the genome for design RNA on each sides of the target sequnce - default 0", valueSignature: "0-10000") {(key, value) in self
            
            guard let offset = Int(value) else {
                self.errorMessage = "ERROR: The target offset (\(value)) value is nut a number!"
                return
            }
            
            if offset >= 0 && offset <= 10000 {
                 self.parameters.targetOffset = offset
            } else {
                self.errorMessage = "ERROR: Target offset (-o) must be between 0 and 10000"
            }
           
        }
        
    }
    
    
    internal func validateRuntimeParameters () throws {

        if let _ = self.errorMessage {
            throw CLIError.Error(self.errorMessage!)
        }
        // Check required parameters and there
        if parameters.source == nil || parameters.target == nil || parameters.endoNuclease == nil {
            if !parameters.hasValidTargetWithTargetLength() {
                throw CLIError.Error ("ERROR: if target length (-T) present target (-t) must be a location (integer number)")
            }
            
            // TODO: remove after testing...
            //parameters.source = "/Users/ilap/Developer/Dissertation/Sequences/Source1/sequence.fasta"
            parameters.source = "/Users/ilap/Developer/Dissertation/Sequences/Source2"
            parameters.target = "250000"
            parameters.targetLength = 1
            parameters.endoNuclease = "wtCas9"
            parameters.pams = ["NGG", "NAG"]
        }
        

        if  parameters.endoNuclease == nil {
            throw CLIError.Error ("ERROR: Nuclease name (-e parameter) is mandatory in database mode.")
        }
    }


    func execute(arguments: CommandArguments) throws  {

        try validateRuntimeParameters()
        try initialiseAndExecute()
    }
}
