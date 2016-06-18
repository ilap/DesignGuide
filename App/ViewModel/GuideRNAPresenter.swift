
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


import BioSwift

public class GuideRNAPresenter {

    ///
    /// Model managers
    ///
    var organismManager: AnyRepository<ModelOrganism>
    var targetManager: AnyRepository<ModelTarget>
    var nucleaseManager: AnyRepository<Nuclease>
    var pamManager: AnyRepository<PAM>

    ///
    /// Commands
    ///
    var listGuideRNACommand : Command? = nil


    ///
    /// properties for the View
    ///
    private var _organisms: [ModelOrganism] = []

    private var _nuclease: Nuclease? = nil
    private var _targets: [ModelTarget] = []
    private var _allPAMs: [PAM] = []
    private var _usedPAMs: [PAM] = []

    private var _pamLength: Int = 0

    private var _location: Int? = nil

    var target: String? = nil
    var targetLength: Int? = nil
    var targetOffset: Int? = nil

    var seedLength: Int? = nil
    var spacerLength: Int? = nil

    var nuclease: String? {
        get {
            if let n = _nuclease {
                return n.name
            } else {
                return nil
            }
        }

        set {

            guard let _ = newValue else {
                print("NEWV \(newValue)")
                self._nuclease = nil
                return
            }

            self._nuclease = getNuclease(newValue!)
        }
    }

    var allPAMs: [String] {
        get {
            if let _ = _nuclease {

                self._allPAMs = pamManager.getByValue("nuclease_id", value: _nuclease!.id!) as [PAM]
                assert(!_allPAMs.isEmpty, "DATABASE ERROR: There is no PAM for nuclease ID:\(_nuclease!.id!)")
                return self._allPAMs.map { $0.sequence }

            } else {
                return []
            }
        }

    }

    var usedPAMSequences: [String]  {
        get {
            if !_usedPAMs.isEmpty {
                return _usedPAMs.map { $0.sequence }
            } else {
                return []
            }
        }
        set {
            //debugPrint ("NEWVALUE: \(newValue)")
            //assert(!newValue.isEmpty, "ERROR: At least one sequence must be chosen.")
            let pams = self.allPAMs

            self._pamLength = pams.first!.characters.count
            if newValue == [] {
                _usedPAMs = _allPAMs
                return
            } else {
                let pamSet = Set(newValue)
                let pamDbSet = Set(_allPAMs.map { $0.sequence} )

                // First check whether the pam sequences provided in the parameters are exists in the Database
                for pam in newValue {
                    if !pamDbSet.contains(pam) {
                        // Invalid parameter
                        _usedPAMs = []
                        return
                    }
                }

                // Then add the existing PAM object to the PAM array
                // everything sems good
                _usedPAMs = []
                for pam in _allPAMs {
                    if pamSet.contains (pam.sequence) {
                        _usedPAMs.append(pam)
                    }
                }
            }


            /*if let _ = _nuclease {
                let allPAMs = pamManager.getByValue("nuclease_id", value: _nuclease!.id!) as [PAM]
                assert(!allPAMs.isEmpty, "DATABASE ERROR: There is no PAM for nuclease ID:\(_nuclease!.id!)")

                self._pamLength =  (allPAMs.map { $0.sequence }.first?.characters.count)!
                
                // FIXME: handle the intial empty array
                if newValue == [] {
                    _usedPAMs = allPAMs
                    return
                }

                let pamSet = Set(newValue)
                let pamDbSet = Set(allPAMs.map { $0.sequence} )

                // First check whether the pam sequences provided in the parameters are exists in the Database
                for pam in newValue {
                    if !pamDbSet.contains(pam) {
                        // Invalid parameter
                        _usedPAMs = []
                        return
                    }
                }

                // Then add the existing PAM object to the PAM array
                // everything sems good
                _usedPAMs = []
                for pam in allPAMs {
                    if pamSet.contains (pam.sequence) {
                        _usedPAMs.append(pam)
                    }
                }

                //pamSequences.first?.characters.count
                //print( _usedPAMs.map{ $0.sequence})
                */

        }
    }


    var sourceFile: String? = nil {
        willSet {
            print("Source File is: \(newValue!)")
        }
    }

    init (context: DataContext) {
        nucleaseManager =  NucleaseModelManager(context: context)
        pamManager =  PamModelManager(context: context)

        organismManager =  OrganismModelManager(context: context)
        targetManager = TargetModelManager(context: context)

        self.listGuideRNACommand = RelayCommand(action: listGuideRNA/*, canExecute: canExecute*/)
    }

