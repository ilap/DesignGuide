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

class GuideRNAListView : BaseView {
    // TODO: Use some presistent store for seedLength parameter.
    let seedLength = 10
    let targetOffset = 0

    let presenter: GuideRNAPresenter
    let service: EnvironmentService

    init(presenter: GuideRNAPresenter, service: EnvironmentService) {
        self.presenter = presenter
        self.service = service
    }

    func show() {
        debugPrint(service.commandLineArgs[.Endonuclease] as! String)

        /// Source
        presenter.sourceFile = service.commandLineArgs[.Source] as! String?

        /// Target
        // FIXME: Only location is supported, means target Length always must be presented.
        presenter.target = service.commandLineArgs[.Target] as! String?
        presenter.targetLength = service.commandLineArgs[.TargetLength] as! Int?
        // if it's not defined then it's always 0
        presenter.targetOffset = service.commandLineArgs[.TargetOffset] as! Int? ?? 0

        /// Endonuclease
        presenter.nuclease = service.commandLineArgs[.Endonuclease] as! String?

        /// Used PAMs
        presenter.usedPAMs = (service.commandLineArgs[.UsedPAMs] as! [String]?) ?? []

        /// Other parameters
        presenter.spacerLength = service.commandLineArgs[.SpacerLength] as! Int?

        // TODO: seed length must be set as it's a user parameter
        presenter.seedLength = service.commandLineArgs[.SeedLength] as! Int?
        // Kick off the command
        print("Presenter's used PAMs: \(presenter.usedPAMs)")

        presenter.listGuideRNACommand!.execute()
    }
}

