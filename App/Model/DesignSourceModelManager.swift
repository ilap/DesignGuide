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


class DesignSourceModelManager: AnyRepository<DesignSource>, DesignableManagerModel {
    // Using BioSwift's File Utils
    let fileUtil = BioSwiftFileUtil()

    // TODO: should use properties for items
    var sourceSequence: [CamembertModel:SeqRecord] = [:]
    
    var sources: [DesignSourceProtocol?] {
        get {
            return sourceSequence.keys.map { $0 as! DesignSourceProtocol }
        }
    }
    
    var _source: DesignSourceProtocol? = nil
    var source: DesignSourceProtocol? {
        get {
            return _source
        }
        set {
            if sources.contains({ $0?.id != nil && $0?.id! == newValue?.id!  }) {
                self._source = newValue
            } else {
                _source = nil
            }
        }
    }

    required init(context: DataContext) {
        super.init(context: context)
    }

    private func processSequenceFile(_ sequenceFile: String?) throws -> [CamembertModel] {
        guard let _ = sequenceFile else { return [] }
        
        //debugPrint("Processing source sequence file: \(sequenceFile!).")
        
        guard let seqRecords = try SeqIO.parse(sequenceFile) else { return []}
        
        let multipleSequences = seqRecords.count > 1


        var result: [CamembertModel] = []
        
        for seqRecord in seqRecords {
            //debugPrint("Found seqrecord \(seqRecord!) \(seqRecords.count)")
            
            if let source = getModelsource(seqRecord!) {

                result.append(source)
                sourceSequence[source] = seqRecord!
                
            } else {
                let source = DesignSource()
                source.name = seqRecord!.id
                source.descr = seqRecord!.description
                if let path = Defaults[.blobFilesPath] {
                    source.path = path
                }
                source.sequence_hash = seqRecord!.hash
                source.sequence_length = seqRecord!.length
                //print("NEW MODELsource: \(source.sequence_hash)")
                try source.copySequenceToDatabase(sequenceFile!, createNewFile: multipleSequences)
                
                if source.push() == .success {
                    sourceSequence[source] = seqRecord!
                }
            }
        }
        return result
    }


    func getModelsource(_ seqRecord: SeqRecord) -> CamembertModel? {

        let hash = seqRecord.seq.sequence.hash
        let results = DesignSource.findHash(hash)
        
        //print("RESULST: \(results)")
        if results.isEmpty {
            return nil
        } else if results.count > 1 {
            // TODO: use own error types
            //throws ModelError.DatabaseError("DATABASE INCONSISTENCY: More than one model source' sequence exists (\(hash))")
            return nil
        } else {
            return results[0]
        }

    }


    func getDesingSourcesFromFileOrDB(_ source: String?) throws ->  [CamembertModel] {

        var result: [CamembertModel] = []

        if let _ = source {
            for sequenceFile in try fileUtil.getFilesFromPath(source!) {
                result += try processSequenceFile(sequenceFile)
            }
        }
        return result
    }

    func getDesingSourceAndSequenceById(_ id: Int) -> (CamembertModel, SeqRecord)? {

        for (source, sequence) in sourceSequence {
            if source.id == id {
                return (source, sequence)
            }
        }
        return nil
    }
}
