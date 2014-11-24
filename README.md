# NaNMath

Implementations of basic math functions which return ``NaN`` instead of throwing a ``DomainError``.

Example:
```julia
import NaNMath
NaNMath.log(-100) # NaN
NaNMath.pow(-1.5,2.3) # NaN
```


[![Build Status](https://travis-ci.org/mlubin/NaNMath.jl.svg?branch=master)](https://travis-ci.org/mlubin/NaNMath.jl)
