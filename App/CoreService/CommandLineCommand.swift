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

    var service: EnvironmentService

    init(service: EnvironmentService) {
        self.service = service
    }
    
    func setupOptions(_ options: Options) {
        
        options.onKeys(["-s", "--source"], usage: "Directory includes sequence file(s) or a sequence file") {(key, value) in self

            self.service.commandLineArgs[.Source] = value

        }
        
        options.onKeys(["-t", "--target"], usage: "Start position, sequence file or a gene name (if the source genome/file is annotated (has not implemented yet)).", valueSignature: "target") {(key, value) in self
            // Always must be String
            self.service.commandLineArgs[.Target] = value

        }
        
        options.onKeys(["-T", "--target-length"], usage: "Only valid if the target is a location e.g. start position.", valueSignature: "length") {(key, value) in self

            guard let length = Int(value) else {
                self.errorMessage = "ERROR: Target length (-T) must be integer."
                return
            }

            if length > 0 {

                 self.service.commandLineArgs[.TargetLength] = length
            } else {
                self.errorMessage = "ERROR: Target length (-T) must be positive number!"
            }

        }
        
        options.onKeys(["-e", "--endonuclease"], usage: "Available endonucleases - default is \"wtCas9\", use \"list -n\" command for obtaining supported Cas9/Cpf1 variants", valueSignature: "endonuclease" ) {(key, value) in self

            self.service.commandLineArgs[.Endonuclease] = value

        }
        
        options.onKeys(["-p", "--pam"], usage: "PAM sequence(s) e.g. \"NGG NAG\", must be a subset of the chosen nuclease's PAMs - default is all the PAMs of the chosen nuclease", valueSignature: "PAMs" ) {(key, value) in self
            let pams = value.characters.split(separator: " ").map(String.init)

            self.service.commandLineArgs[.UsedPAMs] = pams

        }
        
        options.onKeys(["-L", "--spacer-length"], usage: "RNA Spacer length - default is 17", valueSignature: "10-100") {(key, value) in self
            
            guard let spacer_length = Int(value) else {
                self.errorMessage = "ERROR: Spacer length (-L) must be integer."
                return
            }
            
            if spacer_length >= 0 && spacer_length <= 100 {

                self.service.commandLineArgs[.SpacerLength] = spacer_length
            } else {
                self.errorMessage = "ERROR: Spacer length (-L) must be between 10 and 100"
            }
        }
        
        options.onKeys(["-l", "--seed-length"], usage: "Seed length - default is 10", valueSignature: "0-100") {(key, value) in self

            guard let seedLength = Int(value) else  {
                self.errorMessage = "ERROR: Seed length (-l) must be integer."
                return
            }

            if seedLength >= 0 && seedLength <= 100 {

                self.service.commandLineArgs[.SeedLength] = seedLength
            } else {
                self.errorMessage = "ERROR: Seed length (-l) must be between 0 and 100"
            }
        }
        
        options.onKeys(["-o", "--target-offset"], usage: "Extend target sequence size in the genome for design RNA on each sides of the target sequnce - default is 0", valueSignature: "0-10000") {(key, value) in self
            
            guard let offset = Int(value) else {
                self.errorMessage = "ERROR: The target offset (\(value)) value is nut a number!"
                return
            }
            
            if offset >= 0 && offset <= 10000 {

                self.service.commandLineArgs[.TargetOffset] = offset

            } else {
                self.errorMessage = "ERROR: Target offset (-o) must be between 0 and 10000"
            }
        }
        
        options.onKeys(["-a", "--application"], usage: "Application e.g. [\"KO\", \"KI\", \"Activation\" or \"Repression\" - default is \"KO\"", valueSignature: "application" ) {(key, value) in self

            switch value as String {

            case GuideApplication.KO.rawValue,
                 GuideApplication.KI.rawValue,
                 GuideApplication.Activation.rawValue,
                 GuideApplication.Repression.rawValue :

                self.service.commandLineArgs[.ApplicationType] = value
            default:
                self.errorMessage = "ERROR: Application must be either of \"KO\", \"KI\", \"Activation\" or \"Repression\"."
            }
        }
    }
    
    
    internal func validateRuntimeParameters () throws {

        if let _ = self.errorMessage {
            throw CLIError.error(self.errorMessage!)
        }

        // TODO: remove after testing...
        self.service.commandLineArgs[.Source] = "/Users/ilap/Developer/Dissertation/Sequences/Source1in1"
        self.service.commandLineArgs[.Endonuclease] = "wtCas9"
        self.service.commandLineArgs[.Target] = "250000"
        //self.service.commandLineArgs[.TargetOffset] = 20
        self.service.commandLineArgs[.TargetLength] = 100

        //self.service.commandLineArgs[.UsedPAMs] = ["NAG"]

        if self.service.commandLineArgs[.Source] == nil ||
            self.service.commandLineArgs[.Target] == nil ||
            self.service.commandLineArgs[.Endonuclease] == nil {

            throw CLIError.error("ERROR: Source, target and nuclease parameters are mandatory.")

        }

        let target = self.service.commandLineArgs[.Target]

        // FIXME: Get rid of this
        let t = Int(target as! String)
        if t == nil {
            throw CLIError.error("ERROR: Currently, target can be only a location (integer number) ")
        }

        guard let _ = self.service.commandLineArgs[.TargetLength],
        let _ = Int(target as! String) else {
            throw CLIError.error("ERROR: If Target is a number (location) then the target length (-T) is mandatory")
        }
    }


    func execute(_ arguments: CommandArguments) throws  {
        try validateRuntimeParameters()

        let context = SqliteContext()
        let viewModel = GuideRNAPresenter(context: context)
        let view = GuideRNAListView(presenter: viewModel, service: service)

        view.show()

    }
}
