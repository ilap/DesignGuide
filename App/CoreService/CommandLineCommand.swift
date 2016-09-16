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
 * This program is distributed in the hope that it will be useful,
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
        return ""
    }
    
    var commandShortDescription: String  {
        return "Run Design Guide RNA Tool as CLI"
    }

    var service: DesignOptionsService

    init(service: DesignOptionsService) {
        self.service = service
    }
    
    func setupOptions(_ options: Options) {
        
        options.onKeys(["-s", "--source"], usage: "Directory includes sequence file(s) or a sequence file.") {(key, value) in self

            self.service.options[.Source] = value

        }
        
        options.onKeys(["-t", "--target"], usage: "Start position. The sequence file or a gene name (if the source genome/file is annotated) as target parameter has not implemented yet).", valueSignature: "location") {(key, value) in self
            // Always must be String
            self.service.options[.Target] = value
        }
        
        options.onKeys(["-T", "--target-length"], usage: "Only valid if the target is a location e.g. start position.", valueSignature: "length") {(key, value) in self

            guard let length = Int(value) else {
                self.errorMessage = "ERROR: Target length (-T) must be a positive integer."
                return
            }

            if length > 0 {

                 self.service.options[.TargetLength] = length
            } else {
                self.errorMessage = "ERROR: Target length (-T) must be greater than 0!"
            }

        }
        
        options.onKeys(["-e", "--endonuclease"], usage: "Available endonucleases - default is \"wtCas9\", use \"list -n\" command for obtaining supported Cas9/Cpf1 variants.", valueSignature: "endonuclease" ) {(key, value) in self

            self.service.options[.Endonuclease] = value

        }
        
        /* 
         FIXME: Add this feature later 
         options.onKeys(["-p", "--pam"], usage: "PAM sequence(s) e.g. \"NGG NAG\", must be a subset of the chosen nuclease's PAMs - default is all the PAMs of the chosen nuclease", valueSignature: "PAMs" ) {(key, value) in self
            let pams = value.characters.split(separator: " ").map(String.init)

            self.service.options[.UsedPAMs] = pams

        }
        */
        
        options.onKeys(["-L", "--spacer-length"], usage: "RNA Spacer length - default is 20.", valueSignature: "10-100") {(key, value) in self
            
            guard let spacer_length = Int(value) else {
                self.errorMessage = "ERROR: Spacer length (-L) must be integer."
                return
            }
            
            if spacer_length >= 0 && spacer_length <= 100 {

                self.service.options[.SpacerLength] = spacer_length
            } else {
                self.errorMessage = "ERROR: Spacer length (-L) must be between 10 and 100"
            }
        }
        
        options.onKeys(["-l", "--seed-length"], usage: "Seed length - default is 10 (currently not used).", valueSignature: "0-100") {(key, value) in self

            guard let seedLength = Int(value) else  {
                self.errorMessage = "ERROR: Seed length (-l) must be integer."
                return
            }

            if seedLength >= 0 && seedLength <= 100 {

                self.service.options[.SeedLength] = seedLength
            } else {
                self.errorMessage = "ERROR: Seed length (-l) must be between 0 and 100"
            }
        }
        
        options.onKeys(["-o", "--target-offset"], usage: "Extend target sequence size in the genome for design RNA on each sides of the target sequnce - default is 0.", valueSignature: "0-10000") {(key, value) in self
            
            guard let offset = Int(value) else {
                self.errorMessage = "ERROR: The target offset (\(value)) value is nut a number!"
                return
            }
            
            if offset >= 0 && offset <= 10000 {

                self.service.options[.TargetOffset] = offset

            } else {
                self.errorMessage = "ERROR: Target offset (-o) must be between 0 and 10000"
            }
        }
        
        /*
        FIXME: Add this feature later
        options.onKeys(["-a", "--application"], usage: "Application e.g. [\"KO\", \"KI\", \"Activation\" or \"Repression\" - default is \"KO\"", valueSignature: "application" ) {(key, value) in self

            switch value as String {

            case GuideApplication.KO.rawValue,
                 GuideApplication.KI.rawValue,
                 GuideApplication.Activation.rawValue,
                 GuideApplication.Repression.rawValue :

                self.service.options[.ApplicationType] = value
            default:
                self.errorMessage = "ERROR: Application must be either of \"KO\", \"KI\", \"Activation\" or \"Repression\"."
            }
        }
         */
    }
    
    
    internal func validateRuntimeParameters () throws {
        if let _ = self.errorMessage {
            throw CLIError.error(self.errorMessage!)
        }

        if self.service.options[.Source] == nil ||
            self.service.options[.Target] == nil ||
            self.service.options[.Endonuclease] == nil {

            throw CLIError.error("ERROR: Source, target and nuclease parameters are mandatory.")

        }

        let target = self.service.options[.Target]

        // FIXME: Get rid of this
        let t = Int(target as! String)
        if t == nil || t < 0 {
            throw CLIError.error("ERROR: Currently, target can be only a location (positive integer number) ")
        }

        guard let _ = self.service.options[.TargetLength],
        let _ = Int(target as! String) else {
            throw CLIError.error("ERROR: If Target is a number (location) then the target length (-T) is mandatory")
        }
        self.service.options[.Target] = t
    }

    func execute(_ arguments: CommandArguments) throws  {

        try validateRuntimeParameters()

        let context = SqliteContext()

        let dao = AnyRepository<Nuclease>(context: context)
        let pamDao = AnyRepository<PAM>(context: context)
        
        let nucleasePresenter = NucleaseCollectionPresenter(dao: dao, pamDao: pamDao)
        _ = NucleasesCollectionCLIView(presenter: nucleasePresenter, optionService: service)
        
        let presenter = DesignManagerPresenter(context: context, service: service)
        let view = DesignGuideView(presenter: presenter, optionService: service)

        
        view.show()

    }
}
