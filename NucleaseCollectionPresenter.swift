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


public class NucleaseCollectionPresenter: AnyPresenter<NucleaseViewProtocol> {
    
    var nucleaseViewModelList: [NucleaseViewModel]!
    
    var selectedNuclease: NucleaseViewModel? {
        didSet {
            if let _ = selectedNuclease {
            //    view?.showNucleaseDetails(nucleaseViewModel: selectedNuclease!)
                SwiftEventBus.post(name: DesignBusEventType.NucleaseChanged.rawValue,
                               sender: selectedNuclease)
            }
        }
    }
    
    let dao: AnyRepository<Nuclease>
    let pamDao: AnyRepository<PAM>
    
    init (dao: AnyRepository<Nuclease>, pamDao: AnyRepository<PAM>) {
        self.dao = dao
        self.pamDao = pamDao
        
        super.init()
        self.initEventBus()
    }
    
    private func initEventBus() {
        SwiftEventBus.onBackgroundThread(target: self, name: DesignBusEventType.NucleaseUpdateRequest.rawValue) { _ in
            self.update()
        }
        
        SwiftEventBus.onBackgroundThread(target: self, name: DesignBusEventType.NucleaseSelected.rawValue) { result in
            self.setSelectedByName(name: result.object as! String)
        }
    }

    override public func onViewInitialised() {
        resolveViewModelArray()
    }
    
    func update() {
        // Update the data from model
        resolveViewModelArray()
        
        // Update the view.
        view?.showNucleases(nucleaseViewModelList: nucleaseViewModelList)
    }
    

    func resolveViewModelArray() {
        nucleaseViewModelList = []
        if let nucleases: [Nuclease] = dao.getAll() {
            for nuclease in nucleases {
                nucleaseViewModelList.append(NucleaseViewModel(model: nuclease, pamDao: pamDao))
            }
        }
    }
    
   public func setSelectedByName(name: String) -> NucleaseViewModel? {
        //XXX: ilap debugPrint("SetseletctByName: \(name)")
        if let nuclease =  nucleaseViewModelList.filter({ $0.name == name }).first {
            selectedNuclease = nuclease
             return selectedNuclease
        }
        assertionFailure("The selected Nuclease (\(name)) cannot be found in the database!")
        return nil
    }
}
