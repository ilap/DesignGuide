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

class AnyRepository<T: DataServiceProtocol>: RepositoryProtocol {

    var context: DataContext

    required init(context: DataContext) {
        self.context = context

    }

    func create() -> T? {
        return T()
    }
    
    func add(_ item: T) -> Void {
        // FIXME: get rid off this thightly coupled CamembertModel.
        let result = (item as! CamembertModel).push()
        if result != .success {
            debugPrint("DATABASE ERROR: \(result): \(item)")
        }
    }

    func delete(_ item: T) -> Void {
        // FIXME: get rid off this thightly coupled CamembertModel.
        let result = (item as! CamembertModel).remove()
        if result != .success {
            debugPrint("DATABASE ERROR: \(result): \(item)")
        }
    }

    func getAll<T: DataServiceProtocol where T.T ==T>() -> [T] {
        // MARK: Call static function.
        return T.findAll()
    }

    
    func getByValue<T: DataServiceProtocol where T.T ==T>(_ column: String, value: Any) -> [T] {
        // MARK: Call static function.
        return T.findByValue(column, value: value)
    }

    func getByValues<T: DataServiceProtocol where T.T ==T>(_ queries: [String:Any]) -> [T] {
        // MARK: Call static function.
        return T.findByValues(queries)
    }
}
