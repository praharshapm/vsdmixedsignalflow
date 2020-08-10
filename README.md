# OpenROAD RTL2GDS flow for Mixed Signal SoC
This project describes an analog IP, 2:1 analog multiplexer, needs to be modified in order to be recognised by placement and routing tools and how the physical design is carried out.

# Table of Contents

- [Mixed Signal SoC](#mixed-signal-soc)
- [RTL2GDS flow of mixed signal SoC](#rtl2gds-flow-of-mixed-signal-soc)
- [The OpenROAD Project](#the-openroad-project)
- [OpenROAD tools installation](#openroad-tools-installation)
- [Inputs required for physical design](#inputs-required-for-physical-design)
- [Obtaining IP](#obtaining-ip)
- [Obtaining verilog files](#obtaining-verilog-files)
- [Getting LEF files](#getting-lef-files)
- [Limitations of current IP designs](#limitations-of-current-ip-designs)
- [Resolving the pin issue](#resolving-the-pin-issue)
	-For the labels on metal layers:
	-For the labels on polysilicon layers: 
- [Writing LIB file](#writing-lib-file)
- [Top level verilog file](#top-level-verilog-file)
- [Experiments with Qflow](#experiments-with-qflow)
    - [setting up the directories using hard macro](#setting-up-the-directories-using-hard-macro)
    - [Running sythesis for analog multiplexer](#running-synthesis-for-analog-multiplexer)
    - [Running placement for analog multiplexer](#running-placement-for-analog-multiplexer)
- [Future Work](#future-work)
- [Contact Information](#contact-information)
- [References](#references)
   

# Mixed Signal SoC

Mixed signal SoC is a chip which contains both analog and digital blocks. The designers are adding more analog circuitry and increasing their complexities day by day. Not only that, they also contain digital control logic. Additionally, they also contain multiple feedback loops, which make the verification difficult. As the process nodes shrink, the demand for integration grows. For example, in home automation systems, it senses the surrounding atmosphere, like light, temperature etc. and converts these analog signals into digital for processing. A divide and conquer approach is followed, where the analog and digital structures were dealt with separately. Usually, an analog IP (Intellectual Property) is bought as black- box. It is then integrated with a mostly digital SoC. When analog and digital merge, then even the fastest circuit solvers become slow. The digital and analog IP blocks are at different levels of abstraction, which force mixed signal SoC design to take a hierarchical approach. 

# RTL2GDS flow of mixed signal SoC

To implement a RTL-to-GDS flow for mixed signal SoC, there is need to establish communication between the analog and digital blocks. For this integration to happen, hierarchical level of abstraction with either analog or digital as top level is required. In order to carry out this task, OpenROAD project can be utilized. 

# The OpenROAD Project

In order to carry out this task, OpenROAD project can be utilized. OpenROAD, is a ‘no human in loop’ hardware compiler which translates source code (RTL) to layouts (GDS). The time required for the translation is less than 24 hours. It is a DARPA initiative, an open source project. RTL2GDS flow of OpenROAD is used only for digital SoC. Hence, with OpenROAD, we can establish digital as our top level hierarchy

For more details visit [The OpenROAD Project](https://github.com/The-OpenROAD-Project)

# OpenROAD tools installation

For detailed installation steps, go to 

# Inputs required for physical design

The main inputs required to carry out RTL2GDS flow are:
- LIB file
- LEF file
- top level verilog file

# Obtaining IP
The analog multiplexer is available on the following github page: [https://github.com/prithivjp/avsdmux2x1_3v3](https://github.com/prithivjp/avsdmux2x1_3v3)
This page includes the spice files and magic layout files. 

To clone the repository type the following from terminal:
```javascript 
git clone https://github.com/prithivjp/avsdmux2x1_3v3.git
```

# Obtaining verilog files
The verilog file for analog multiplexer can be procured from [Efabless PicoRV-32 Github page](https://github.com/efabless/raven-picorv32/blob/master/verilog/AMUX2_3V.v)

To get the repository:
```javascript 
git clone https://github.com/efabless/raven-picorv32.git
```

# Getting LEF file
The LEF file can be obtained from magic layout synthesis tool from mag file as the input. 
The steps to install on centOS 7 machine can be seen in

The IP uses OSU018 as the technology node. So it is essential that the tech file for OSU018 is downloaded in the machine. the tech file is present in this repository. 
```javascript 
git clone https://github.com/prithivjp/avsdmux2x1_3v3.git
```

From the terminal type the following :

```javascript 
cd avsdmux2x1_3v3/Layout
magic -T osu018 21muxlayout.mag
```
A layout window and a tkcon window will open. In the tkcon window, type the following command to dump out the LEF file

```javascript 
lef write AMUX2_3V.lef
```
# Limitations of current IP layouts
On opening the LEF file, it is observed that it is incomplete. The file does not contain the pin descriptions. 
On observing the layout from the layout window, we can see that the pins are not present. Only labels are present in the layout. And the magic tool is not able to identify these labels. 
This incomplete LEF file would not be accepted by the PnR tools.

# Resolving the pin issue
To convert the labels into pins, a command called 'port' can be used.

## For the labels on metal layers:
- Select the area under which the label is present. 
- In the tkcon window type 
  ```javascript 
  port make
  ```
  To verify if the port is made 
    ```javascript 
    port name
    ```
- Similarly, carry out the same process for other labels

## For the labels on polysilicon layers:
- Type 'g' to enable the grid option
- delete the label on 'polysilicon' layer by selecting the area where label is present and typing the following in tkcon window
   ```javascript 
  erase labels
  ```
- Connect a `polycontact` layer on the `polysilicon` on one side
- To the `polycontact`, connect a `metal1` layer . 
- Overlap the `metal1` layer with 'm1p.
- Remove DRC errors if any.
- Create a label on `metal1` layer , by selecting a point on the layer and in tkcon window, typing
  ```javascript 
  label 'name_of_label'
  ```
- Continue the same process for turning a label into port as mentioned above.

Now, dump out the LEF file again by using 
```javascript 
lef write AMUX2_3V.lef
```
All the pins and their descriptions can noe be seen.

A section called OBS must also be seen at the end of the file. If it is not visible, it means that the label on polysilicon is not converted into port properly.

In the LEF file, we can observe that the name of macro is 21muxlayout. This is because the name of the layout file was 21muxlayout. For our flow, we have defined the name of the macro as `AMUX2_3V`. Therefore, we have to rename the layout file as `AMUX2_3V` and dump out the file again.

# Writing LIB file
LIB file can be got by using a perl script, which converts verilog file to LIB file. 
To view the script

The verilog file is obtained from the efabless github page. But, the names of the pins defined in the verilog file and the layout and LEF file obtained above may be different. 
Therefore, change the pin names in the verilog file accordingly and then obtain the LIB file by using the perl script. 

The modified verilog file and the LIB file can be seen

# top level verilog file
This verilog file contains only instantiations of the macro. The file can be viewed in 

# Experiments with Qflow
OpenROAD does not support OSU018 technology node. Therefore, the placement is done using Qflow.
Qflow can be installed by taking help of the following repository: [VSDFLOW](https://github.com/kunalg123/vsdflow.git)
The tutorial for the same is available  as a free course on [Udemy](https://www.udemy.com/course/vsd-a-complete-guide-to-install-open-source-eda-tools/)

## Setting up directories for using hard macro
The hard macros are intended to be local to the project (although they may be elsewhere and pointed to with symbolic links). Each hard macro should be a subdirectory of "source".
"<hard_macro_dir>" could be a symbolic link to a place where you keep hard macros, if you expect them to be general-purpose macros used for  more than one project.
  
  design1              
	 source                       
		AMUX2_3V_top.v 
		AMUX2_3V                                							
        		AMUX2_3V.lib                                					
        		AMUX2_3V.lef 


Run the qflow:
```javascript 
  cd design1
  qflow -T osu018 AMUX2_3V_top.v
```
On running the above command, a file called `project_vars.sh` will be created. In that file, fill the options as shown below

## Running sythesis for analog multiplexer
Run the following script
```javascript 
  qflow synthesize -T osu018 AMUX2_3V_top.v
```
If the synthesis ran successfully, then `AMUX2_3V.ys` and `AMUX2_3V.blif` files will be generated.

In case of any errors,
```javascript 
  cd Logs
  gedit synth.log
  cd ../
```
Check the errors in the log file. If `AMUX2_3V_top.v` and `AMUX2_3V.lib` are correct, then the synth should run successfully. 
In the `AMUX2_3V.ys` file, liberty files must be read and `AMUX2_3V` must be considered as a macro and not as a module.

## Running placement for analog multiplexer
To run the placement,
```javascript 
  qflow placement -T osu018 AMUX2_3V_top.v
```
In case of any errors,
```javascript 
  cd Logs
  gedit place.log
  cd ../
```
check the log file. If the synthesis ran correctly and the `AMUX2_3V.lef` file is correct, then placement should run successfully.
The graywolf window must open when running placement. If it runs correctly, then it should window should be as shown in the figure below.

# Future Work
To obtain complete RTL2GDS flow for mixed signal SoC on OpenROAD using sky130 PDK.

# Contact Information
- Praharsha Mahurkar, BE Electronics and Telecommunication, Maharashtra Institute of Technology, Pune, 	praharshapm@gmail.com
- Kunal Ghosh Director, VSD Corp. Pvt. Ltd. kunalpghosh@gmail.com

# References
- Sini Mukundan
