__precompile__()
module NaNMath

using Compat

for f in (:sin, :cos, :tan, :asin, :acos, :acosh, :atanh, :log, :log2, :log10,
          :lgamma, :log1p)
    @eval begin
        ($f)(x::Float64) = ccall(($(string(f)),Base.Math.libm), Float64, (Float64,), x)
        ($f)(x::Float32) = ccall(($(string(f,"f")),Base.Math.libm), Float32, (Float32,), x)
        ($f)(x::Real) = ($f)(float(x))
        if VERSION >= v"0.5.0-dev+4002"
            function ($f){T<:Number}(x::AbstractArray{T})
                Base.depwarn("$f{T<:Number}(x::AbstractArray{T}) is deprecated, use $f.(x) instead.", $f)
                return ($f).(x)
            end
        else
            ($f){T<:Number}(x::AbstractArray{T}) = broadcast($f, x)
        end
    end
end

# Would be more efficient to remove the domain check in Base.sqrt(),
# but this doesn't seem easy to do.
sqrt(x::Real) = x < 0.0 ? NaN : Base.sqrt(x)

# Don't override built-in ^ operator
pow(x::Float64, y::Float64) = ccall((:pow,Base.Math.libm),  Float64, (Float64,Float64), x, y)
pow(x::Float32, y::Float32) = ccall((:powf,Base.Math.libm), Float32, (Float32,Float32), x, y)
pow(x::Number,y::Number) = pow(float(x),float(y))

"""
NaNMath.sum(A)

##### Args:
* `A`: A one dimensional array of floating point numbers

##### Returns:
*    Returns the sum of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath as nm
nm.sum([1., 2., NaN]) # result: 3.0
```
"""
function sum{T<:AbstractFloat}(x::Vector{T})
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

"""
NaNMath.maximum(A)

##### Args:
* `A`: A one dimensional array of floating point numbers

##### Returns:
*    Returns the maximum of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath as nm
nm.maximum([1., 2., NaN]) # result: 2.0
```
"""
function maximum{T<:AbstractFloat}(x::Vector{T})
    result = convert(eltype(x), NaN)
    for i in x
        if !isnan(i)
            if (isnan(result) || i > result)
                result = i
            end
        end
    end
    return result
end

"""
NaNMath.minimum(A)

##### Args:
* `A`: A one dimensional array of floating point numbers

##### Returns:
*    Returns the minimum of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath as nm
nm.minimum([1., 2., NaN]) # result: 1.0
```
"""
function minimum{T<:AbstractFloat}(x::Vector{T})
    result = convert(eltype(x), NaN)
    for i in x
        if !isnan(i)
            if (isnan(result) || i < result)
                result = i
            end
        end
    end
    return result
end

"""
NaNMath.mean(A)

##### Args:
* `A`: A one dimensional array of floating point numbers

##### Returns:
*    Returns the arithmetic mean of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath as nm
nm.mean([1., 2., NaN]) # result: 1.5
```
"""
function mean{T<:AbstractFloat}(x::Vector{T})
    return mean_count(x)[1]
end

"""
Returns a tuple of the arithmetic mean of all elements in the array, ignoring NaN's,
and the number of non-NaN values in the array.
"""
function mean_count{T<:AbstractFloat}(x::Vector{T})
    sum = convert(eltype(x), NaN)
    count = 0
    for i in x
        if !isnan(i)
            if isnan(sum)
                sum = i
                count = 1
            else
                sum += i
                count += 1
            end
        end
    end
    result = sum / count
    return (result, count)
end

"""
NaNMath.var(A)

##### Args:
* `A`: A one dimensional array of floating point numbers

##### Returns:
* Returns the sample variance of a vector A. The algorithm will return
  an estimator of the  generative distribution's variance under the
  assumption that each entry of v is an IID drawn from that generative
  distribution. This computation is  equivalent to calculating \\
  sum((v - mean(v)).^2) / (length(v) - 1). NaN values are ignored.

##### Examples:
```julia
using NaNMath as nm
nm.var([1., 2., NaN]) # result: 0.5
```
"""
function var{T<:AbstractFloat}(x::Vector{T})
    mean_val, n = mean_count(x)
    if !isnan(mean_val)
        sum_square = zero(eltype(x))
        for i in x
            if !isnan(i)
                sum_square += (i - mean_val)^2
            end
        end
        return sum_square / (n - one(eltype(x)))
    else
        return mean_val # NaN or NaN32
    end
end

"""
NaNMath.std(A)

##### Args:
* `A`: A one dimensional array of floating point numbers

##### Returns:
* Returns the standard deviation of a vector A. The algorithm will return
  an estimator of the  generative distribution's standard deviation under the
  assumption that each entry of v is an IID drawn from that generative
  distribution. This computation is  equivalent to calculating \\
  sqrt(sum((v - mean(v)).^2) / (length(v) - 1)). NaN values are ignored.

##### Examples:
```julia
using NaNMath as nm
nm.std([1., 2., NaN]) # result: 0.7071067811865476
```
"""
function std{T<:AbstractFloat}(x::Vector{T})
    return sqrt(var(x))
end

"""
    NaNMath.min(x, y)

Compute the IEEE 754-2008 compliant minimum of `x` and `y`. As of version 0.6 of Julia,
`Base.min(x, y)` will return `NaN` if `x` or `y` is `NaN`. `NanMath.min` favors values over
`NaN`, and will return whichever `x` or `y` is not `NaN` in that case.

## Examples

```julia
julia> NanMath.min(NaN, 0.0)
0.0

julia> NaNMath.min(1, 2)
1
```
"""
min{T<:AbstractFloat}(x::T, y::T) = ifelse((y < x) | (signbit(y) > signbit(x)),
                                           ifelse(isnan(y), x, y),
                                           ifelse(isnan(x), y, x))

"""
    NaNMath.max(x, y)

Compute the IEEE 754-2008 compliant maximum of `x` and `y`. As of version 0.6 of Julia,
`Base.max(x, y)` will return `NaN` if `x` or `y` is `NaN`. `NaNMath.max` favors values over
`NaN`, and will return whichever `x` or `y` is not `NaN` in that case.

## Examples

```julia
julia> NaNMath.max(NaN, 0.0)
0.0

julia> NaNMath.max(1, 2)
2
```
"""
max{T<:AbstractFloat}(x::T, y::T) = ifelse((y > x) | (signbit(y) < signbit(x)),
                                           ifelse(isnan(y), x, y),
                                           ifelse(isnan(x), y, x))

min(x::Real, y::Real) = min(promote(x, y)...)
max(x::Real, y::Real) = max(promote(x, y)...)

function min(x::BigFloat, y::BigFloat)
    isnan(x) && return y
    isnan(y) && return x
    return Base.min(x, y)
end

function max(x::BigFloat, y::BigFloat)
    isnan(x) && return y
    isnan(y) && return x
    return Base.max(x, y)
end

# Integers can't represent NaN
min(x::Integer, y::Integer) = Base.min(x, y)
max(x::Integer, y::Integer) = Base.max(x, y)

min(x::Real) = x
max(x::Real) = x

# Multi-arg versions
for f in (:min, :max)
    @eval ($f)(a, b, c, xs...) = Base.afoldl($f, ($f)(($f)(a, b), c), xs...)
end

end
