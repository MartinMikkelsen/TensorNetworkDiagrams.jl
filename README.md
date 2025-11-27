# TensorNetworkDiagrams.jl
Package to draw tensor networks

## Installation

You can install the package via the Julia package manager. In the Julia REPL, type:

```julia
using Pkg
Pkg.add("TensorNetworkDiagrams")
```

## Usage

To create and visualize tensor network diagrams, you can use the following example code:

```juliajulia
using TensorNetworkDiagrams

mps = MPS(length = 4)
tikz = to_tikz(mps)

save_tex(tikz, "examples/mps.tex")

mpo = MPO(4)
tikz_mpo = to_tikz(mpo)
save_tex(tikz_mpo, "examples/mpo.tex")
````

And then compile the generated `.tex` files using tectonic to visualize the tensor networks.

```
tectonic examples/mps.tex
tectonic examples/mpo.tex
```
