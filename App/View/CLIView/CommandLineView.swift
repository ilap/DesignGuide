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

public class CommandLineView: GeneralView {
    let parameters = RuntimeParameters.sharedInstance
    
    public func execute() throws {
        let start = NSDate()
        //var seqIO = SeqIO(path: "/Users/ilap/Developer/Dissertation/DesignGuide/Utils/Sequences/Bacillus_subtilis-ATCC6051_whole_genome/sequence.fasta.txt")
        guard let seqrecords = try SeqIO.parse(parameters.source) else { return }
        
        //print("SEQRECORD.... \(seqrecords)")
        let seqRecord = seqrecords[0]!
        
        let end = NSDate()
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        
        
        print("Timeinterval \(timeInterval)")
        
        
        
        print ("GC Content \(seqRecord.gcContent.format(".2"))")
        print ("Bases \(seqRecord.bases)")
        print ("Length \(seqRecord.length)")
    }
}