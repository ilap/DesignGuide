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

class WebAppCommand: DesignGuideCommand, OptionCommandType {

    override init () {}

    private var port: Int = 9000

    
    var commandName: String  {
        return "webapp"
    }
    
    var commandSignature: String  {
        return ""
    }
    
    var commandShortDescription: String  {
        return "Run Design Guide RNA Tool as Web Application"
    }
    
    func setupOptions(options: Options) {
        options.onKeys(["-p", "--listen-port"], usage: "Webapp's listening port - default 8000") {(key, value) in
            
            if let port = Int(value) {
                self.port = port
            }
        }
    }
    
    func execute(arguments: CommandArguments) throws  {
        
        print ("Starting as Web Application...")
        let webApp = WebAppView()
        webApp.show()
        
    }
    
    
}
