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

import Foundation
import SQLite

enum DataAccessLayerError: ErrorType {
    case ConnectionError
    case InsertError
    case Deleterror
    case FindError
    case NilError
}

protocol DataStore {
    var initialised : Bool { get }
}

class SQLiteDataStore : DataStore {
    
    var initialised : Bool = false
    //let path =  NSBundle.mainBundle().pathForResource("base", ofType: "sqlite", inDirectory: "Database")
    
    static let sharedInstance = SQLiteDataStore()
    
    private init() {
        if let path = Defaults[.databasePath], let nameDatabase = Defaults[.databaseFile] {
            self.initialised = Camembert.initDataBase(path, nameDatabase: nameDatabase)
        }
    }
    
    /* TODO: func createTables() throws{
        do {
            try SomeDataHelper.createTable()

        } catch {
            throw DataAccessLayerError.ConnectionError
        }
    }*/
}


