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

public class DesignGuidePresenter: AnyPresenter<ListNucleasesViewProtocol> {
    
    ///
    /// Model managers
    ///
    let organismModel: AnyRepository<DesignSource>
    let targetModel: AnyRepository<DesignTarget>
    let nucleaseModel: AnyRepository<Nuclease>
    let pamModel: AnyRepository<PAM>
    
    
    /// Design Guide Parameters.
    var parameters: DesignParameters? = nil
    let optionService: DesignOptionsService

    
    init (context: DataContext, service: DesignOptionsService) {

        optionService = service
        parameters = DesignParameters()

        //let sourceFile = optionService.options[.Source] as! String?
        organismModel =  DesignSourceModelManager(context: context)
        
        /// Endonuclease
        //let nucleaseName = optionService.options[.Endonuclease] as! String?
        nucleaseModel =  AnyRepository<Nuclease>(context: context)
        //let nuclease
        pamModel =  AnyRepository<PAM>(context: context)
        

        
 
        
        targetModel = TargetModelManager(context: context)
        
        super.init()
        initialiseModels(context: context)
        
    }
    
    private func initialiseModels(context: DataContext) {
        

    }
    
    private func validateAndRetrieveTarget(target: String?, length: Int?) {
    
    }
    
    private func initialiseParameters() {
        // FIXME: Only location is supported, means target Length always must be presented.
        let target = optionService.options[.Target] as! String?
        let targetLength = optionService.options[.TargetLength] as! Int?
        
        validateAndRetrieveTarget(target: target, length: targetLength)
        
        /// Other parameters
        parameters?.spacerLength = optionService.options[.SpacerLength] as! Int? ?? (parameters?.spacerLength)!
        
        // TODO: seed length must be set as it's a user parameter
        parameters?.seedLength = optionService.options[.SeedLength] as! Int? ?? (parameters?.seedLength)!
        
        /// Source
        
        
        /// Target
        // if it's not defined then it's always 0
        parameters?.targetOffset = optionService.options[.TargetOffset] as! Int? ?? 0
        
        
        /// Used PAMs
        //FIXME: parameters?.usedPAMSequences = (optionService.options[.UsedPAMs] as! [String]?) ?? []
    }
    

    override public func onViewInitialised() {

    }
    
    
}


protocol DesignSourceModelProtocol {
    var seqRecord: SeqRecord? { get set }
}


class DesignParameters: DesignParameterProtocol {
    var seedLength: Int = 10
    var spacerLength: Int = 20
    var senseCutOffset: Int? = nil
    var antiSenseCutOffset: Int? = nil
    var targetOffset: Int = 0
    
    var pamLength: Int = 0
    
}

class DesignTargetModel: DesignTargetProtocol {
    var id: Int? = nil
    var design_source_id: INTEGER = 0
    var design_application_id: INTEGER = 0
    var name: TEXT = ""
    
    var location: INTEGER = 0
    var length: INTEGER = 0
    var offset: INTEGER = 0
    var type: TEXT = "L"
    var descr: TEXT = ""
    
    init(location: Int, length: Int) {
        self.location = location
        self.length = length
    }
}

class DesignSourceAdapter {
    
    var designSource: DesignSourceProtocol?
    var designParameters: DesignParameterProtocol
    
    var pams: PAMProtocol?
    
    var designTargets: [DesignTargetProtocol?] {
        
        didSet {
            // TODO:
            initialise()
        }
    }
    
    private var crisprUtil: CrisprUtil? = nil
    
    init(designSource: DesignSourceProtocol?, designTargets: [DesignTargetProtocol?], designParameters: DesignParameterProtocol) {
        
        self.designSource = designSource
        self.designParameters = designParameters
        self.designTargets = designTargets
        
        initialise()
        
    }
    
    private func initialise() {
        let record = (designSource as! DesignSourceModelProtocol?)?.seqRecord
        self.crisprUtil = CrisprUtil(record: record!, parameters: designParameters)
    }
    
