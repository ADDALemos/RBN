# Abstract 
***
Boolean logical models of biological regulatory and signalling networks are increasingly used to formally describe and understand complex biological processes.
Such models often need to be repaired whenever new observations become available, rendering the model inconsistent with the new observations.
Although many studies have focuses on inferring new models (or classes of models) from data, the automation of model repair is still in its infancy, often still being a manual process and therefore prone to errors.

In this work, a tool is provided to suggest possible repair operations to inconsistent models based on changing the model logical functions.
The tool uses Answer Set Programming to identify possible repair operations to the models following both synchronous or asynchronous updating schemes. 

The tool was validated using both Boolean models of randomly generated networks and data sets of Escherichia coli at steady state.
The limitations of the implemented tool for each of the updating schemes are discussed. The impact of the minimization algorithm is also addressed.

***

# How to run the project

`./Converter type [asynchronous|synchronous|steady_state] repair[e|i|g|combinations] examples/Model.net [examples/Obs1.obs examples/Obsn.obs]`
This will generate the repair models in the examples folder.

## Arguments of the program

### Type:

If the model is asynchronous, synchronous or is in steady state.

### Available repair operations:

* Repair e - removes regulator
* Repair i - negates a regulator
* Repair g - changes AND function to OR function

Note: All the combinations of repairs are allowed, and they need to be written in alphabetical order.

Some examples with small networks are available in the folder: `examples/steady/repairs`, showing the effects of the repair operations.

### Model

The model has to be encoded in boolSim ([format](http://www.colomoto.org/formats/boolsim.html)). 

### Experimental values

The program can deal with 0 or more observations. The observations correspond to a time-series and the time-series is organized in a matrix. As this argument is optional when not present the program will infer the data to minimize the number of repair operations needed.


***

# Dependencies
An ASP solver (contained in the source folder) and available at:

[clingo](https://github.com/potassco/clingo)

Uses the Quince McCluskey algorithm available at:

[Quine-McCluskey](https://github.com/pfpacket/Quine-McCluskey) (to compile requires the Boost C++ Libraries) [boost.org](http://www.boost.org/)

***

## Data Sets

### Steady State

In the folder `examples/steady/ecoli` two data sets originally obtained from [Gebser et al](http://www.cs.uni-potsdam.de/bioasp/KR10/) are available.
As the model did not have functions associated with them, all nodes are explained by the same function, where a biological component is present if it has at least one activator and has no inhibitors.

### Time-series

The data sets in the folder `examples/time/modeloriginal` and `examples/time/modelCorrupted` were originally obtained from [Merhej et al](https://github.com/eliemerhejUGENT/repairInconsistentASP).

The data sets in the folder `examples/time/#networksize` were randomly generated using the program available on the folder scripts. The model was generated using the script available at [BoolNetR2GINsim](https://github.com/ptgm/BoolNetR2GINsim).

***

# Authors
[Alexandre Lemos](http://web.ist.utl.pt/ist173316/), [Pedro T. Monteiro](http://pedromonteiro.org/) and [Inês Lynce](http://sat.inesc-id.pt/~ines/).

# Contacts:
If you have any comments or questions, please [contact us](mailto:ines.lynce@tecnico.ulisboa.pt;alexandre.lemos@tecnico.ulisboa.pt;pedro.tiago.monteiro@tecnico.pt;?subject=[Repairing%20Boolean%20regulatory%20networks]).

# Previous Work
[Repairing Steady State Boolean Regulatory Network](http://web.ist.utl.pt/~alexandre.lemos/rbn/)
