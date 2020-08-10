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

Mixed signal SoC is a chip which contains both analog and digital blocks. The designers are adding more analog circuitry and increasing their complexities day by day. Not only that, they also contain digital control logic. Additionally, they also contain multiple feedback loops, which make the verification difficult. As the process nodes shrink, the demand for integration grows. For example, in home automation systems, it senses the surrounding atmosphere, like light, temperature etc. and converts these analog signals into digital for processing. A divide and conquer approach is followed, where the analog and digital structures were dealt with separately. Usually, an analog IP (Intellectual Property) is bought as black- box. It is then integrated with a mostly digital SoC. When analog and digital merge, then even the fastest circuit solvers become slow. The digital and analog IP blocks are at different levels of abstraction, which force mixed signal SoC design to take a hierarchical approach. 

# RTL2GDS flow of mixed signal SoC

To implement a RTL-to-GDS flow for mixed signal SoC, there is need to establish communication between the analog and digital blocks. For this integration to happen, hierarchical level of abstraction with either analog or digital as top level is required. In order to carry out this task, OpenROAD project can be utilized. 

# The openROAD Project

In order to carry out this task, OpenROAD project can be utilized. OpenROAD, is a ‘no human in loop’ hardware compiler which translates source code (RTL) to layouts (GDS). The time required for the translation is less than 24 hours. It is a DARPA initiative, an open source project. RTL2GDS flow of OpenROAD is used only for digital SoC. Hence, with OpenROAD, we can establish digital as our top level hierarchy

For more details visit [The OpenROAD Project](https://github.com/The-OpenROAD-Project)
