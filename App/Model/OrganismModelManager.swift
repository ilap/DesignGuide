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


class OrganismModelManager: AnyRepository<ModelOrganism>, DesignableManagerModel {
    // Using BioSwift's File Utils
    let fileUtil = BioSwiftFileUtil()

    // TODO: should use properties for items
    var organismSequence: [CamembertModel:SeqRecord] = [:]

    required init(context: DataContext) {
        super.init(context: context)
        self.context = context
    }

    private func processSequenceFile(_ sequenceFile: String?) throws -> [CamembertModel] {
        guard let _ = sequenceFile else { return [] }
        
        //debugPrint("Processing source sequence file: \(sequenceFile!).")
        
        guard let seqRecords = try SeqIO.parse(sequenceFile) else { return []}
        
        let multipleSequences = seqRecords.count > 1


        var result: [CamembertModel] = []
        
        for seqRecord in seqRecords {
            //debugPrint("Found seqrecord \(seqRecord!) \(seqRecords.count)")
            
            if let organism = getModelOrganism(seqRecord!) {

                result.append(organism)
                organismSequence[organism] = seqRecord!
                
            } else {
                let organism = ModelOrganism()
                organism.name = seqRecord!.id
                organism.descr = seqRecord!.description
                if let path = Defaults[.blobFilesPath] {
                    organism.path = path
                }
                organism.sequence_hash = seqRecord!.hash
                organism.sequence_length = seqRecord!.length
                //print("NEW MODELORGANISM: \(organism.sequence_hash)")
                try organism.copySequenceToDatabase(sequenceFile!, createNewFile: multipleSequences)
                organism.push()

                organismSequence[organism] = seqRecord!
            }
        }
        return result
    }


    func getModelOrganism(_ seqRecord: SeqRecord) -> CamembertModel? {

        let hash = seqRecord.seq.sequence.hash
        let results = ModelOrganism.findHash(hash)
        
        //print("RESULST: \(results)")
        if results.isEmpty {
            return nil
        } else if results.count > 1 {
            // TODO: use own error types
            //throws ModelError.DatabaseError("DATABASE INCONSISTENCY: More than one model organism' sequence exists (\(hash))")
            return nil
        } else {
            return results[0]
        }

    }


    func getOrganismsFromFileOrDB(_ source: String?) throws ->  [CamembertModel] {

        var result: [CamembertModel] = []

        if let _ = source {
            for sequenceFile in try fileUtil.getFilesFromPath(source!) {
                result += try processSequenceFile(sequenceFile)
            }
        }
        return result
    }

    func getOrgaismAndSequenceById(_ id: Int) -> (CamembertModel, SeqRecord)? {

        for (organism, sequence) in organismSequence {
            if organism.id == id {
                return (organism, sequence)
            }
        }
        return nil
    }
}
