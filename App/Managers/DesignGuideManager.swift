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


class DesignGuideManager {
    var initialised: Bool? = nil
    var organismManager: DesignManagerModel?
    var targetManager: DesignManagerModel?
    
    var nucleaseManager: DesignManagerModel?
    var pamManager: DesignManagerModel?
    
    var dataStore : DataStore
    
    static let sharedInstance = DesignGuideManager()
    
    private init () {
        dataStore = SQLiteDataStore.sharedInstance
    }
    
    func view() {
        
    }
    
    internal func initialiseFromParameters(parameters: DesignGuideParameters) throws -> DesignGuideManager {
        // Initialise Manager singletons.
        organismManager = try OrganismManager.sharedInstance.initialise(parameters: parameters)
        targetManager = try ModelTargetManager.sharedInstance.initialise(organismManager, parameters: parameters)
        
        nucleaseManager = try NucleaseManager.sharedInstance.initialise(parameters: parameters)
        
        // Everything seems fine.
        initialised = true
        return self
    }
    
    func design () -> [CamembertModel] {
        guard let _ = initialised else { return [] }
        
        for (source, seqRecord) in (organismManager as! DesignableManagerModel).sequences {
            print("SOURCE:... \((source as! ModelOrganism).name) \(seqRecord.seq)")
            
            
        }
        
        return []
    }
}