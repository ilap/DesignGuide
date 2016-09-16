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

protocol DesignSourceModelProtocol {
    var seqRecord: SeqRecord? { get set }
}

class DefaultDesignParameters: DesignParameterProtocol {
    var seedLength: Int = 0
    var spacerLength: Int = 20
    var senseCutOffset: Int? = nil
    var antiSenseCutOffset: Int? = nil
    var targetOffset: Int = 0
    var pamLength: Int = 0
    var maxMismtach: Int = 5
}

public class DesignManagerPresenter: AnyPresenter<DesignGuideViewProtocol> {
    // Visitor patterns
    public var message: String = ""
    
    public var sourceViewModels: [SourceViewModel?]!
    public var guideViewModels: [GuideViewModel?]!
    
    /// Design Guide Parameters.
    public var parameters: DesignParameterProtocol?
    
    var nucleaseViewModel: NucleaseViewModel? = nil

    let context: DataContext

    init (context: DataContext, service: DesignOptionsService) {
        self.context = context
        parameters = DefaultDesignParameters()
        
        super.init()
        
    }
    
    private func initEventBus() {
        SwiftEventBus.onBackgroundThread(target: self, name: DesignBusEventType.UpdateDesignGuideParameters.rawValue) { _ in
            self.view?.updateDesignParameters(parameters: self.parameters!)
        }
        
        SwiftEventBus.onBackgroundThread(target: self, name: DesignBusEventType.DesignGuideRequest.rawValue) { _ in
            do {
                try self.runDesign()
            } catch let error {
                debugPrint("DesignGuide Error: \(error)")
            }
        }
        
        SwiftEventBus.onBackgroundThread(target: self, name: DesignBusEventType.NucleaseChanged.rawValue) { result in
            self.nucleaseViewModel = result.object as! NucleaseViewModel
        }
    }
    
    override public func onViewInitialised() {
        self.initEventBus()
    }
    
    func runDesign() throws {
        

        do {
            try resolveViewModelArray()
            try view?.showDesignDetails(sourceViewModelList: sourceViewModels, parameters: parameters!,
                                nuclease: nucleaseViewModel)
            
        } catch let error as ModelError {

            print("DesignGuide error: \(error)")
            return
        }

        for sourceViewModel in sourceViewModels {
            
            let ds = DesignSourceAdapter(sourceViewModel: sourceViewModel!, designParameters: parameters!)
            let all_pams = nucleaseViewModel?.pamViewModels.map({
                $0?.model as PAMProtocol?
            })
   
            parameters?.pamLength = (all_pams?[0]?.sequence.characters.count)!

            let source = (sourceViewModel?.model)! as DesignSourceProtocol
            //let target = sourceViewModel?.targetViewModels.first??.model
            for targetViewModel in (sourceViewModel?.targetViewModels)! {
                
                let target = targetViewModel?.model
                // FIXME: Alwasy use the 1st the Optimal PAM
                let ontargets = ds.getOntargets(usedPams: [all_pams?[0]])

                if ontargets.isEmpty != true {
                
                    let scoreTask = CasOffinderScoreFunction(sequenceFile: Defaults[.blobFilesPath]! + "/" + source.path,
                                                            // source: source,
                                                             target: target,
                                                             ontargets: ontargets,
                                                             pams: all_pams!,
                                                             parameters: parameters)
                    
                    let scoreTaskMediator = TaskMediator(task: scoreTask)
                    
                    scoreTaskMediator.runTasks()
                }
                //let targetViewModel = sourceViewModel?.targetViewModels.first!
                targetViewModel?.loadGuides(guides: ontargets)
            }
            // Let the view now that data is avaialable...
            view?.showSourceGuides(sourceViewModel: sourceViewModel)
        }
    }
    
