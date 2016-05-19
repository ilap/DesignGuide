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


public class NucleasePresenter  {

    var listCommand : Command? = nil

    // model as Repository e.g. implements CRUD
    let nucleaseModel: AnyRepository<Nuclease>
    let pamModel: AnyRepository<PAM>

    init (model:  AnyRepository<Nuclease>, otherModel: AnyRepository<PAM>) {
        self.nucleaseModel = model
        self.pamModel = otherModel
        //self.canExecute = true
        self.listCommand = RelayCommand(action: listAvailableNucleases/*, canExecute: canExecute*/)
    }


    func listAvailableNucleases() {
        let nucleases = Nuclease.findAll()

        for nuclease in nucleases {
            let pams = PAM.findByValue("nuclease_id", value: nuclease.id!)

            if pams.isEmpty {
                continue
            }
            var spams: String = ""
            for pam in pams {
                spams += " "
                spams += pam.sequence
                spams += "("
                spams += String(pam.survival*100)
                spams += "%)"
            }
            print("\t\"\(nuclease.name)\" - \(spams)")

        }
        
    }
}