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

import Foundation
import BioSwift
import SwiftCLI


public class OldCommandLineView: GeneralView {
    let parameters = RuntimeParameters.sharedInstance
    
    public func show() throws {
    }
    
    public func execute() throws {
        
        guard let seqrecords = try SeqIO.parse(parameters.source) else { return }
        let seqRecord = seqrecords[0]!
        
        // The source seems valid therefore the sequence file should be saved into database.
        var modelOrganism: ModelOrganism? = nil
        
        let name = seqRecord.id
        let path = Defaults[.blobFilesPath]!
        let sequence_hash = seqRecord.seq.sequence.hash
        
        let fromPath = parameters.source!
        let toPath = path + "/" + String(seqRecord.seq.sequence.hash, radix:16).uppercaseString + ".fasta"
        
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(toPath) {
            // Check in database
            let organisms = ModelOrganism.select(selectRequest:  Select.Where("sequence_hash", .EqualsTo, seqRecord.seq.sequence.hash, .Ascending, "1"))! as! [ModelOrganism]
            
            if organisms.isEmpty {
                throw CLIError.Error ("DATABASE ERROR: Cannot find \(name) in the Database \n \(toPath)")
            } else if organisms.count != 1 {
                throw CLIError.Error ("DATABASE ERROR: More than one organism with \"\(name)\" name could be find in the database!")
            }
            
            //TODO: check if it's
            modelOrganism = organisms[0]
            
        } else {
            do {
                print("Copying \(fromPath) to \(toPath)")
                try fileManager.copyItemAtPath( fromPath, toPath: toPath)
                
            }
            catch let error as NSError {
                print("Cannot copy \(fromPath) to \(toPath): \(error)")
            }
            
            modelOrganism = ModelOrganism()
            modelOrganism!.name = name
            modelOrganism!.path = path
            modelOrganism!.sequence_hash = sequence_hash
            modelOrganism!.push()
        }


        // testView()
        

    }
    
    private func testView () throws {
        var start = NSDate()
        //var seqIO = SeqIO(path: "/Users/ilap/Developer/Dissertation/DesignGuide/Utils/Sequences/Bacillus_subtilis-ATCC6051_whole_genome/sequence.fasta.txt")
        guard let seqrecords = try SeqIO.parse(parameters.source) else { return }
        
        //print("SEQRECORD.... \(seqrecords)")
        let seqRecord = seqrecords[0]!
        
        var end = NSDate()
        var timeInterval: Double = end.timeIntervalSinceDate(start)
        
        print("Timeinterval \(timeInterval)")
        
        start = NSDate(); print ("GC Content \(seqRecord.gcContent.format(".2"))"); end = NSDate(); timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")
        start = NSDate(); print ("GC Content \(seqRecord.bases)"); end = NSDate(); timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")
        start = NSDate(); print ("GC Content \(seqRecord.length)"); end = NSDate(); timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")
        
        print (seqRecord[15] as String)
        
        start = NSDate()
        let hash = seqRecord.seq.sequence.hash
        print ("HASVALUE: \(String(hash, radix: 16))")
        end = NSDate()
        timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")
        //print ("Bases \(seqRecord.bases)")
        //print ("Length \(seqRecord.length)")
        
    }
    
    
}