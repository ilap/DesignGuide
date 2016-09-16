DesignGuide - Guide RNA Design Tool for bacterial species -  README file
==========================================================

This tool is developed by Apple's Swift language.

DesignGuide tries to score guide RNAa in a gsequence similar . 

Firstly, the source/query sequence(s) (genome(s) of species where we want to find gRNAs) 
must be selected from the already stored sequences (currently one). 

After that, the (design) target location(s) (genes or DNA sequences will be supported in the later releases) must be applied.

Finally, the tool try to find the prospective guide RNAs in the the targets based on the interested PAM sequence and score the guide RNAs based on the available scoring algorythm (currently Cas-Offinder is being developed, but Bowtie2, Bowtie and BWA will be supported in later releases)


Requirements
============

The Design Guide RNA Tool for Bacterial species is currently supported and tested Mac OS X > 10.10. 
However it should run on Ubuntu LTS 15.04 (x64) Linux but it has not been built and tested.

The other requirements are the following:

Dependencies
============

- BioSwift -  An implementation of BioPython like framework in Swift. It is required for DesignGuide.
https://github.com/ilap/BioSwift.git

- Xcode 8 beta 3

Frameworks
----------

- Swift-CLI -  A powerful framework that can be used to develop a CLI, from the simplest to the most complex, in Swift.
https://github.com/jakeheis/SwiftCLI.git

- Camembert - Camembert is a toolkit written in swift, for using sqlite3 easier. Is is available for OSX and iOS. 
https://github.com/remirobert/Camembert.git

Installation and use
======================

    mkdir DesignGuideBuild

    git clone https://github.com/ilap/DesignGuide
    git clone https://github.com/ilap/BioSwift
    mkdir FrameWorks
    cd FrameWorks
    git clone https://github.com/jakeheis/SwiftCLI
mkdir FrameWorks



