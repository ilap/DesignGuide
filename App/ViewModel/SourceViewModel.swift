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

//protocol DesignSourceModelProtocol {
 //   var seqRecord: SeqRecord? { get set }
//}

public class SourceViewModel: DesignSourceModelProtocol {
    
    var seqRecord: SeqRecord?
    
    var context: DataContext
    var model: DesignSourceProtocol!
    
    var targetDao: AnyRepository<DesignTarget>
    var targetViewModels: [TargetViewModel?] = []
    
    var name: String {
        get {
            return model.name
        }
    }
   
    init(model: DesignSourceProtocol, context: DataContext, record: SeqRecord) {
        self.model = model
        self.context = context
        self.targetDao = AnyRepository<DesignTarget>(context: context)
        self.seqRecord = record
    }
}
