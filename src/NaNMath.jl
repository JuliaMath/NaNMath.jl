VERSION >= v"0.4.0-dev+6521" && __precompile__()
module NaNMath

using Compat

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

end
