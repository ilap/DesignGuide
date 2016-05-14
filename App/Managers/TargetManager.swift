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

class ModelTargetManager: DesignManagerModel {
    
    static let sharedInstance = ModelTargetManager()
    
    var items: [CamembertModel] = []
    
    func initialise (depends: DesignManagerModel? = nil, parameters: DesignGuideParameters) throws  -> DesignManagerModel? {
        guard let _ = depends else {
            //debugPrint("FATAL ERROR: Model target needs a ModelOrganism")
            throw ModelError.ParameterError("FATAL ERROR: Model target needs a ModelOrganism")
        }
        
        //debugPrint("\(__FILE__):\(__LINE__):invoked")
        
        var targetOffset: Int? = parameters.targetOffset
        if let _ = parameters.target, let targetLocation = Int(parameters.target!), let targetLength = parameters.targetLength {
            // Length can be 1 as point mutation. but the offset must be set at least 20 bases
            // on both stream...

            if targetLength < 20  && targetOffset < 20 {
                // parameter's target offset must be set.
                //parameters.targetOffset = Int(20)
                targetOffset = 20
            }

            //It's location target...
            for item  in depends!.items {
                
                let modelId = item.id!
                
                let targets = ModelTarget.findForModelOrganism(["model_organism_id", "location", "length"], value: [modelId, targetLocation, targetLength])
                
                if targets.isEmpty {
                
                    let target = ModelTarget()
                    target.model_organism_id = modelId
                    target.name = "location_" + String(targetLocation)
                    target.location = targetLocation
                    target.length = targetLength
                    //print ("TARGET OFFSET: \(targetOffset) DEFAULT VALUE \(target.offset)")
                    target.offset = targetOffset ?? target.offset // Set to default
                    target.type = TargetType.Location.rawValue
                    target.descr = "Automatically generated based on Location and length"
                    
                    //print("ADD NEW TARGET \(target)")
                    items.append(target)
                    target.push()
                } else {
                    //print("ADD EXISITNG TARGET \(targets.first!)")
                    items.append(targets.first!)
                }
            }
 
        } else {
            //debugPrint("FATAL: Currently just the location and length supported. Given parameters are: \n Use -t <location> -T <target length> \n\(parameters.parametersDescription())")
            throw ModelError.ParameterError("FATAL: Currently just the location and length supported. Given parameters are: \n Use -t <location> -T <target length> \n\(parameters.parametersDescription())")
        }
        
        return self
    }
}