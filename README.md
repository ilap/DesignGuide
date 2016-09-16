DesignGuide - Guide RNA Design Tool for bacterial species -  README file
=========================================================================

The Design Guide RNA Tool for Bacterial species.
It design and score guide RNAa for the genomic target in one or more genomes of bacterial species.

Requirements
============

The tool is developed by Apple's Swift language and is currently supported and tested only on Mac OS X > 10.10. 
However it should run on Ubuntu LTS 15.04 (x64) Linux but it has not been built and tested.

Dependencies
============

- BioSwift -  An implementation of BioPython like framework in Swift. It is required for DesignGuide.
https://github.com/ilap/BioSwift.git

- Xcode 8 beta 3 - Xcode fully featured Integrated Development Environment.
https://developer.apple.com/xcode/

Frameworks
----------

- Swift-CLI -  A powerful framework that can be used to develop a CLI, from the simplest to the most complex, in Swift.
https://github.com/jakeheis/SwiftCLI.git

- Camembert - Camembert is a toolkit written in swift, for using sqlite3 easier. Is is available for OSX and iOS. 
https://github.com/remirobert/Camembert.git

Installation and use
======================

 1. Download the source code from github, see below, or uncompress the submitted file.
```bash
$ mkdir DesignGuideBuild
$ cd DesignGuideBuild
$ git clone https://github.com/ilap/DesignGuide
$ git clone https://github.com/ilap/BioSwift
$ mkdir FrameWorks
$ cd FrameWorks
$ git clone https://github.com/jakeheis/SwiftCLI
```

2. Launch the Xcode 8 beta3 and epen the DesignGuide's Xcode Workspace file (./DesignGuideBuild/DesignGuide/DesignGuide.xcworkspace).
3. Convert the cloned SwitCLI Framework to Swiwt 3.0 (Xcode 8 asks automatically).
4. Clean and build (at least twice) the BioSwift 1st and then the SwiftClI
5. Lastly, build the DesignGuide, no any error should be experienced during the build.
6. If the build successed, copy the DesignGuide.app from the build directory to /usr/local/bin or similar 
7. Run the DesignGuide.

Example
===============
The found gRNAs marked with '*'.

```bash

$ cd ~/DesignGiude.app/Contents/Macos
$ ./DesignGuide cli -s /Users/ilap/Developer/Dissertation/Resources/Sequences/Source1in2 -e wtCas9  -t 100 -T 20
Designing "guide RNA(s)" for the following species:
Source: AE005174-1
Source: AE005174v2-2

Design Parameters:
Protospacer length: 20
Nuclease: wtCas9 - NGG (68.0%), NAG (1.32%), NGA (0.2%), NAA (0.07%)
It takes a while to finish the design, please be patient.

Designed guideRNA(s) for species "AE005174-1":
5'+AATTAAAATTTTATTGACTT+3'*
||||||||||||||||||||    gRNA:AATTAAAATTTTATTGACTT:+:99.173%:97:AE005174-1
3'-TTAATTTTAAAATAACTGAA-5'

Designed guideRNA(s) for species "AE005174v2-2":
5'+CAGAGCAGTGGCCAAGCGTA+3'*
||||||||||||||||||||    gRNA:CAGAGCAGTGGCCAAGCGTA:+:98.687%:95:AE005174v2-2
3'-GTCTCGTCACCGGTTCGCAT-5'

5'+AGAGCAGTGGCCAAGCGTAC+3'*
||||||||||||||||||||    gRNA:AGAGCAGTGGCCAAGCGTAC:+:98.553%:96:AE005174v2-2
3'-TCTCGTCACCGGTTCGCATG-5'

5'+AGCGTACGGGAAAAAAACAT+3'
||||||||||||||||||||    gRNA:ATGTTTTTTTCCCGTACGCT:-:98.423%:109:AE005174v2-2
3'-TCGCATGCCCTTTTTTTGTA-5'*

5'+GTGGTGGTCCGGCAGAGCAG+3'*
||||||||||||||||||||    gRNA:GTGGTGGTCCGGCAGAGCAG:+:31.701%:83:AE005174v2-2
3'-CACCACCAGGCCGTCTCGTC-5'


$ ./DesignGuide  help


Available commands:
- cli                  Run Design Guide RNA Tool as CLI
- list                 List base database - items = cas9, experiments, targets, sources
- gui                  Run Design Guide RNA Tool as Standalone GUI
- help                 Prints this help information
192-168-1-2:MacOS ilap$ ./DesignGuide  list -h
Usage:  list [options]

-h, --help                               Show help information for this command
-n, --nucleases                          List nucleases with known PAMs

$ ./DesignGuide  list -n
Available nucleases and their PAM(s) efficiency:

Nuclease: wtCas9          - NGG (68.0%), NAG (1.32%), NGA (0.2%), NAA (0.07%)
Nuclease: SpCas9 Nickase  - NGG (68.0%), NAG (1.32%), NGA (0.2%), NAA (0.07%)
Nuclease: SpCas9 D1135E   - NGG (70.0%), NAG (0.2%)
Nuclease: SpCas9 VRER     - NGCG (70.0%)
Nuclease: SpCas9 EQR      - NGAG (70.0%)
Nuclease: SpCas9 VQR      - NGAN (70.0%), NGNG (70.0%)
Nuclease: dCas9           - NGG (68.0%), NAG (1.32%), NGA (0.2%), NAA (0.07%)
Nuclease: NmCas9          - NNNNGATT (70.0%)
Nuclease: TdCas9          - NAAAAC (70.0%)
Nuclease: FnCpf1          - TTN (70.0%)
Nuclease: AsCpf1          - TTN (70.0%)
Nuclease: LbCpf1          - TTN (70.0%)

$ ./DesignGuide  cli -h
Usage:  cli [options]

-L, --spacer-length <10-100>             RNA Spacer length - default is 20.
-T, --target-length <length>             Only valid if the target is a location e.g. start position.
-e, --endonuclease <endonuclease>        Available endonucleases - default is "wtCas9", use "list -n" command for obtaining supported Cas9/Cpf1 variants.
-h, --help                               Show help information for this command
-l, --seed-length <0-100>                Seed length - default is 10 (currently not used).
-o, --target-offset <0-10000>            Extend target sequence size in the genome for design RNA on each sides of the target sequnce - default is 0.
-s, --source <value>                     Directory includes sequence file(s) or a sequence file.
-t, --target <location>                  Start position. The sequence file or a gene name (if the source genome/file is annotated) as target parameter has not implemented yet).
```
