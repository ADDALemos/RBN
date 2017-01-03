# Abstract 
***
Bla

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

Some examples with small networks are available in the folder: `examples/repairs`, showing the effects of the repair operations.

### Model

The model has to be encoded in Boolsim ([format](http://www.colomoto.org/formats/boolsim.html)). 

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
In the folder examples/steady two data sets originally obtained from  are available.
As the model did not have functions associated with them, all nodes are explained by the same function, where a biological component is present if it has at least one activator and has no inhibitors.
### Time-series
The data sets in the folder examples/time were randomly generated using the program available on the folder scripts. The model was generated using the script available at [BoolNetR2GINsim](https://github.com/ptgm/BoolNetR2GINsim).
***
# Authors
Alexandre Lemos, [Pedro T. Monteiro](http://pedromonteiro.org/) and [Inês Lynce](http://sat.inesc-id.pt/~ines/).
# Contacts:
If you have any comments or questions, please [contact us](mailto:ines.lynce@tecnico.ulisboa.pt;alexandre.lemos@tecnico.ulisboa.pt;pedro.tiago.monteiro@tecnico.pt;?subject=[Repairing%20Boolean%20regulatory%20networks]).

# Previous Work
[Repairing Steady State Boolean Regulatory Network](http://web.ist.utl.pt/~alexandre.lemos/rbn/)
