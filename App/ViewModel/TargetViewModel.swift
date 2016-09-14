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

public class TargetViewModel {
    
    var context: DataContext
    
    var model: DesignTargetProtocol
    
    var guideDao: AnyRepository<OnTarget>
    var guideViewModels: [GuideViewModel?] = []
    
    var name: String {
        get {
            return model.name
        }
    }

    
    var location: Int {
        get {
            return model.location
        }
    }
    var length: Int {
        get {
            return model.length
        }
    }
    var offset: Int {
        get {
            return model.offset
        }
    }
    
    init(model: DesignTargetProtocol, context: DataContext) {
        self.model = model
        self.context = context
        self.guideDao = AnyRepository<OnTarget>(context: context)
    
        //self.loadGuides()
    }

    public func loadGuides(guides: [VisitableProtocol?]) {
        //XXX: ilap print("LOADING..........")
        guideViewModels = []
        if !guides.isEmpty {
            for guide  in guides  {
                let a = guide as! RNAOnTarget
                //XXX: ilap print("Adding guide: \(a.sequence)\n")
                guideViewModels.append(GuideViewModel(model: a))
            }
        }
    }
}
