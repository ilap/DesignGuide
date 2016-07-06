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


///
/// MVP Communication between presenters
/// http://stackoverflow.com/questions/9761546/mvp-communication-between-presenters
///
class PamDetailsCLIView: AnyView<ListPamsViewProtocol>, ListPamsViewProtocol {
    
    required init(presenter: AnyPresenter<ListPamsViewProtocol>) {
        super.init(presenter: presenter)
        
        initialiseEventBus()
    }
    
    ///
    /// Implements EventBus for communicating between View and Presenter.
    ///
    private func initialiseEventBus() {
        SwiftEventBus.onBackgroundThread(target: self, name: DesignBusEvent.ListPAM.rawValue) { _ in
            print ("Thread kicked off");
        }
    }
    
    override func show() {
        // Kick the event.
        SwiftEventBus.post(name: DesignBusEvent.ListPAMRequest.rawValue)
    }
    
    override func showMessage(message: String) {
        print("Message: \(message)")
    }
    
    func showPams(pamViewModelList: [PamViewModel]) {
        for viewModel in pamViewModelList {
            print(viewModel.name + "(" + viewModel.survival + ")")
        }
        
    }
}



