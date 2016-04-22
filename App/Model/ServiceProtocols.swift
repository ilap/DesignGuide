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

protocol DataAccessService {
    
    associatedtype T
    
    func findAll(item: T?) throws -> [T]?
    func insert (item: T) throws -> T?
    func delete (item: T) throws -> Void
    func update (item: T) throws -> Void
}

// Wrapper abstraction as generic protocol cannot be properties.
struct AnyDataService<U>: DataAccessService {
    
    typealias T = U
    let _findAll: U? throws -> [T]?
    let _insert: U throws -> T?
    let _delete: U throws -> Void
    let _update: U throws -> Void
    
    init<Base: DataAccessService where Base.T == U>(base : Base) {
        _insert = base.insert
        _delete = base.delete
        _update = base.update
        _findAll = base.findAll
    }
    
    func insert(item: T) throws -> T? {
        print("Do something")
        return try _insert(item)
    }
    
    func delete(item: T) throws -> Void {
        print("Do something")
        try _delete(item)
    }

    func update(item: T) throws -> Void {
        print("Do something")
        try _update(item)
    }
    
    func findAll(item: T?) throws -> [T]? {
        print("Do something")
        return try _findAll(item)
    }
    
}