    func getOntargets(pams: [PAMProtocol?]) -> [VisitableProtocol?]? {
        var result: [VisitableProtocol?] = []
        
        for target in designTargets {
            let start = (target?.location)! - (target?.offset)!
            let end = start + (target?.length)! + 2 * (target?.offset)!
            
            let r = self.crisprUtil?.getPAMOnTargets(pams, start: start, end: end)
            
            result += r!
        }
        
        return result
    }
}

public class DesignGuidePresenterX {
    
    ///
    /// Model managers
    ///
    let organismModel: AnyRepository<DesignSource>
    let targetModel: AnyRepository<DesignTarget>
    let nucleaseModel: AnyRepository<Nuclease>
    let pamModel: AnyRepository<PAM>
    
    let optionService: DesignOptionsService
    
    /// Design Guide Parameters.
    var designParameters: DesignParameters? = nil
    
    ///
    /// Commands
    ///
    var listGuideRNACommand: Command? = nil
    var designGuideCommand: Command? = nil
    var listOntargetsCommand: Command? = nil
    var listOfftargetsCommand: Command? = nil
    
    
    ///
    /// properties for the View
    ///
    private var _organisms: [DesignSource] = []
    private var _targets: [DesignTarget] = []
    private var _usedPAMs: [PAM] = []
    //private var _location: Int? = nil
    
    
    
    //var target: String? = nil
    //var targetLength: Int? = nil
    
    
    private var _targetsToValidate: [DesignTargetProtocol] = []
    func validateAndAddTarget(target: String?, targetLength: Int?) {
        //FIXME: validate the design target(s).
        
        let element = DesignTargetModel(location: Int(target!)!, length: targetLength!)
        _targetsToValidate.append(element)
    }
    
    private var _targetOffset: Int? = nil
    var targetOffset: Int? {
        get {
            if let _ = _targetOffset {
                return designParameters!.targetOffset
            } else {
                return nil
            }
        }
        set {
            if let v = newValue {
                designParameters!.targetOffset = v
            }
        }
    }
    
    var seedLength: Int? {
        get {
            return designParameters!.seedLength
        }
        set {
            if let v = newValue {
                designParameters!.seedLength = v
            }
        }
    }
    
    var spacerLength: Int? {
        get {
            return designParameters!.spacerLength
        }
        set {
            if let v = newValue {
                designParameters!.spacerLength = v
            }
        }
    }
    
    // Property
    private var _nuclease: Nuclease? = nil
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
    
