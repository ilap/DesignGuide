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
import Foundation




class CommandLineListCommand: OptionCommandType {
    
    private var listNuclease: Bool = false
    private var listExperiment: Bool = false

    var commandName: String  {
        return "list"
    }
    
    var commandSignature: String  {
        return ""
    }
    
    var commandShortDescription: String  {
        return "List base database - items = cas9, experiments, targets, sources"
    }
    
    func setupOptions(options: Options) {
        options.onFlags(["-e", "--experiments"], usage: "List experiments by users and date") {(flag) in
            self.listExperiment = true
        }
        options.onFlags(["-n", "--nucleases"], usage: "List nucleases with known PAMs") {(flag) in
            self.listNuclease = true
        }
        
    }

    func execute(arguments: CommandArguments) throws  {
        if listExperiment {
            print ("Conducted experiments")
        } else if listNuclease {
            print("Available nucleases with PAMs and PAMs' default affinity:")
            Variant.printWithOriginEndPAM()
        } else {
            print("CSH \(self.commandShortcut)")
        }
                
    }
}
