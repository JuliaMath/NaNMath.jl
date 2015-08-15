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

function sum(x::Array{Float64,1})
    result = NaN
    for i = x
        if !isnan(i)
            if isnan(result)
                result = i
            else
                result += i
            end
        end
    end
    if size(x)[1] == 0
        result = 0.0
    end
    if isnan(result)
        Base.warn_once("All elements of the array, passed to \"sum\" are NaN!")
    end
    return result
end

end
