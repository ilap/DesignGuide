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

import BioSwift

class DesignGuideView : AnyView<DesignGuideViewProtocol>, DesignGuideViewProtocol {
    
    var source: String? = nil
    var target: Int? = nil
    var targetLength: Int? = nil
    var nuclease: String? = nil
    
    required init(presenter: AnyPresenter<DesignGuideViewProtocol>, optionService: DesignOptionsService) {
        super.init(presenter: presenter, optionService: optionService)
    }
    
    func updateDesignParameters(parameters: DesignParameterProtocol) {
        
        // debugPrint( #file + ":" + String(#line) + " - Parameters are updating:")
        
        self.source = optionService.options[.Source] as! String?
        self.target = optionService.options[.Target] as! Int?

        self.targetLength = optionService.options[.TargetLength] as! Int?
        self.nuclease = optionService.options[.Endonuclease] as! String?
        
        /// Other parameters for designing guides.
        parameters.spacerLength = optionService.options[.SpacerLength] as! Int? ?? parameters.spacerLength
        
        // TODO: seed length must be set as it's a user parameter
        parameters.seedLength = optionService.options[.SeedLength] as! Int? ?? parameters.seedLength
        
        /// Target
        // if it's not defined then it's always 0
        parameters.targetOffset = optionService.options[.TargetOffset] as! Int?  ?? parameters.targetOffset
        
        /// Other parameters
        parameters.spacerLength = optionService.options[.SpacerLength] as! Int? ?? parameters.spacerLength
        
        // TODO: seed length must be set as it's a user parameter
        parameters.seedLength = optionService.options[.SeedLength] as! Int? ?? parameters.seedLength
        
        /// Target
        // if it's not defined then it's always 0
        parameters.targetOffset = optionService.options[.TargetOffset] as! Int? ?? parameters.targetOffset
    
        SwiftEventBus.post(name: DesignBusEventType.NucleaseSelected.rawValue,
                        sender: self.nuclease)
        SwiftEventBus.post(name: DesignBusEventType.DesignGuideRequest.rawValue)

    }
    
    override func show() {
        //XXX: ilap debugPrint("MVP-VM: " +  #function  )
        // Kick the update event first and then fire the request event.
        SwiftEventBus.post(name: DesignBusEventType.UpdateDesignGuideParameters.rawValue)
    }
    
    func showGuides(guideViewModelList: [GuideViewModel?]) {

        print("Designed guideRNA(s):\n")
        let g = (guideViewModelList[0]?.model)! as RNAOnTarget
        let str = String(repeating: "|" as Character, count: (g.sequence?.characters.count)!)

        for guide in guideViewModelList {
            let i = (guide?.model)! as RNAOnTarget
            var s = i.sequence
            var ss = "*"
            var c = i.complement
            var cc = " "
            
            if i.strand == "-" {
                s = i.complement
                c = i.sequence
                ss = " "
                cc = "*"
            }
            print("")
            print("+:\t\t\t\t\(ss)\(s!)")
            let prec = String(format: "%.3f%", i.score!)
            print("\(prec):\(i.location!)\t\t \(str)\t\(i.speciesName!)")
            print("-:\t\t\t\t\(cc)\(c!)")
            print("")

        }
    }
}
