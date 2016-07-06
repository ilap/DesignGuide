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

class TargetModelManager: AnyRepository<DesignTarget> {
    
    var items: [CamembertModel] = []

    required init(context: DataContext) {
        super.init(context: context)
    }

    func getOrCreateTargetsFromLocation(_ sourceId: Int, location: Int, length: Int, offset: Int? = nil) -> [CamembertModel] {

        //let modelId = modelId

        var result = DesignTarget.findByValues(["design_source_id":sourceId,
            "location":location,
            "length":length,
            "offset":offset!])

        assert(result.count <= 1, "DATABASE ERROR: More than one targets found")

        if result.isEmpty {
            print("RESULT IS EMPTY")

            let target = DesignTarget()
            target.design_source_id = sourceId

            // FIXME: name must be uniq for an organism
            target.location = location
            target.length = length
            target.offset = offset ?? target.offset // Set to default
            target.type = TargetType.Location.rawValue
            target.descr = "Automatically generated target based on Location, length and offset"

            // Computed name for target as just the location has been set.
            target.name = "location_" + String(location) + "_" + String(length) + "_" + String(target.offset)
            
            if target.push() == .success {
                result.append(target)
            }

        } else {
            print("RESULT IS NOT EMPTY")
        }

        return result

    }
}