    // All PAMs property.
    private var _allPAMs: [PAM] = []
    var allPAMs: [String] {
        get {
            if let _ = _nuclease {
                
                self._allPAMs = pamModel.getByValue("nuclease_id", value: _nuclease!.id!) as [PAM]
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
            
            designParameters!.pamLength = pams.first!.characters.count
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
            
        }
    }
    
    
    var sourceFile: String? = nil {
        willSet {
            if let _ = sourceFile {
                
            }
            print("Source File is: \(sourceFile), \(newValue!)")
        }
    }
    
    init (context: DataContext, service: DesignOptionsService) {
            
        
        optionService = service
        designParameters = DesignParameters()
        
        nucleaseModel =  AnyRepository<Nuclease>(context: context)
        //pamModel =  PamModelManager(context: context)
        pamModel = AnyRepository<PAM>(context: context)
        
        organismModel =  DesignSourceModelManager(context: context)
        targetModel = TargetModelManager(context: context)
        
        
        listGuideRNACommand = RelayCommand(action: listGuideRNA/*, canExecute: canExecute*/)
    }
    
    func initialiseComponents() throws {
        
        
        if usedPAMSequences.isEmpty {
            throw ModelError.parameterError("FATAL ERROR: Improper values in used PAMs (empty or bad)!")
        }
        
         
        let om = organismModel as! DesignSourceModelManager
        self._organisms = try om.getDesingSourcesFromFileOrDB(sourceFile) as! [DesignSource]
         
        let tm = targetModel as! TargetModelManager
         
        self._targets = []
        //self._location = Int(self.target!)
         
        for organism in self._organisms {
            //debugPrintprint(organism)
            // Currently jsut the location is supported
            for target2Validate in _targetsToValidate {
                let offset = (designParameters?.targetOffset)!
                let length = target2Validate.length
                let start = target2Validate.location - offset
                let end = length + 2 * offset
                
                //TODO: Validate the bounds
                if start >= organism.sequence_length -
                    (offset + length + 1) {
                    throw ModelError.parameterError("FATAL ERROR: The location \(start) is beyond the size \(organism.sequence_length) of the source sequence!")
                }

         

                let targets = tm.getOrCreateTargetsFromLocation(organism.id!,
                                                                location: start,
                                                                length: end,
                                                                offset: offset) as! [DesignTarget]
             
                self._targets += targets
            }
        }
         
        designParameters!.spacerLength = getNuclease(self.nuclease!).spacer_length
        //debugPrint("Organisms \(self._organisms), TARGETS: \(self._targets)")*/
    }
    
    
    func getNuclease(_ name: String) -> Nuclease {
        let nucleaseArray = nucleaseModel.getByValue("name", value: name) as [Nuclease]
        assert(!nucleaseArray.isEmpty, "DATABASE ERROR: There is no nuclease in name:\(name)")
        assert(nucleaseArray.count == 1, "DATABASE ERROR: There is more than one nuclease with same name:\(name)")
        return nucleaseArray.first!
    }
    
    func designGuide() {
        do {
            try initialiseComponents()
        } catch ModelError.parameterError(let message) {
            
            print ("Error: \(message)")
            return
            
        } catch let error {
            print ("External error: \(error)")
        }
        
        /// #1. Generate Score inputfile
        
        /*let designSources = DesignSource.getDesignSources(path: fileName!)
        
        print(designSources.map {
            $0?.path
            })
        
        let allPAMs = MockPAM.getPAMs()
        
        let usedPAMs = allPAMs.filter {
            $0?.sequence == "NGG"
        }
        
        let designTargets = MockDesignTarget.getDesignTargets()
        
        let parameters = DesignParameters()
        
        let ds = MockDesignSourceAdapter(designSource: designSources[0]!, designTargets: designTargets, designParameters: parameters)
        
        let ontargets = ds.getOntargets(pams: usedPAMs)
        
        let scoreTask = CasOffinderScoreFunction(source: designSources.first!, target: designTargets.first!, ontargets: ontargets!, parameters: parameters)
        
        let scoreTaskMediator = TaskMediator(task: scoreTask)
        
        scoreTaskMediator.runTasks()
        
        print("RESULT \(scoreTask.results)")*/
    }
    
    func listGuideRNA() {
        //print("RUNNNNIIIINNNG:")
        
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
        let om = organismModel as! DesignSourceModelManager
        for target in self._targets {
         
            //print("AAA \(target.name) \(target.location) \(self.spacerLength)")
            if let (organism, genome) = om.getDesingSourceAndSequenceById(target.design_source_id) {
                print ("Source sequence length \(genome.length)")
         
                // FIXME: handle spacerLEngth and seedLength
                //let start = target.location - designParameters!.spacerLength
                //let end=target.location+target.length+target.offset
                let tstart = Date()
                // let rnaTargets = genome.seq.getOnTargets(self.usedPAMSequences, start: start, end: end)
                //let rnaTargets = CrisprUtil(record: genome, allPAMs: self.allPAMs).getOnTargetsLocation(self.usedPAMSequences, start: start, end: end)
                let cu = CrisprUtil(record: genome, parameters: designParameters!)
                //let cu = CrisprUtil(record: genome, allPAMs: _allPAMs.map({ $0 as PAMProtocol?}))
                let rnaTargets = cu.getPAMOnTargets(_usedPAMs.map({ $0 as PAMProtocol?}), start: target.location, end: target.location + target.length )
                let tend = Date()
                let timeInterval: Double = tend.timeIntervalSince(tstart)
                print("Time to evaluate designing gRNA \(timeInterval) seconds")
                
                if let ontargets = rnaTargets {
                    
                    for ontarget in ontargets {
                        let ot = ontarget as! TargetProtocol
                        print(ot.name + "____" + ot.sequence + "XXXXXXX" + ot.pam)
                    //printGuideRNAs(rnaTargets!, sequence: genome.seq, name: (organism as! DesignSource).name)
                    }
                }
            }
        }
    }
}
