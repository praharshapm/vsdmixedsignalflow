# OpenROAD RTL2GDS flow for Mixed Signal SoC
This project describes an analog IP needs to be modified in order to be recognised by placement and routing tools and how the physical design is carried out.

# Table of Contents

- [Mixed Signal SoC](#mixed-signal-soc)
- RTL2GDS flow of mixed signal SoC
- The OpenROAD Project
- OpenROAD tools installation
- Inputs required for physical design
  - LIB
  - LEF
  - top level verilog file
 - Obtaining IP
 - Limitations of current IP designs
 - Resolving pin issue
 - Some pointers for top level verilog
 - Experiments with Qflow
    - setting up the directories
    - modifications for hard macro
    - running qflow
    - placement
  - Future work
  - Contact Information

# Mixed Signal SoC
