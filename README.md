# NaNMath

[![deps](https://juliahub.com/docs/NaNMath/deps.svg)](https://juliahub.com/ui/Packages/NaNMath/k9Y1O?t=2)

Implementations of basic math functions which return ``NaN`` instead of throwing a ``DomainError``.

Example:
```julia
import NaNMath
NaNMath.log(-100) # NaN
NaNMath.pow(-1.5,2.3) # NaN
```

In addition this package provides functions that aggregate arrays and ignore elements that are NaN.
The following functions are implemented:

```
sum
maximum
minimum
extrema
mean
median
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

