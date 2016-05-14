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

class NucleaseManager: DesignManagerModel {
    var pamManager: DesignManagerModel? = nil
    var seed_length: Int? = nil
    var spacer_length: Int? = nil
    
    static let sharedInstance = NucleaseManager()
    
    var items: [CamembertModel] = []
    var pams: [CamembertModel] = []
    
    func initialise(depends: DesignManagerModel? = nil, parameters: DesignGuideParameters) throws  -> DesignManagerModel? {
        
        //debugPrint("\(__FILE__):\(__LINE__):invoked")
        if let enzyme = parameters.endoNuclease {
            let nuclease = Nuclease.findByName(enzyme) as [CamembertModel]
            if nuclease.isEmpty || nuclease.count > 1 {
                //debugPrint("DATABASE ERROR: Endonuclease variant \"\(nuclease)\" is not in or duplicated in the database")
                throw ModelError.Error("DATABASE ERROR: Endonuclease variant \"\(nuclease)\" is not in or duplicated in the database")
            } else {
                
                items = nuclease
                let nuclease_id = (nuclease.first as! Nuclease).id!
               
                let nucleasePAMs = PAM.findByValue("nuclease_id", value: nuclease_id)
                
                if let pamStrings = parameters.pams {
                    let pamSet = Set(pamStrings)
                    let pamDbSet = Set(nucleasePAMs.map { $0.sequence} )
                    
                    // First check whether the pam sequences provided in the parameters are exists in the Database
                    for pam in pamStrings {
                        if !pamDbSet.contains(pam) {
                            //debugPrint("ERROR: PAM sequence \(pam) is not in the Database \(pamDbSet)")
                            throw ModelError.Error("ERROR: PAM sequence \(pam) is not in the Database \(pamDbSet)")
                        }
                    }
                    
                    // Then add the existing PAM object to the PAM array
                    for pam in nucleasePAMs {
                        if pamSet.contains (pam.sequence) {
                            pams.append(pam)
                        }
                    }
                    if pams.isEmpty {
                        //debugPrint("ERROR: No any PAMs \(pamSet) for variant \(parameters.endoNuclease!) are not found in database")
                        throw ModelError.Error("ERROR: No any PAMs \(pamSet) for variant \(parameters.endoNuclease!) are not found in database")
                    } else {
                        //print("PAMS \(pams)")
                    }
                    
                } else {
                    pams = nucleasePAMs
                }
                
            }
        } else {
            // debugPrint("No endonuclease specified!")
            throw ModelError.Error("No endonuclease specified!")
        }
        
        return self
    }
}