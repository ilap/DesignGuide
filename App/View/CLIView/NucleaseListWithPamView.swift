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

class NucleaseListWithPamView : BaseView {

    let presenter: NucleasePresenter
    let service: EnvironmentService

    init(presenter: NucleasePresenter, service: EnvironmentService) {
        self.presenter = presenter
        self.service = service
    }

    func show() {
        // Here ve just list the nucleases.
        let nlist = service.commandLineArgs[.ListNucleaseWithPAMs] as! Bool? ?? false
        let blist = service.commandLineArgs[.ListExperiment] as! Bool? ?? false

        if nlist {
            print("Available nucleases with PAMs and PAM's affinity.")
            presenter.listCommand!.execute()
        } else if blist {
            print("Listing experimetns is not implemented yet!")
        }
    }
}

