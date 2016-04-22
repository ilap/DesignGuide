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
    
    private var path: String? = nil
    private var pam: String? = "NGG"
    private var spacerLength: Int = 17
    private var targetPath: String? = nil
    private var targetLocation: Int = 0
    private var targetStart: Int = 0
    private var targetEnd:  Int = 0
    private var targetOffset: Int = 0

    var commandName: String  {
        return "cli"
    }
    
    var commandSignature: String  {
        return ""
    }
    
    var commandShortDescription: String  {
        return "Run Design Guide RNA Tool as CLI"
    }
    
    func setupOptions(options: Options) {
        options.onKeys(["-d", "--directory"], usage: "Direcotry or a sequence file") {(key, value) in
            self.path = value
        }
        
        options.onKeys(["-p", "--pam"], usage: "PAM sequence or Cas9 variant default is \"NGG\" - see list command for Cas9 variants") {(key, value) in
            self.spacerLength = Int(value)!
        }
        
        options.onKeys(["-l", "--target-location"], usage: "Spacer length - default is 17") {(key, value)
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
        
        let view = CommandLineView()
        view.execute()
        
    }
    
    
}