    func initialiseComponents() throws {

        if usedPAMSequences.isEmpty {
            throw ModelError.parameterError("FATAL ERROR: Improper values in used PAMs (empty or bad)!")
        }
        let om = organismManager as! OrganismModelManager

        self._organisms = try om.getOrganismsFromFileOrDB(sourceFile) as! [ModelOrganism]

        let tm = targetManager as! TargetModelManager

        self._targets = []
        self._location = Int(self.target!)

        for organism in self._organisms {
            //debugPrintprint(organism)
            // Currently jsut the location is supported


            if self._location >= organism.sequence_length -
                (self.targetOffset! + self.targetLength! + 1) {
                throw ModelError.parameterError("FATAL ERROR: The location \(self._location!) is beyond the size \(organism.sequence_length) of the source sequence!")
            }

            if self._location != nil {
                let targets = tm.getOrCreateTargetsFromLocation(organism.id!,
                                                                location: self._location!,
                                                                length: self.targetLength!,
                                                                offset: self.targetOffset!) as! [ModelTarget]

                self._targets += targets
            } else {
                assertionFailure("Only target location is supported yet.")
            }
        }

        if self.spacerLength == nil {
            self.spacerLength = getNuclease(self.nuclease!).spacer_length
        }
        //debugPrint("Organisms \(self._organisms), TARGETS: \(self._targets)")
    }


    func getNuclease(_ name: String) -> Nuclease {
        let nucleaseArray = nucleaseManager.getByValue("name", value: name) as [Nuclease]
        assert(!nucleaseArray.isEmpty, "DATABASE ERROR: There is no nuclease in name:\(name)")
        assert(nucleaseArray.count == 1, "DATABASE ERROR: There is more than one nuclease in name:\(name)")
        return nucleaseArray[0]
    }

    func listGuideRNA() {
        do {
            try initialiseComponents()
        } catch ModelError.parameterError(let message) {
            print ("Error: \(message)")
            return
        } catch let error {
            print ("External error: \(error)")
        }

        ///
        /// Everything should be initialised properly by now
        ///
        let om = organismManager as! OrganismModelManager
        for target in self._targets {

            //print("AAA \(target.name) \(target.location) \(self.spacerLength)")
            if let (organism, genome) = om.getOrgaismAndSequenceById(target.model_organism_id) {
                print ("Source sequence length \(genome.length), \(targetLength)")

                // FIXME: handle spacerLEngth and seedLength
                let start = target.location - self.spacerLength!
                let end=target.location+target.length+target.offset
                let tstart = Date()
                let rnaTargets = genome.seq.getOnTargets(self.usedPAMSequences, start: start, end: end)
                let tend = Date()
                let timeInterval: Double = tend.timeIntervalSince(tstart)
                print("Time to evaluate designing gRNA \(timeInterval) seconds")

                if let _ = rnaTargets {
                    printGuideRNAs(rnaTargets!, sequence: genome.seq, name: (organism as! ModelOrganism).name)
                }
            }
        }
    }

    private func printGuideRNAs(_ rnaTargets: [Int], sequence: Seq, name: String? = nil) {

        var organismName = ""
        if let _ = name {
            organismName = name!
        }
        var result: [String] = []
        var validLocation = 0
        var strand = "+"
        var pamPos = 0
        var s = 0
        var e = 0

        let tstart = Date()
        for pamLocation in rnaTargets {

            //print ("PAMLOCATION \(pamLocation)")
            if  pamLocation >= 0 {
                validLocation = pamLocation
                pamPos = validLocation
                strand = "+"
                s=Int(pamPos) - spacerLength!
                e=Int(pamPos) + _pamLength-1
                result.append("\(organismName):\(strand):\(s)-\(e):\(sequence[s...e])")
            } else {
                validLocation = -pamLocation
                pamPos = validLocation + _pamLength
                strand = "-"
                s=Int(pamPos) - _pamLength
                e=Int(pamPos) + spacerLength! - 1
                result.append("\(organismName):\(strand):\(s)-\(e):\(sequence[s...e].complement())")
            }
        }
        let tend = Date()
        let timeInterval = tend.timeIntervalSince(tstart)
        print("Time to evaluate printing gRNA \(timeInterval) seconds")

        dump(result)
        //print(result.joinWithSeparator("\n"))

    }
}
