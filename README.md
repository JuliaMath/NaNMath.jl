# NaNMath

Implementations of basic math functions which return ``NaN`` instead of throwing a ``DomainError``.

Example:
```julia
import NaNMath
NaNMath.log(-100) # NaN
NaNMath.pow(-1.5,2.3) # NaN
```

In addition this package provides functions that aggregate one dimensional arrays and ignore elements that are NaN.
The following functions are implemented:

```
sum
maximum
minimum
mean
var
std
min
max
```

Example:
```julia
using NaNMath; nm=NaNMath
nm.sum([1., 2., NaN]) # result: 3.0
```

[![Build Status](https://travis-ci.org/mlubin/NaNMath.jl.svg?branch=master)](https://travis-ci.org/mlubin/NaNMath.jl)
