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
    
    static let sharedInstance = DesignGuideManager()
    
    private init () {
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
    
    func design() throws -> [CamembertModel] {
        guard let _ = initialised else { return [] }

        let nm = nucleaseManager as! NucleaseManager
        let pams = nm.pams.map{ ($0 as! PAM).sequence }

        //print("PAMS \(pams)")
        let pamLength=pams.first?.characters.count

        let spacerLength = nm.items.map{($0 as! Nuclease).spacer_length }

        print("SPACER LENGTH: \(spacerLength)")
        var result: [String] = []
        var pamArray = [(Int,Int)](count:14000, repeatedValue: (0,0))

        let tstart = NSDate()
        for target in targetManager!.items as! [ModelTarget] {
            //print("MODELORG: \(target.model_organism_id)")
            if let seqRecord = (organismManager as! OrganismManager).getSeqRecordById(target.model_organism_id) {

                let start=target.location-spacerLength.first!
                let end=target.location+target.length+target.offset

                let tend = NSDate()
                let rnaTargets = seqRecord.seq.getOnTargets(pams, start: start, end: end)
                let timeInterval: Double = tend.timeIntervalSinceDate(tstart);
                print("Time to evaluate problem \(timeInterval) seconds");

                //print("RNA TARGETS \(rnaTargets)")

                var validLocation = 0
                var strand = "+"
                var pamPos = 0
                var s = 0
                var e = 0
                for pamLocation in rnaTargets! {
                    print ("PAMLOCATION \(pamLocation)")
                    if  pamLocation < 0 {
                        validLocation = -pamLocation
                        pamPos = validLocation + pamLength!
                        strand = "-"
                        s=Int(pamPos)-pamLength!-1
                        e=Int(pamPos)+spacerLength.first!
                    } else {
                        validLocation = pamLocation
                        pamPos = validLocation
                        strand = "+"
                        s=Int(pamPos)-spacerLength.first!
                        e=Int(pamPos)+pamLength!-1
                    }


                    //result.append(seqRecord.seq[s...e])
                    print("SE: \(s), \(e)")
                    print ("GUIDE: Strand: \(strand), Location:\(seqRecord.seq[s...e])")
                }
                print ("GUIDES: \(result)")

            } else {
                //debugPrint("\(__FILE__):\(__LINE__):NO SEQUENCE FOUND")
                throw ModelError.Error("\(__FILE__):\(__LINE__):NO SEQUENCE FOUND")
            }

        }



        return []
    }
}