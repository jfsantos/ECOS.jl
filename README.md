# ECOS.jl

Julia wrapper for the [ECOS](https://github.com/embotech/ecos) embeddable conic
optimization interior point solver.

[![Build Status](https://github.com/jump-dev/ECOS.jl/workflows/CI/badge.svg?branch=master)](https://github.com/jump-dev/ECOS.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/jump-dev/ECOS.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jump-dev/ECOS.jl)

## Installation

You can install ECOS.jl through the Julia package manager:
```julia
julia> Pkg.add("ECOS")
```

ECOS.jl will automatically install and setup the ECOS solver itself using [BinaryProvider.jl](https://github.com/JuliaPackaging/BinaryProvider.jl).

## Custom Installation

After ECOS.jl is installed and built, you can replace the installed `libecos` dependency with a custom installation by following the [Pkg documentation for overriding artifacts](https://julialang.github.io/Pkg.jl/v1/artifacts/#Overriding-artifact-locations-1). Note that your custom `libecos` is required to be at least version 2.0.5.

## Usage

The ECOS interface is completely wrapped. ECOS functions corresponding to the C API are available as `ECOS.setup`, `ECOS.solve`, `ECOS.cleanup`, and `ECOS.ver` (these are not exported from the module). Function arguments are extensively documented in the source, and an example of usage can be found in `test/direct.jl`.

ECOS.jl also supports the **[MathOptInterface](https://github.com/jump-dev/MathOptInterface.jl)** standard solver interface.
Thanks to this support ECOS can be used as a solver with both the **[JuMP]** and **[Convex.jl]** modeling languages.

All ECOS solver options can be set through the direct interface and through MathOptInterface.
The list of options is defined the [`ecos.h` header](https://github.com/embotech/ecos/blob/master/include/ecos.h), which we reproduce here:
```julia
gamma          # scaling the final step length
delta          # regularization parameter
eps            # regularization threshold
feastol        # primal/dual infeasibility tolerance
abstol         # absolute tolerance on duality gap
reltol         # relative tolerance on duality gap
feastol_inacc  # primal/dual infeasibility relaxed tolerance
abstol_inacc   # absolute relaxed tolerance on duality gap
reltol_inacc   # relative relaxed tolerance on duality gap
nitref         # number of iterative refinement steps
maxit          # maximum number of iterations
verbose        # verbosity bool for PRINTLEVEL < 3
```
To use these settings you can either pass them as keyword arguments to `setup`
(direct interface) or as arguments to the `ECOS.Optimizer` constructor
(MathOptInterface interface), e.g.
```julia
# Direct
my_prob = ECOS.setup(n, m, ..., c, h, b; maxit=10, feastol=1e-5)
# MathOptInterface (with JuMP)
model = Model(with_optimizer(ECOS.Optimizer, maxit=10, feastol=1e-5))
```

### JuMP example

This example shows how we can model a simple knapsack problem with JuMP and use ECOS to solve it.

```julia
using JuMP
using ECOS

items  = [:Gold, :Silver, :Bronze]
values = Dict(:Gold => 5.0,  :Silver => 3.0,  :Bronze => 1.0)
weight = Dict(:Gold => 2.0,  :Silver => 1.5,  :Bronze => 0.3)

model = Model(with_optimizer(ECOS.Optimizer))
@variable(model, 0 <= take[items] <= 1)  # Define a variable for each item
@objective(model, Max, sum(values[item] * take[item] for item in items))
@constraint(model, sum(weight[item] * take[item] for item in items) <= 3)
optimize!(model)

println(value.(take))
# take
# [  Gold] = 0.9999999680446406
# [Silver] = 0.46666670881026834
# [Bronze] = 0.9999999633898735
```

---

`ECOS.jl` is licensed under the MIT License (see LICENSE.md), but note that ECOS itself is GPL v3.

[MathProgBase]: https://github.com/JuliaOpt/MathProgBase.jl
[JuMP]: https://github.com/jump-dev/JuMP.jl
[Convex.jl]: https://github.com/JuliaOpt/Convex.jl
[Homebrew.jl]: https://github.com/JuliaLang/Homebrew.jl
