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

pow(x::Float64, y::Float64) = ccall((:pow,Base.Math.libm),  Float64, (Float64,Float64), x, y)
pow(x::Float32, y::Float32) = ccall((:powf,Base.Math.libm), Float32, (Float32,Float32), x, y)

end
