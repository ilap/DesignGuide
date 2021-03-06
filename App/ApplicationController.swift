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

public class ApplicatonController {
    static var configured: Bool = false
    
    private static func setup() {
        // TODO: Use dependency injection instead
        // Singleton for initialising the Settings application level
        ApplicationDefaultsConfiguration.setDefaults()

        let envService = DesignGuideOptions()


        let defaultCommand = CommandLineCommand(service: envService)
        //let defaultCommand = CommandLineListCommand(service: envService)
        //let defaultCommand = WebAppCommand()
        //let defaultCommand = GraphicalUserInterfaceCommand(service: envService)
        CLI.registerCommand(defaultCommand)

        
        //CLI.registerCommand(CommandLineCommand(service: envService))
        CLI.registerCommand(CommandLineListCommand(service: envService))
        // FIXME: Add this when Express is available for Swift 3
        // CLI.registerCommand(WebAppCommand())
        CLI.registerCommand(GraphicalUserInterfaceCommand())

        // Run as the default Web App
        CLI.router = DefaultRouter(defaultCommand: defaultCommand)
        
        // Initialise database before start the app...
        //TODO: Use dependency injection instead...
    }
    
    static func run() -> CLIResult {
        if !configured {
            setup()
        }
        return CLI.go()
    }
}
