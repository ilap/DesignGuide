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
    var conf : NSUserDefaults?
    
    
    public func execute() {
        let start = NSDate()
        //var seqIO = SeqIO(path: "/Users/ilap/Developer/Dissertation/DesignGuide/Utils/Sequences/Bacillus_subtilis-ATCC6051_whole_genome/sequence.fasta.txt")
        //let sr = seqIO!.parse()
        let seqrecords = try SeqIO.parse("/Users/ilap/Developer/Dissertation/Sequences/Source1/sequence.fasta.txt")
        
        let end = NSDate()
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        
        print("Timeinterval \(timeInterval)")
        
        
        
        print ("GC Content \(seqrecords[0]!.gcContent.format(".2"))")
        print ("Bases \(seqrecords[0]!.bases)")
        print ("Length \(seqrecords[0]!.length)")
    }
}