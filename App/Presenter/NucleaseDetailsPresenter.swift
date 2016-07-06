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


public class NucleaseDetailPresenter: AnyPresenter<ListNucleasesViewProtocol> {
    
    var nucleaseViewModelList: [NucleaseViewModel]!

    let dao: AnyRepository<Nuclease>
    let pamDao: AnyRepository<PAM>
    let options: DesignOptionsService
    
    init (dao: AnyRepository<Nuclease>, pamDao: AnyRepository<PAM>, options: DesignOptionsService) {
        self.options = options
        self.dao = dao
        self.pamDao = pamDao
        
        super.init()
        self.initEventBus()
    }
    
    private func initEventBus() {
        SwiftEventBus.onBackgroundThread(target: self, name: DesignBusEvent.ListNucleaseRequest.rawValue) { _ in
            self.update()
            SwiftEventBus.post(name: DesignBusEvent.ListNuclease.rawValue)
        }
    }

    func update() {
        resolveViewModelArray()
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
}
