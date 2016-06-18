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

class TargetModelManager: AnyRepository<ModelTarget> {
    
    var items: [CamembertModel] = []

    required init(context: DataContext) {
        super.init(context: context)
        self.context = context
    }

    func getOrCreateTargetsFromLocation(_ organism_id: Int, location: Int, length: Int, offset: Int? = nil) -> [CamembertModel] {

        let modelId = organism_id

        var result = ModelTarget.findByValues(["model_organism_id":organism_id,
            "location":location,
            "length":length,
            "offset":offset!])


        assert(result.count <= 1, "DATABASE ERROR: More than one targets found")

        if result.isEmpty {

            let target = ModelTarget()
            target.model_organism_id = modelId

            // FIXME: name must be uniq for an organism
            target.location = location
            target.length = length
            target.offset = offset ?? target.offset // Set to default
            target.type = TargetType.Location.rawValue
            target.descr = "Automatically generated target based on Location, length and offset"

            // Computed name for target as just the location has been set.
            target.name = "location_" + String(location) + "_" + String(length) + "_" + String(target.offset)
            target.push()

            result.append(target)

        }

        return result

    }
}
