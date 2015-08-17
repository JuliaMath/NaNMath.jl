VERSION >= v"0.4.0-dev+6521" && __precompile__()
module NaNMath

for f in (:sin, :cos, :tan, :asin, :acos, :acosh, :atanh, :log, :log2, :log10,
          :lgamma, :log1p)
    @eval begin
        ($f)(x::Float64) = ccall(($(string(f)),Base.Math.libm), Float64, (Float64,), x)
        ($f)(x::Float32) = ccall(($(string(f,"f")),Base.Math.libm), Float32, (Float32,), x)
        ($f)(x::Real) = ($f)(float(x))
        @vectorize_1arg Number $f
    end
end

# Don't override built-in ^ operator
pow(x::Float64, y::Float64) = ccall((:pow,Base.Math.libm),  Float64, (Float64,Float64), x, y)
pow(x::Float32, y::Float32) = ccall((:powf,Base.Math.libm), Float32, (Float32,Float32), x, y)
pow(x,y) = pow(float(x),float(y))

"""
NaNMath.sum(A)

##### Args:
* `A`: A one dimensional array of floating point numbers

##### Returns:
*    Returns the sum of all elements in an array, ignoring NaN's.

##### Examples:
```julia
using NaNMath as nm
nm.sum([1., 2., NaN]) # result: 3.0
```
"""
function sum{T<:FloatingPoint}(x::Vector{T})
    if size(x)[1] == 0
        result = zero(eltype(x))
    else
        result = convert(eltype(x), NaN)
        for i in x
            if !isnan(i)
                if isnan(result)
                    result = i
                else
                    result += i
                end
            end
        end
    end

    if isnan(result)
        Base.warn_once("All elements of the array, passed to \"sum\" are NaN!")
    end
    return result
end

end
