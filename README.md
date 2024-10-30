# LabUtils.jl
This repository provides some basic utility needed for my Physics lab. \
Implementation is not very nice as this Library was written while paralel aquering the Julia skills to write this library. \
But feel free to take the code as Inspiration or just to mess around but also be awere that there may are more Elegant solutions out there. 

Also a big focus of this utilitys was to create comprehensible output log.


## Documentation

### Data Structs

``` julia
struct Data
    v
    σsys
end

struct DataMultiMes
    v::Vector
    σsys
end

struct DataDerived
    v
    σtot
end
```
These thre structs are used to store data or results of uncertanty Propagation on some data.

Data: is used for a single messurment with an associated uncertenty.

DataMultiMes: Is used when Multiple Messurments where made.

DataDerived: Is used to store results made when Propagating uncertanty. \
But it can also be used for storing constant's witch come with a certain uncertanty.


### Propagate Uncertanty
```julia
function propagate_uncertanty(vₛ , eq  ,MessDict , file)
```
This Function takes for input $v_s$ reprsents the variable for which the equation eq shold be solved.

Mess dict shold be a Dictionary wher the keys are variables and the values are one of the Data Structs

The parameter expects a file where the calculations made are logged in LaTeX code

