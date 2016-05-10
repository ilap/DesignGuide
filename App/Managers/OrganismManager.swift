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


class OrganismManager: DesignManagerModel, DesignableManagerModel {
    
    static let sharedInstance = OrganismManager()
    
    var items: [CamembertModel] = []
    var sequences: [CamembertModel:SeqRecord] = [:]
    
    func initialise(depends: DesignManagerModel? = nil, parameters: DesignGuideParameters) throws  -> DesignManagerModel? {
        if let source = parameters.source {
            for sourceFile in try parseSource(source) {
                try processSequenceFile(sourceFile)
            }
        }
        
        return self
    }
    
    private func isDirectory(path: String) -> Bool {
        var isDir: ObjCBool = false
        NSFileManager().fileExistsAtPath(path, isDirectory: &isDir)
        return Bool(isDir)
    }
    
    private func parseSource(source: String) throws -> [String]  {
    
        var result: [String] = []
        let fileManager = NSFileManager.defaultManager()
    
        var isDir: ObjCBool = false
        if fileManager.fileExistsAtPath(source, isDirectory:  &isDir) {
            if isDir {
                //let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(source)
                //while let element = enumerator?.nextObject() as? String {
                let files = try fileManager.contentsOfDirectoryAtPath(source)
                for file in files {
                    //Add all files but direcotries from the path...
                    // Handle Unix hidden files..
                    let fileName = source+"/"+file
                    if !isDirectory(fileName) && !file.hasPrefix(".") {
                        //print("ITIS FILE: \(fileName)")
                        result.append(fileName)
                    }
                }
                
            } else {
                result.append(source)
            }
        } else {
            //TODO Throw an error.
            throw ModelError.FileError("Error parsing source file \(source)")
        }
        
        return result
    
    }

    
    private func processSequenceFile(sequenceFile: String?) throws {
        guard let _ = sequenceFile else { return }
        
        debugPrint("Processing source sequence file: \(sequenceFile!).")
        
        guard let seqRecords = try SeqIO.parse(sequenceFile) else { return }
        
        let multipleSequences = seqRecords.count > 1
        
        for seqRecord in seqRecords {
            print("Found seqrecord \(seqRecord!) \(seqRecords.count)")
            
            if let organism = getModelOrganism(seqRecord!) {

                items.append(organism)
                
                sequences[organism] = seqRecord!
                
            } else {
                let organism = ModelOrganism()
                organism.name = seqRecord!.id
                organism.descr = seqRecord!.description
                if let path = Defaults[.blobFilesPath] {
                    organism.path = path
                }
                organism.sequence_hash = seqRecord!.hash
                print("NEW MODELORGANISM: \(organism.sequence_hash)")
                try organism.copySequenceToDatabase(sequenceFile!, createNewFile: multipleSequences)
                organism.push()
                items.append(organism)
                sequences[organism] = seqRecord
            }
        }
    }

    func getModelOrganism(seqRecord: SeqRecord) -> CamembertModel? {

        let hash = seqRecord.seq.sequence.hash
        let results = ModelOrganism.findHash(hash)
        
        print("RESULST: \(results)")
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
}
