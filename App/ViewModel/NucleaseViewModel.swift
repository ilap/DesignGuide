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


public class NucleaseViewModel {
    
    var model: Nuclease

    var pamDao: AnyRepository<PAM>
    var pamViewModels: [PamViewModel?] = []

    var name: String {
        get {
            return model.name
        }
        set {
            model.name = newValue
        }
    }
    
    var spacerLength: Int {
        get {
            return model.spacer_length
        }
    }
    
    init(model: Nuclease, pamDao: AnyRepository<PAM>) {
        self.model = model
        self.pamDao = pamDao
        loadPams()
    }

    private func loadPams() {
        pamViewModels = []

        let pams: [PAM] = pamDao.getByValues(["nuclease_id":model.id!])
        

        if !pams.isEmpty {
            for pam in pams {
                pamViewModels.append(PamViewModel(model: pam))
            }
        }
    }
}