    private func resolveDesignSources(path: String?, target: Int, targetLength: Int, targetOffset: Int) throws {

        guard let _ = path else { return }

        
        guard let seqRecords = try SeqIO.parse(path) else {
            assertionFailure("Error parsing file: \(path)")
            return
        }
        
        let multipleSequences = seqRecords.count > 1
        
        if seqRecords.count > 1 {
            assertionFailure("ERROR: More than SeqRecord in a file: \(path)\n")
        }
        let seqRecord = seqRecords[0]
        

        
        if let source: DesignSource = getModelSource(seqRecord!) {
            let source = SourceViewModel(model: source, context: context, record: seqRecord!)
            sourceViewModels.append(source)
            validateAndRetrieveTarget(viewModel: source, target: target, length: targetLength , offset: targetOffset)
            
        } else {
            let source = DesignSource()
            source.name = seqRecord!.id
            source.descr = seqRecord!.description
            source.sequence_hash = seqRecord!.hash
            source.sequence_length = seqRecord!.length
            
            //TODO: source.path  =  String(UInt(bitPattern:source.sequence_hash), radix:16).uppercased() + ".fasta"
            try source.copySequenceToDatabase(path!, createNewFile: multipleSequences)

            if source.push() == .success {
                let source = SourceViewModel(model: source, context: context, record: seqRecord!)
                sourceViewModels.append(source)
                validateAndRetrieveTarget(viewModel: source, target: target, length: targetLength , offset: targetOffset)
            }
        }
    }
    
    private func getModelSource(_ seqRecord: SeqRecord) -> DesignSource? {
        
        let hash = seqRecord.seq.sequence.hash
        let results = DesignSource.findHash(hash)
        
        if results.isEmpty {
            return nil
        } else if results.count > 1 {
            // TODO: use own error types
            assertionFailure("DATABASE INCONSISTENCY: More than one model source' sequence exists (\(hash))")
            return nil
        } else {
            return results[0]
        }
    }
    
    private func validateAndRetrieveTarget(viewModel: SourceViewModel, target: Int, length: Int, offset: Int) {

        let source = viewModel.model
        let start = target - offset
                
        //TODO: Validate the bounds
        if start >= (source?.sequence_length)! -
            (length + 2 * offset + 1) {
            assertionFailure("FATAL ERROR: The location \(start) is beyond the size \(source!.sequence_length) of the source sequence!")
        }
        
        
        for target in self.getOrCreateTargetsFromLocation((source?.id!)!,
                        location: target, length: length, offset: offset) as! [DesignTarget] {

            viewModel.targetViewModels.append(TargetViewModel(model: target, context: context))
        }
    }
    
    
    func getOrCreateTargetsFromLocation(_ sourceId: Int, location: Int, length: Int, offset: Int? = nil) -> [CamembertModel] {
        
        var result = DesignTarget.findByValues(["design_source_id":sourceId,
                                                "location":location,
                                                "length":length,
                                                "offset":offset!])
        
        
        assert(result.count <= 1, "DATABASE ERROR: More than one targets found")
        
        if result.isEmpty {
            
            let target = DesignTarget()
            target.design_source_id = sourceId
            
            // FIXME: name must be uniq for an organism
            target.location = location
            target.length = length
            target.offset = offset ?? target.offset // Set to default
            target.type = TargetType.Location.rawValue
            target.descr = "Automatically generated target based on Location, length and offset"
            
            // Computed name for target as just the location has been set.
            target.name = "location_" + String(location) + "_" + String(length) + "_" + String(target.offset)
            
            if target.push() == .success {
                result.append(target)
            }
        }
        
        return result
        
    }
    
    func resolveViewModelArray() throws {
        sourceViewModels = []

        for sequenceFile in try BioSwiftFileUtil().getFilesFromPath((view?.source!)!) {
            
            try! resolveDesignSources(path: sequenceFile, target: (view?.target)!,
                                      targetLength: (view?.targetLength)!,
                                      targetOffset: (parameters?.targetOffset)!)
        }
    }
}


public class DesignSourceAdapter {
    
    var sourceViewModel: SourceViewModel
    var designParameters: DesignParameterProtocol
    
    var pams: [PAMProtocol?] = []
    
    var crisprUtil: CrisprUtil
    
    init(sourceViewModel: SourceViewModel, designParameters: DesignParameterProtocol) {
        
        self.sourceViewModel = sourceViewModel
        self.designParameters = designParameters

        let record = sourceViewModel.seqRecord
        self.crisprUtil = CrisprUtil(record: record!, parameters: designParameters)
    
    }
    
    public func getOntargets(usedPams: [PAMProtocol?]) -> [VisitableProtocol?] {
        var result: [VisitableProtocol?] = []
        
        self.pams = usedPams
        
        for target in self.sourceViewModel.targetViewModels {
            let start = (target?.location)! - (target?.offset)!
            let end = start + (target?.length)! + 2 * (target?.offset)!
            
            if let ontargets = crisprUtil.getPAMOnTargets(pams, start: start, end: end) {
                // No guide candidates in the selected Target.
                result += ontargets
            }
        }
        
        return result
    }
}
