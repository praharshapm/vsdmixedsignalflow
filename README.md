# OpenROAD RTL2GDS flow for Mixed Signal SoC
This project describes how the synthesis and placement of an analog IP, 2:1 analog multiplexer is carried out by opensource EDA tools. It also discusses the steps to modify the current IP layouts inorder to ensure its acceptance by the EDA tools. 

# Table of Contents

- [Mixed Signal SoC](#mixed-signal-soc)
- [RTL2GDS flow of mixed signal SoC](#rtl2gds-flow-of-mixed-signal-soc)
- [The OpenROAD Project](#the-openroad-project)
- [OpenROAD tools installation](#openroad-tools-installation)
- [Inputs required for physical design](#inputs-required-for-physical-design)
- [Obtaining IP](#obtaining-ip)
- [Obtaining verilog files](#obtaining-verilog-files)
- [Getting LEF file](#getting-lef-file)
- [Limitations of current IP layouts](#limitations-of-current-ip-layouts)
- [Resolving the pin issue](#resolving-the-pin-issue)
	- [For the labels on metal layers:](#for-the-labels-on-metal-layers)
	- [For the labels on polysilicon layers:](#for-the-labels-on-polysilicon-layers) 
- [Writing LIB file](#writing-lib-file)
- [Top level verilog file](#top-level-verilog-file)
- [Experiments with Qflow](#experiments-with-qflow)
    - [setting up directories for using hard macro](#setting-up-directories-for-using-hard-macro)
    - [Running sythesis for analog multiplexer](#running-synthesis-for-analog-multiplexer)
    - [Running placement for analog multiplexer](#running-placement-for-analog-multiplexer)
- [Future Work](#future-work)
- [Contact Information](#contact-information)
- [References](#references)
   

# Mixed Signal SoC

Mixed signal SoC is a chip which contains both analog and digital blocks. The designers are adding more analog circuitry and increasing their complexities day by day. Not only that, they also contain digital control logic. As the process nodes shrink, the demand for integration grows. A divide and conquer approach is followed, where the analog and digital structures were dealt with separately. Usually, an analog IP (Intellectual Property) is bought as black- box. 

<img align="center" width="500"  src="/images/mixed_signal_soc.JPG">


# RTL2GDS flow of mixed signal SoC

To implement a RTL-to-GDS flow for mixed signal SoC, there is need to establish communication between the analog and digital blocks. For this integration to happen, hierarchical level of abstraction with either analog or digital as top level is required. In order to carry out this task, OpenROAD project can be utilized. 

# The OpenROAD Project

In order to carry out this task, OpenROAD project can be utilized. OpenROAD, is a ‘no human in loop’ hardware compiler which translates source code (RTL) to layouts (GDS). The time required for the translation is less than 24 hours. It is a DARPA initiative, an open source project. RTL2GDS flow of OpenROAD is used only for digital SoC. Hence, with OpenROAD, we can establish digital as our top level hierarchy

For more details visit [The OpenROAD Project](https://github.com/The-OpenROAD-Project)

# OpenROAD tools installation

For detailed installation steps, go to [Steps to install OpenROAD tools.pdf](Steps%20to%20install%20OpenROAD%20tools.pdf)

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
<img align="center" width="500"  src="/images/amux.JPG">

# Getting LEF file

The LEF file can be obtained from magic layout synthesis tool from mag file . 


The IP uses OSU018 as the technology node. So it is essential that the tech file for OSU018 is downloaded in the machine. The tech file is present in this repository as [osu018.tech](osu018.tech).

From the terminal type the following :

```javascript 
cd avsdmux2x1_3v3/Layout
magic -T osu018.tech 21muxlayout.mag
```
<img align="center" width="500"  src="/images/21muxlayout.png">

A layout window and a tkcon window will open. In the tkcon window, type the following command to dump out the LEF file

```javascript 
lef write AMUX2_3V.lef
```

# Limitations of current IP layouts
On opening the LEF file, it is observed that it is incomplete. The file does not contain the pin descriptions. 
On observing the layout from the layout window, we can see that the pins are not present. Only labels are present in the layout. And the magic tool is not able to identify these labels. 
This incomplete LEF file would not be accepted by the PnR tools.

# Resolving the pin issue
To convert the labels into pins, a command called `port` can be used in magic.

## For the labels on metal layers:
- Select the area under which the label is present. 

<img align="center" width="500"  src="/images/selecting%20VDD.png">

- In the tkcon window type 
  ```javascript 
  port make
  ```
  To verify if the port is made 
    ```javascript 
    port name
    ```
 <img align="center" width="500"  src="/images/port.png">   

- Similarly, carry out the same process for other labels

<img align="center" width="500"  src="/images/tkcon%20window.png">

## For the labels on polysilicon layers:


<img align="center" width="500"  src="/images/polysilicon.png">

- Type `g` to enable the grid option
- delete the label on `polysilicon` layer by selecting the area where label is present and typing the following in tkcon window
   ```javascript 
  erase labels
  ```
- Connect a `polycontact` layer on the `polysilicon` on one side
- To the `polycontact`, connect a `metal1` layer . 
- Overlap the `metal1` layer with `m1p`.
- Remove DRC errors if any.
- Create a label on `metal1` layer , by selecting a point on the layer and in tkcon window, typing
  ```javascript 
  label 'name_of_label'
  ```
- Continue the same process for turning a label into port as mentioned above.

<img align="center" width="500"  src="/images/select%20pin.png">

Now, dump out the LEF file again by using 
```javascript 
lef write AMUX2_3V.lef
```
All the pins and their descriptions can now be seen.

A section called `OBS` must also be seen at the end of the file. If it is not visible, it means that the label on polysilicon is not converted into port properly.

In the LEF file, we can observe that the name of macro is 21muxlayout. This is because the name of the layout file was 21muxlayout. For our flow, we have defined the name of the macro as `AMUX2_3V`. Therefore, we have to rename the layout file as `AMUX2_3V` and dump out the file again.

# Writing LIB file
LIB file can be got by using a perl script, which converts verilog file to LIB file. The script is taken from the website [VLSI Professional Network](https://vlsi.pro/creating-lib-file-from-verilog/). It is written by Ms Sini Mukundan.
To view the script, go to `verilog_to_lib.pl`

The verilog file is obtained from the efabless github page. But, the names of the pins defined in the verilog file and the layout and LEF file obtained above may be different. 
Therefore, change the pin names in the verilog file accordingly and then obtain the LIB file by using the perl script by typing the following on terminal

```javascript 
perl verilog_to_lib.pl AMUX2_3V AMUX2_3V
```

The modified verilog file and the LIB file can be viewed from [AMUX2_3V.v](AMUX2_3V.v) and [AMUX2_3V.lib](AMUX2_3V.lib) directory. 

# Top level verilog file
This verilog file contains only instantiations of the macro. The file can be viewed in [AMUX2_3V_top.v](AMUX2_3V_top.v) directory. 

# Experiments with Qflow
OpenROAD does not support OSU018 technology node. Therefore, the placement is done using Qflow.
Qflow can be installed by taking help of the following repository: [VSDFLOW](https://github.com/kunalg123/vsdflow.git)
The tutorial for the same is available  as a free course on [Udemy](https://www.udemy.com/course/vsd-a-complete-guide-to-install-open-source-eda-tools/)

## Setting up directories for using hard macro
The hard macros are intended to be local to the project (although they may be elsewhere and pointed to with symbolic links). Each hard macro should be a subdirectory of "source".
"<hard_macro_dir>" could be a symbolic link to a place where you keep hard macros, if you expect them to be general-purpose macros used for more than one project.
  
  - design1              
  	- source                       
		- AMUX2_3V_top.v 
		- AMUX2_3V                                							
        		
			- AMUX2_3V.lib                                					
        		
			- AMUX2_3V.lef 


Run the qflow:
```javascript 
  cd design1
  qflow -T osu018 AMUX2_3V_top.v
```
On running the above command, a file called `project_vars.sh` will be created. In that file, fill the options as shown below

<img align="center" width="500"  src="/images/project_vars.png">

## Running synthesis for analog multiplexer
To run synthesis,
```javascript 
  qflow synthesize -T osu018 AMUX2_3V_top.v
```
If the synthesis ran successfully, then `AMUX2_3V.ys` and `AMUX2_3V.blif` files will be generated.

In case of any errors,
```javascript 
  cd logs
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
  cd logs
  gedit place.log
  cd ../
```
check the log file. If the synthesis ran correctly and the `AMUX2_3V.lef` file is correct, then placement should run successfully.
The graywolf window must open when running placement. If it runs correctly, then the window should be as shown in the figure below.

<img align="center" width="500"  src="/images/placement.JPG">

# Experiments with Openlane and sky130

OpenLANE is an automated RTL to GDSII flow based on several components including OpenROAD, Yosys, Magic, Netgen, Fault and custom methodology scripts for design exploration and optimization.

## Installation
Openlane along with sky130 PDK can be downloaded and installed by following the steps in [this](https://github.com/nickson-jose/openlane_build_script) repository. 

## Adding a new project 
In the `designs` directory create a folder with the name of the project
```javascript 
 cd designs
 mkdir design_mux
```
## setting up the new project
To set-up the project, run the following :
Go to the `~/openlane_working_dir/openlane` and execute the following:
```javascript 
export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks reside>
```
```javascript 
docker run -it -v $(pwd):/openLANE_flow -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) openlane:rc2
```
```javascript 
 ./flow.tcl -design design_mux -init_design_config
```
<img align="center" width="500"  src="/images/bash%20shell.png">
This will create `config.tcl` file with default settings. The final `config.tcl` file can be seen from [here](). This file also contains the reasons for some configurations as comments.

The information about configuration veriables can be found [here](https://github.com/efabless/openlane/blob/master/configuration/README.md)

## Adding input files

### Verilog files
The input files are to added under `~/designs/design_mux/src` directory. 
The `src`folder consists of verilog files for the design which may be found in the `verilog` section of this repository. 

- `design_mux.v` is the name of the top level verilog file.
- `AMUX2_3V.v` is the verilog file of the macro. 
- `raven_spi.v` and `spi_slave.v` are the files to be included in the design.

### LEFs
LEF file can be obtained from the IP layouts using magic. 

The labels can be converted to pins using the same method mentioned [here](#resolving-the-pin-issue)

In addition to converting pins from labels, there are certain other lines included in the LEF file, such that it can be accepted by the openlane tool:
- ` CLASS CORE`

This line can be added using the following command in the tkcon window:
```javascript 
 property LEFclass CORE
```
- ` ORIGIN 0.000 0.000 `

The layout must start from the origin (0,0)
In order to get this: 
1. first find out the current co-ordinates of origin by:
selecting the whole layout and type the following in tkcon window
```javascript 
box
```
From this, llx and lly are X and Y co-ordinates respectively.
2. setting X co-ordinate to 0:
```javascript 
move origin right 'llx'
```
3. setting Y co-ordinate to 0:
```javascript 
move origin bottom -`lly`
```
4. checking if the origin has shifted to (0,0):
first find out the current co-ordinates of origin by:
```javascript 
box
```
Now, the llx and lly should have the value of 0.

- `SITE unithddbl`

To set this, type the following from tkcon window:
```javascript 
 property LEFsite unithddbl
```
- `SIZE`

The height of the macro must be either 2.72 um or 5.444 um in order to fit into the rails ( for fd_sc_hd) . In order to acheive this, first find the current height of the macro by selecting the entire macro and typing the following in tkcon window:
```javascript 
box
```
Then, find the value by which it should be scaled to get height=5.44 um.
Save the magic file.

Next, add the following in the .mag file:
```javascript 
magscale 10075 1000
```
Reload the file in magic. Check the height of the macro now by typing the following in tkcon window:
```javascript 
box
```
The height should be 5.44 um now. Remove the `magscale` line from .mag file and save the file.

- `DIRECTION`

Select the part which contains the pin and type the following in tkcon window:
 - For Power and Ground pins:
	
	 ```javascript 
         port class inout
         ```
- For Input pins:
	   
	   ```javascript 
           port class input
           ```
- For Output pins:

	    ```javascript 
            port class output
            ```
- `USE`

Select the part which contains the pin and type the following in tkcon window:
	- Power pin:
	  ```javascript 
          port use power
          ```
	- Ground pin:
	  ```javascript 
          port use ground
          ```
	- Other pins:
	  ```javascript 
          port use signal
          ```
	  
Ultimately, after configuring all the lines for LEF, create a LEF file by typing the following in tkcon window:
```javascript 
lef write AMUX2_3V.lef
```

<img align="center" width="500"  src="/images/lef.JPG">
# The flow
To harden a macro, the automated flow for Openlane cannot by used. Instead an interactive script should be used. 

Go to the `~/openlane_working_dir/openlane` and execute the following:
```javascript 
export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks reside>
```
```javascript 
docker run -it -v $(pwd):/openLANE_flow -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) openlane:rc2
```
A bash window will open. In the bash window, the interactive flow is executed. The commands to be executed are also present in a script [here]():
## Setting up flow
```javascript 
package require openlane 0.9
```
```javascript 
prep -design design_mux -overwrite
```
## The LEF file for macro must be added from the bash window
```javascript 
set lefs 	 [glob $::env(DESIGN_DIR)/src/lef/*.lef]
```
```javascript 
add_lefs -src $lefs
```
## Synthesis
```javascript 
run_synthesis
```
## Floorplanning
```javascript 
init_floorplan_or
```
After floorplanning, the layout can be viewed in magic using the merged LEF and DEF file produced.
<img align="center" width="500"  src="/images/floorplan.JPG">
## IO Placement
```javascript 
place_io
```
## Placement
```javascript 
global_placement_or
```
```javascript 
detailed_placement
```
```javascript 
tap_decap_or
```
```javascript 
detailed_placement
```
After final placement, the layout can be viewed in magic using merged LEF and DEF file.

<img align="center" width="500"  src="/images/placement.JPG">
## Generation of Power Delivery Network(PDN)
```javascript 
gen_pdn
```
## Routing
```javascript 
run_routing
```
After routing, the layout can be viewed in magic using merged LEF and DEF file.
<img align="center" width="500"  src="/images/routing.JPG">
## DRC Cleaning
```javascript 
run_magic_drc
```
## Final Layout generation
```javascript 
run_magic
```

The final layout output is in the form of `design_mux.mag` 
<img align="center" width="500"  src="/images/layout%20final.JPG">

# Notes and Tips
- You may have to update RePlace to the latest version if you wish to run placement for low instance count designs.
- If, the error still persists in placement, check if following block of code in `~scripts/openroad/or_replace.tcl` is commented. If not, comment it. 
```javascript 
global_placement \
 	-density $::env(PL_TARGET_DENSITY) \
 	-verbose 3
```
- The verilog files must not contain the power and ground pins. 
- Add the macro LEF both in the `config.tcl` file and in the interactive flow.




	 

# Future Work
To obtain complete RTL2GDS flow for mixed signal SoC on OpenROAD using sky130 PDK.

# Contact Information
- Praharsha Mahurkar, BE Electronics and Telecommunication, Maharashtra Institute of Technology, Pune, 	praharshapm@gmail.com
- Kunal Ghosh, Director, VSD Corp. Pvt. Ltd. kunalpghosh@gmail.com

# References
- Sini Mukundan, Creating .lib file from verilog
