module NaNMath

using OpenLibm_jll
const libm = OpenLibm_jll.libopenlibm

for f in (:sin, :cos, :tan, :asin, :acos, :acosh, :atanh, :log, :log2, :log10,
          :lgamma, :log1p)
    @eval begin
        ($f)(x::Float64) = ccall(($(string(f)),libm), Float64, (Float64,), x)
        ($f)(x::Float32) = ccall(($(string(f,"f")),libm), Float32, (Float32,), x)
        ($f)(x::Real) = ($f)(float(x))
    end
end

# Would be more efficient to remove the domain check in Base.sqrt(),
# but this doesn't seem easy to do.
sqrt(x::T) where {T<:AbstractFloat} = x < 0.0 ? T(NaN) : Base.sqrt(x)
sqrt(x::Real) = sqrt(float(x))

# Don't override built-in ^ operator
pow(x::Float64, y::Float64) = ccall((:pow,libm),  Float64, (Float64,Float64), x, y)
pow(x::Float32, y::Float32) = ccall((:powf,libm), Float32, (Float32,Float32), x, y)
# We `promote` first before converting to floating pointing numbers to ensure that
# e.g. `pow(::Float32, ::Int)` ends up calling `pow(::Float32, ::Float32)`
pow(x::Number, y::Number) = pow(promote(x, y)...)
pow(x::T, y::T) where {T<:Number} = pow(float(x), float(y))

"""
NaNMath.sum(A)

##### Args:
* `A`: An array of floating point numbers

##### Returns:
*    Returns the sum of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath
NaNMath.sum([1., 2., NaN]) # result: 3.0
```
"""
function sum(x::AbstractArray{T}) where T<:AbstractFloat
    if length(x) == 0
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
        @warn "All elements of the array, passed to \"sum\" are NaN!"
    end
    return result
end

"""
NaNMath.median(A)

##### Args:
* `A`: An array of floating point numbers

##### Returns:
*   Returns the median of all elements in the array, ignoring NaN's.
    Returns NaN for an empty array or array containing NaNs only.

##### Examples:
```jldoctest
julia> using NaNMath

julia> NaNMath.median([1., 2., 3., NaN])
2.

julia> NaNMath.median([1., 2., NaN])
1.5

julia> NaNMath.median([NaN])
NaN
```
"""
median(x::AbstractArray{<:AbstractFloat}) = median(collect(Iterators.flatten(x)))

function median(x::AbstractVector{<:AbstractFloat})

    x = sort(filter(!isnan, x))

    n = length(x)
    if n == 0
        return convert(eltype(x), NaN)
    elseif isodd(n)
        ind = ceil(Int, n/2)
        return x[ind]
    else
        ind = Int(n/2)
        lower = x[ind]
        upper = x[ind+1]
        return (lower + upper) / 2
    end

end

"""
NaNMath.maximum(A)

##### Args:
* `A`: An array of floating point numbers

##### Returns:
*    Returns the maximum of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath
NaNMath.maximum([1., 2., NaN]) # result: 2.0
```
"""
function maximum(x::AbstractArray{T}) where T<:AbstractFloat
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
* `A`: An array of floating point numbers

##### Returns:
*    Returns the minimum of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath
NaNMath.minimum([1., 2., NaN]) # result: 1.0
```
"""
function minimum(x::AbstractArray{T}) where T<:AbstractFloat
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
NaNMath.extrema(A)

##### Args:
* `A`: An array of floating point numbers

##### Returns:
*    Returns the minimum and maximum of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath
NaNMath.extrema([1., 2., NaN]) # result: 1.0, 2.0
```
"""
function extrema(x::AbstractArray{T}) where T<:AbstractFloat
    resultmin, resultmax = convert(eltype(x), NaN), convert(eltype(x), NaN)
    for i in x
        if !isnan(i)
            if (isnan(resultmin) || i < resultmin)
                resultmin = i
            end
            if (isnan(resultmax) || i > resultmax)
                resultmax = i
            end
        end
    end
    return resultmin, resultmax
end

"""
NaNMath.mean(A)

##### Args:
* `A`: An array of floating point numbers

##### Returns:
*    Returns the arithmetic mean of all elements in the array, ignoring NaN's.

##### Examples:
```julia
using NaNMath
NaNMath.mean([1., 2., NaN]) # result: 1.5
```
"""
function mean(x::AbstractArray{T}) where T<:AbstractFloat
    return mean_count(x)[1]
end

"""
Returns a tuple of the arithmetic mean of all elements in the array, ignoring NaN's,
and the number of non-NaN values in the array.
"""
function mean_count(x::AbstractArray{T}) where T<:AbstractFloat
    z = zero(eltype(x))
    sum = z
    count = 0
    @simd for i in x
        count += ifelse(isnan(i), 0, 1)
        sum += ifelse(isnan(i), z, i)
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
using NaNMath
NaNMath.var([1., 2., NaN]) # result: 0.5
```
"""
function var(x::Vector{T}) where T<:AbstractFloat
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
using NaNMath
NaNMath.std([1., 2., NaN]) # result: 0.7071067811865476
```
"""
function std(x::Vector{T}) where T<:AbstractFloat
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
min(x::T, y::T) where {T<:AbstractFloat} = ifelse((y < x) | (signbit(y) > signbit(x)),
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
max(x::T, y::T) where {T<:AbstractFloat} = ifelse((y > x) | (signbit(y) < signbit(x)),
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
