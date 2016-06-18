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


enum DataAccessLayerError: ErrorProtocol {
    case connectionError
    case insertError
    case deleterror
    case findError
    case nilError
}


protocol DataContext {
    var initialised : Bool { get }
}


// For DAL's class function.
public protocol DataServiceProtocol {
    associatedtype T
    static func findAll() -> [T]
    static func findByValue(_ column: String, value: Any) -> [T]
    static func findByValues(_ queries: [String:Any]) -> [T]
    func save() -> Void

    init()
}


protocol RepositoryProtocol{
    associatedtype T

    func create() -> T?
    func add(_ item: T) -> Void

    func getAll<T: DataServiceProtocol where T.T == T>() -> [T]
    func getByValue<T: DataServiceProtocol where T.T ==T>(_ column: String, value: Any) -> [T]
    func getByValues<T: DataServiceProtocol where T.T ==T>(_ queries: [String:Any]) -> [T]

    init(context: DataContext)
}
