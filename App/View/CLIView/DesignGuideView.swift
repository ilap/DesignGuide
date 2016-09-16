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
        // Kick the update event first and then fire the request event.
        SwiftEventBus.post(name: DesignBusEventType.UpdateDesignGuideParameters.rawValue)
    }
    
    func showSourceGuides(sourceViewModel: SourceViewModel?) {

        //let targetViewModel = sourceViewModel?.targetViewModels.first!
        //targetViewModel?.loadGuides(guides: ontargets)
        
        print("Designed guideRNA(s) for species \"\((sourceViewModel?.name)!)\":")

        for targetViewModel in (sourceViewModel?.targetViewModels)! {
            
            var sep = ""
            if let first_guide = targetViewModel?.guideViewModels.first {
               sep = String(repeating: "|" as Character, count: (first_guide?.guide?.characters.count)!)
            } else {
                let start = (targetViewModel?.location)! - (targetViewModel?.offset)!
                let end = (targetViewModel?.location)! + (targetViewModel?.length)! + (targetViewModel?.offset)!
                
                print("No any \"guide RNA\" candidates in the region \"\(start)-\(end)\" genome region .\n")
                continue
            }
            var rank = 1
            // let g = (guideViewModelList[0]?.model)! as RNATarget
            for guide in (targetViewModel?.guideViewModels.sorted(isOrderedBefore: {
                $0?.score > $1?.score
            }))! {
                let i = (guide?.model)! as RNATarget
                
                var pseq = i.sequence!
                var nseq = i.complement!
                var gseq = pseq

                var ptail = "*"
                var ntail = " "
                
                let pam_len = i.pam?.characters.count
                let padded = String(i.pam!).padding(toLength: 10, withPad: " ", startingAt: 0)

                let prec = String(format: "%03.03f%", i.score!*100)
                
                if i.strand == "-" {
                    let a = pseq
                    pseq = nseq
                    nseq = a
                    ptail = " "
                    ntail = "*"
                    gseq = String(nseq.characters.reversed())
                }
                
                print("5'+\(pseq)+3'\(ptail)")
                print("   \(sep)    gRNA:\(gseq):\(i.strand!):\(prec)%:\(i.location!):\(i.sourceName!)")
                print("3'-\(nseq)-5'\(ntail)")
                print("")
                rank += 1

            }
        }
    }
    
    func showDesignDetails(sourceViewModelList: [SourceViewModel?],
                           parameters: DesignParameterProtocol,
                           nuclease: NucleaseViewModel?) throws {
        
        guard let _ = nuclease else {
            throw  BioSwiftError.fileError("DATABASE ERROR: the selected nuclease is not available in the database!")
    
        }
        print("Designing \"guide RNA(s)\" for the following species:")
        
        for sourceViewModel in sourceViewModelList {
            let species = sourceViewModel?.name
            print("Source: \(species!)")
        }
        print("\nDesign Parameters:")
        print("Protospacer length: \(parameters.spacerLength)")
        let pams = nuclease?.pamViewModels.map {
           ($0?.name)! + " (" + ($0?.survival)! + ")"
        }.joined(separator: ", ")
        
        let padded = String((nuclease?.name)! + ":").padding(toLength: 10, withPad: " ", startingAt: 0)
        
        print("Nuclease: \((nuclease?.name)!) - \(pams!)")
        
        print("It takes a while to finish the design, please be patient.\n")
    }
}
