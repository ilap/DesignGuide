DesignGuide - Guide RNA Design Tool for bacterial species -  README file
==========================================================

This tool is developed by Apple's Swift language.

It tries to find and score guide RNAa in a sequence similar 
to the target location in a genome and stores the results in database. 

Firstly, the source/query sequence(s) (genome(s) of species where we want to find gRNAs) 
must be selected from the already stored sequences (currently one). 

After that, the (design) target location(s) (genes or DNA sequences will be supported in the later releases) must be applied.

Finally, the tool try to find the prospective guide RNAs in the the targets based on the interested PAM sequence and score the guide RNAs based on the available scoring algorythm (currently Cas-Offinder is being developed, but Bowtie2, Bowtie and BWA will be supported in later releases)


Requirements
============

The Design Guide RNA Tool for Bacterial species is currently supported and tested on Ubuntu LTS 
15.04 (x64) Linux and Mac OS X > 10.10. 

The other requirements are the following:

Dependencies
============

- BioSwift -  An implementation of BioPython like framework in Swift. It is required for DesignGuide.
https://github.com/ilap/BioSwift.git

Frameworks
----------

- Swift-CLI -  A powerful framework that can be used to develop a CLI, from the simplest to the most complex, in Swift.
https://github.com/jakeheis/SwiftCLI.git

- Camembert - Camembert is a toolkit written in swift, for using sqlite3 easier. Is is available for OSX and iOS. 
https://github.com/remirobert/Camembert.git

Installation and use
======================

       git clone https://github.com/ilap/DesignGuide

Testing
=======
No unit test yet.

Distribution Structure
======================

- README       -- This file.
