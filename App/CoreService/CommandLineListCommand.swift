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

import SwiftCLI
import Foundation


class CommandLineListCommand: DesignGuideCommand, OptionCommandType {

    var service: EnvironmentService

    init(service: EnvironmentService) {
        self.service = service
    }

    var commandName: String  {
        return "list"
    }
    
    var commandSignature: String  {
        return ""
    }
    
    var commandShortDescription: String  {
        return "List base database - items = cas9, experiments, targets, sources"
    }
    
    func setupOptions(_ options: Options) {
        options.onFlags(["-e", "--experiments"], usage: "List experiments by users and date") {(flag) in
            self.service.commandLineArgs[.ListExperiment] = true
        }
        options.onFlags(["-n", "--nucleases"], usage: "List nucleases with known PAMs") {(flag) in
            self.service.commandLineArgs[.ListNucleaseWithPAMs] = true
        }

    }

    func execute(_ arguments: CommandArguments) throws  {

        // TODO: Remove this in production...
        //self.service.commandLineArgs[.ListNucleaseWithPAMs] = true

        let context = SqliteContext()
        let pamManager = PamModelManager(context: context)
        let nucleaseManager = NucleaseModelManager(context: context)
        let viewModel = NucleasePresenter(model: nucleaseManager, otherModel: pamManager)
        let view = NucleaseListWithPamView(presenter: viewModel, service: service)

        view.show()

    }
}
