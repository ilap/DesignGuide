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

class GuideRNAListView : ViewProtocol {
    // TODO: Use some presistent store for seedLength parameter.
    
    let presenter: DesignGuidePresenter //GuideRNAPresenter
    //let service: DesignOptionsService

    init(presenter: DesignGuidePresenter) {//, service: DesignOptionsService) {
        self.presenter = presenter
        //self.service = service
    }
    
    func initialised() -> Bool {
        presenter.onViewInitialised()
        /// No any throws occured
        return true
    }

    func getContext (contexts: [String]) {
        for context in contexts {
            print(context)
        }
    }
    
    func showMessage(message: String) {
        print(message)
    }
    
    func show() {
        if initialised() {
            //FIXME: Design Guide RNA
            // presenter.listGuideRNACommand!.execute()
        } else {
            print("Error in initialising View.")
        }
    }
}

