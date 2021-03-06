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

public enum ModelError: ErrorProtocol {
    case error(String)
    case fileError(String)
    case databaseError(String)
    case parameterError(String)

    public var description: String {
        get {
            switch (self) {
            case .error(let message):
                return message
            case .fileError(let message):
                return message
            case .databaseError(let message):
                return message
            case .parameterError(let message):
                return message
            }
        }
    }
}
protocol DesignableManagerModel {
    var sourceSequence: [CamembertModel:SeqRecord] { get }
}
