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
class NucleasesCollectionCLIView: AnyView<NucleaseViewProtocol>, NucleaseViewProtocol {
    
   required init(presenter: AnyPresenter<NucleaseViewProtocol>,
                 optionService: DesignOptionsService) {
        super.init(presenter: presenter, optionService: optionService)
    }
    
    override func show() {
        // Kick the list request event on show.
        SwiftEventBus.post(name: DesignBusEventType.NucleaseUpdateRequest.rawValue)
    }
    
    func showNucleases(nucleaseViewModelList: [NucleaseViewModel]) {
    
        print("Available nucleases and their PAM(s) efficiency:\n")
        for nuclease in nucleaseViewModelList {
            
            let pams = nuclease.pamViewModels.map {
                ($0?.name)! + " (" + ($0?.survival)! + ")"
                }.joined(separator: ", ")
            
            let padded = nuclease.name.padding(toLength: 15, withPad: " ", startingAt: 0)

            print("Nuclease: \(padded) - \(pams)")
        }
    }
    
    func showNucleaseDetails(nucleaseViewModel: NucleaseViewModel) {
        
        print("Details of \"\(nucleaseViewModel.name)\"")
        
        var str = ""
        for pamViewModel in nucleaseViewModel.pamViewModels {
            
            str += pamViewModel!.name + "(" + (pamViewModel?.survival)! + ") \n"
        }
        print("\(nucleaseViewModel.name):\n\(str)")
    }
}
