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


class DesignGuideOptions: DesignOptionsService {
    var options: [DesignOption:Any] = [:]

    func description() {
        print ("Description:")
        print ("============================")
        print("Source: \(options[.Source])")
        print("Target: \(options[.Target])")
        print("Target Length: \(options[.TargetLength])")
        print("Target offset: \(options[.TargetOffset])")
        print("-----")
        print("Endonuclease: \(options[.Endonuclease])")
        print("Used PAMs: \(options[.UsedPAMs])")
        print("-----")
        print("Spacer length: \(options[.SpacerLength])")
        print("Seed length: \(options[.SeedLength])")
        print("-----")
    }
}
