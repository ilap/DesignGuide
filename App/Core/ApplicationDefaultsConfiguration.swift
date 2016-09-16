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


extension DefaultsKeys {
    // Defaults
    static let databasePath = DefaultsKey<String?>("databasePath")
    static let databaseFile = DefaultsKey<String?>("databaseFile")
    static let blobFilesPath = DefaultsKey<String?>("blobFilesPath")
}

class ApplicationDefaultsConfiguration {
    static let sharedInstance = ApplicationDefaultsConfiguration()
    
    private init() {
    }
    
    class func setDefaults() {
        // TODO: fix for Linux
        if var path = Bundle.main.resourcePath {
            
            path +=  "/database"
            let nameDatabase = "design_guide.sqlite"
            
            Defaults[.databasePath] = path
            Defaults[.databaseFile] = nameDatabase
            
            path += "/sequences"
            Defaults[.blobFilesPath] = path
            //debugPrint ("Database is set on:  \(Defaults[.databasePath])/\(Defaults[.databaseFile])")
        }
    }
}
