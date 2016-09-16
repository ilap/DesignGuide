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

import BioSwift

public protocol ViewProtocol {
    func show() throws
    func showMessage(message: String)
    //func showErrorMessage(erroMessage: String)
}

public protocol NucleaseViewProtocol: ViewProtocol {
    func showNucleases(nucleaseViewModelList: [NucleaseViewModel])
    func showNucleaseDetails(nucleaseViewModel: NucleaseViewModel)
}

public protocol DesignGuideViewProtocol: ViewProtocol {
    
    var source: String? { get set }
    var target: Int? { get set }
    var targetLength: Int? { get set }
 
    func showDesignDetails(sourceViewModelList: [SourceViewModel?],
                           parameters: DesignParameterProtocol,
                           nuclease: NucleaseViewModel?) throws
    func showSourceGuides(sourceViewModel: SourceViewModel?)
    func updateDesignParameters(parameters: DesignParameterProtocol)
}
