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

public class ApplicatonController {
    
    static var configured: Bool = false
    
    private static func setup() {
        let defaultCommand = CommandLineCommand()
        //let defaultCommand = WebAppCommand()
        //let defaultCommand = CommandLineListCommand()
        CLI.registerCommand(defaultCommand)
        
        //CLI.registerCommand(CommandLineCommand())
        CLI.registerCommand(WebAppCommand())
        CLI.registerCommand(GraphicalUserInterfaceCommand())
        CLI.registerCommand(CommandLineListCommand())
        
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
