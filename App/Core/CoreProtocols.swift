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

/// The mandatory options are
/// 1. -s: Source sequence (dir including sequence or sequence file) -s "/Users/ilap/sequence/Sources"
/// 2. -t: Target in the source that can be either of:
///      2.1 Sequence file includes one or more sequences e.g. -t "/tmp/Targers.fasta"
///      2.2 gene name(s) if the source is annotated  e.g. -t "lacZ" or -t "lacZ dacA"
///      2.3 start and end position or start and length in the Source sequences.
///           Length can be 1 for a single point mutation.
/// 3. -e -[-p] or -p: Endonuclease and/or PAM sequence it can be derivated from either of:
///      3.1 endonuclease e.g. -e "wtCas9" (it has NGG, NAG, NGA and NAA), if database is used
///      3.2 from explcicite string separated by whitte spaces -p "NAANG NAANGGA" if custom values are used
///      3.3 combine both of the above -e "wtCas9" -p "NGG" only "NGG" of wtCas9 is considered, if database is used.
///
/// Others are optional:
///  1. -L <17-100>: Spacer length - default 20
///  2. -l <0..spacer lentgth>:Seed length - default 10
///  3. -o <0..2000>: Target offset, means offset of up/down stream of the target start and and position - default 0
public enum DesignOption: String  {
    ///
    /// CLI Parameters
    ///
    case Source = "Source Organism."
    case Target = "Target: gene, file or location."
    case TargetLength = "Target length."
    case TargetOffset = "Target offset."

    case Endonuclease = "Cas9/Cpf1 enzyme."

    case UsedPAMs = "Used PAMs of the chosen endonuclease"

    case SpacerLength = "Spacer length."
    case SeedLength = "Seed length."

    case ApplicationType = "Guide RNA application type e.g. KO, KI, Activation or Repression"

    ///
    /// CLI List parameters
    ///
    case ListExperiment = "List available experiments:"
    case ListNucleaseWithPAMs = "Available nucleases with PAMs and PAM's affinity."

    var defaultValue: Int {
        switch self {
        case TargetOffset: return Int(0)
        case SpacerLength: return 10
        case SeedLength: return 20
        default : return 0

        }
    }
}

enum GuideApplication: String {
    case KO = "KO"
    case KI = "KI"
    case Activation = "Activation"
    case Repression = "Repression"

    var defaultApplication: GuideApplication{
        return KO
    }
}

public protocol DesignOptionsService {
    var options: [DesignOption:Any] { get set }
}

enum DesignBusEvent: String {
    case ListNucleaseRequest = "ListNucleaseRequest"
    case ListNuclease = "ListNuclease"
    case ListPAMRequest = "ListPAMRequest"
    case ListPAM = "ListPAM"
}

