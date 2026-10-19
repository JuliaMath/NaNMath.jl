using NaNMath
using Test

@test isnan(NaNMath.log(-10))
@test isnan(NaNMath.log1p(-100))
for T in (Float16, Float32, Float64, BigFloat)
    @test isnan(NaNMath.pow(T(-1.5),T(2.3)))
    @test NaNMath.pow(T(-1.5),T(5)) ≈ T(-1.5) ^ T(5)
end
@test isnan(NaNMath.pow(-1.5,2.3f0))
@test isnan(NaNMath.pow(-1.5f0,2.3))
# `float` rounds this exponent onto an integer-valued `Float64`, so the domain check has
# to look at the original `y`.
@test isnan(NaNMath.pow(-1.5, (2^60 + 1)//2))
@test NaNMath.pow(-1.5f0,2) isa Float32
@test NaNMath.pow(-1.5f0,2//1) isa Float32
@test NaNMath.pow(-1.5f0,2.3f0) isa Float32
@test NaNMath.pow(-1.5f0,2.3) isa Float64
@test NaNMath.pow(-1.5,2) isa Float64
@test NaNMath.pow(-1.5,2//1) isa Float64
@test NaNMath.pow(-1.5,2.3f0) isa Float64
@test NaNMath.pow(-1.5,2.3) isa Float64
@test NaNMath.pow(-1,2) === 1
@test NaNMath.pow(2,2) === 4
@test NaNMath.pow(1.0, 1.0+im) === 1.0 + 0.0im
@test NaNMath.pow(1.0+im, 1) === 1.0 + 1.0im
@test NaNMath.pow(1.0+im, 1.0) === 1.0 + 1.0im
@test isnan(NaNMath.sqrt(-5))
@test NaNMath.sqrt(5) == Base.sqrt(5)
@test isnan(NaNMath.sqrt(-3.2f0)) && NaNMath.sqrt(-3.2f0) isa Float32
@test isnan(NaNMath.sqrt(Float16(-3.2))) && NaNMath.sqrt(Float16(-3.2)) isa Float16
@test NaNMath.sqrt(Float16(5)) === Base.sqrt(Float16(5))
@test isnan(NaNMath.sqrt(-BigFloat(7.0))) && NaNMath.sqrt(-BigFloat(7.0)) isa BigFloat
@test isnan(NaNMath.sqrt(-7)) && NaNMath.sqrt(-7) isa Float64
@inferred NaNMath.sqrt(5)
@inferred NaNMath.sqrt(5.0)
@inferred NaNMath.sqrt(5.0f0)
@inferred NaNMath.sqrt(Float16(5))
@inferred NaNMath.sqrt(-5)
@inferred NaNMath.sqrt(-5.0)
@inferred NaNMath.sqrt(-5.0f0)
@inferred NaNMath.sqrt(Float16(-5))
@test NaNMath.sum([1., 2., NaN]) == 3.0
@test NaNMath.sum([1. 2.; NaN 1.]) == 4.0
@test isnan(NaNMath.sum([NaN, NaN]))
@test NaNMath.sum(Float64[]) == 0.0
@test NaNMath.sum([1f0, 2f0, NaN32]) === 3.0f0
@test NaNMath.maximum([1., 2., NaN]) == 2.0
@test NaNMath.maximum([1. 2.; NaN 1.]) == 2.0
@test NaNMath.minimum([1., 2., NaN]) == 1.0
@test NaNMath.minimum([1. 2.; NaN 1.]) == 1.0
@test NaNMath.extrema([1., 2., NaN]) == (1.0, 2.0)
@test NaNMath.extrema([2., 1., NaN]) == (1.0, 2.0)
@test NaNMath.extrema([1. 2.; NaN 1.]) == (1.0, 2.0)
@test NaNMath.extrema([2. 1.; 1. NaN]) == (1.0, 2.0)
@test NaNMath.extrema([NaN, -1., NaN]) == (-1.0, -1.0)
@test NaNMath.mean([1., 2., NaN]) == 1.5
@test NaNMath.mean([1. 2.; NaN 3.]) == 2.0
@test NaNMath.var([1., 2., NaN]) == 0.5
@test NaNMath.std([1., 2., NaN]) == 0.7071067811865476

@test NaNMath.median([1.]) == 1.
@test NaNMath.median([1., NaN]) == 1.
@test NaNMath.median([NaN, 1., 3.]) == 2.
@test NaNMath.median([1., 3., 2., NaN]) == 2.
@test NaNMath.median([NaN, 1, 3]) == 2.
@test NaNMath.median([1, 2, NaN]) == 1.5
@test NaNMath.median([1 2; NaN NaN]) == 1.5
@test NaNMath.median([NaN 2; 1 NaN]) == 1.5
@test isnan(NaNMath.median(Float64[]))
@test isnan(NaNMath.median(Float32[]))
@test isnan(NaNMath.median([NaN]))

@test NaNMath.min(1, 2) == 1
@test NaNMath.min(1.0, 2.0) == 1.0
@test NaNMath.min(1, 2.0) == 1.0
@test NaNMath.min(BigFloat(1.0), 2.0) == BigFloat(1.0)
@test NaNMath.min(BigFloat(1.0), BigFloat(2.0)) == BigFloat(1.0)
@test NaNMath.min(NaN, 1) == 1.0
@test NaNMath.min(NaN32, 1) == 1.0f0
@test isnan(NaNMath.min(NaN, NaN))
@test isnan(NaNMath.min(NaN))
@test NaNMath.min(NaN, NaN, 0.0, 1.0) == 0.0

@test NaNMath.max(1, 2) == 2
@test NaNMath.max(1.0, 2.0) == 2.0
@test NaNMath.max(1, 2.0) == 2.0
@test NaNMath.max(BigFloat(1.0), 2.0) == BigFloat(2.0)
@test NaNMath.max(BigFloat(1.0), BigFloat(2.0)) == BigFloat(2.0)
@test NaNMath.max(NaN, 1) == 1.0
@test NaNMath.max(NaN32, 1) == 1.0f0
@test isnan(NaNMath.max(NaN, NaN))
@test isnan(NaNMath.max(NaN))
@test NaNMath.max(NaN, NaN, 0.0, 1.0) == 1.0

## Based on https://github.com/sethaxen/NaNMath.jl/blob/41b3e7edd9dd4cb6c2873abf6e0d90acf43138ec/test/runtests.jl
@testset "findmin/findmax" begin
    if VERSION ≥ v"1.7"
        xvals = [
            [1., 2., 3., 3., 1.],
            (1., 2., 3., 3., .1),
            (1f0, 2f0, 3f0, -1f0),
            (x=1.0, y=3f0, z=-4.0, w=-2f0),
            Dict(:a => 1.0, :b => 1.0, :d => 3.0, :c => 2.0),
        ]
        @testset for x in xvals
            @test NaNMath.findmin(x) === findmin(x)
            @test NaNMath.findmax(x) === findmax(x)
            @test NaNMath.findmin(identity, x) === findmin(identity, x)
            @test NaNMath.findmax(identity, x) === findmax(identity, x)
            @test NaNMath.findmin(sin, x) === findmin(sin, x)
            @test NaNMath.findmax(sin, x) === findmax(sin, x)
        end
    end

    x = [7, 7, NaN, 1, 1, NaN]
    @test NaNMath.findmin(x) === (1.0, 4)
    @test NaNMath.findmax(x) === (7.0, 1)
    @test NaNMath.findmin(identity, x) === (1.0, 4)
    @test NaNMath.findmax(identity, x) === (7.0, 1)
    @test NaNMath.findmin(-, x) === (-7.0, 1)
    @test NaNMath.findmax(-, x) === (-1.0, 4)

    x = [NaN, NaN]
    @test NaNMath.findmin(x) === (NaN, 1)
    @test NaNMath.findmax(x) === (NaN, 1)
    @test NaNMath.findmin(identity, x) === (NaN, 1)
    @test NaNMath.findmax(identity, x) === (NaN, 1)
    @test NaNMath.findmin(sin, x) === (NaN, 1)
    @test NaNMath.findmax(sin, x) === (NaN, 1)

    x = Dict(:a => 1.0, :b => 1 + 2im, :d => 3.0, :c => 2.0)
    @test_throws ErrorException NaNMath.findmin(x)
    @test_throws ErrorException NaNMath.findmax(x)

    x = [3, missing, NaN, -1]
    @test_throws ErrorException NaNMath.findmin(x)

    x = Dict('a' => 1.0, missing => NaN, 'c' => 2.0)
    @test NaNMath.findmin(x) === (1.0, 'a')
    @test NaNMath.findmax(x) === (2.0, 'c')

    x = Dict(:x => 3.0, :w => 2f0, :y => -1.0, :z => NaN)
    @test NaNMath.findmin(x) === (-1.0, :y)
    @test NaNMath.findmax(x) === (3.0, :x)
    @test NaNMath.findmin(identity, x) === (-1.0, :y)
    @test NaNMath.findmax(identity, x) === (3.0, :x)
    @test NaNMath.findmin(-, x) === (-3.0, :x)
    @test NaNMath.findmax(-, x) === (1.0, :y)
    @test NaNMath.findmin(exp, x) === (exp(-1.0), :y)
    @test NaNMath.findmax(exp, x) === (exp(3.0), :x)

    x = (x=1.0, y=NaN, z=NaN, w=-2.0)
    @test NaNMath.findmin(x) === (-2.0, :w)
    @test NaNMath.findmax(x) === (1.0, :x)
    @test NaNMath.findmin(-,x) === (-1.0, :x)
    @test NaNMath.findmax(-,x) === (2.0, :w)

    x = [2.0 3.0; 2.0 -1.0]
    @test NaNMath.findmin(x) === (-1.0, CartesianIndex(2, 2))
    @test NaNMath.findmax(x) === (3.0, CartesianIndex(1, 2))
    @test NaNMath.findmin(exp,x) === (exp(-1), CartesianIndex(2, 2))
    @test NaNMath.findmax(exp,x) === (exp(3.0), CartesianIndex(1, 2))
end

@testset "argmin/argmax" begin
    if VERSION ≥ v"1.7"
        xvals = [
            [1., 2., 4., 3., 1.],
            (1., 2., 4., 3., .1),
            (1f0, 2f0, 3f0, -1f0),
            (x=1.0, y=3f0, z=-4.0, w=-2f0),
            Dict(:a => 1.0, :b => 1.0, :d => 3.0, :c => 2.0),
        ]    
        @testset for x in xvals
            @test NaNMath.argmin(x) === argmin(x)
            @test NaNMath.argmax(x) === argmax(x)
            x isa Dict || @test NaNMath.argmin(identity, x) === argmin(identity, x)
            x isa Dict || @test NaNMath.argmax(identity, x) === argmax(identity, x)
            x isa Dict || @test NaNMath.argmin(sin, x) === argmin(sin, x)
            x isa Dict || @test NaNMath.argmax(sin, x) === argmax(sin, x)
        end
    end
    x = [7, 7, NaN, 1, 1, NaN]
    @test NaNMath.argmin(x) === 4
    @test NaNMath.argmax(x) === 1
    @test NaNMath.argmin(identity, x) === 1.0
    @test NaNMath.argmax(identity, x) === 7.0
    @test NaNMath.argmin(-, x) === 7.0
    @test NaNMath.argmax(-, x) === 1.0

    x = [NaN, NaN]
    @test NaNMath.argmin(x) === 1
    @test NaNMath.argmax(x) === 1
    @test NaNMath.argmin(identity, x) === NaN
    @test NaNMath.argmax(identity, x) === NaN
    @test NaNMath.argmin(-, x) === NaN
    @test NaNMath.argmax(-, x) === NaN

    x = [3, missing, NaN, -1]
    @test_throws ErrorException NaNMath.argmin(x)
    @test_throws ErrorException NaNMath.argmax(x)

    x = Dict('a' => 1.0, missing => NaN, 'c' => 2.0)
    @test NaNMath.argmin(x) === 'a'
    @test NaNMath.argmax(x) === 'c'

    x = Dict(:v => NaN, :w => 2.1f0, :x => 3.1, :z => -1.0, :y => NaN)
    @test NaNMath.argmin(x) === :z
    @test NaNMath.argmax(x) === :x
    @test NaNMath.argmin(-, x) === 3.1
    @test NaNMath.argmax(-, x) === -1.0
    @test NaNMath.argmin(exp, x) === -1.0
    @test NaNMath.argmax(exp, x) === 3.1

    x = (x=1.1, y=NaN, z=NaN, w=-2.3)
    @test NaNMath.argmin(x) === :w
    @test NaNMath.argmax(x) === :x
    @test NaNMath.argmin(exp, x) === -2.3
    @test NaNMath.argmax(exp, x) === 1.1

    x = [2.0 3.0; 2.0 -1.0]
    @test NaNMath.argmin(x) === CartesianIndex(2, 2)
    @test NaNMath.argmax(x) === CartesianIndex(1, 2)
    @test NaNMath.argmin(exp,x) === -1.0
    @test NaNMath.argmax(exp,x) === 3.0
end

# Test forwarding
x = 1 + 2im
for f in (:sin, :cos, :tan, :asin, :acos, :acosh, :atanh, :log, :log2, :log10,
          :log1p, :sqrt)
    @test @eval (NaNMath.$f)(x) == $f(x)
end
@test_throws MethodError NaNMath.lgamma(x)

struct A end
Base.isless(::A, ::A) = false
y = A()
for f in (:max, :min)
    @test @eval (NaNMath.$f)(y, y) == $f(y, y)
end
@test NaNMath.pow(x, x) == ^(x, x)

@testset "acosh" begin
    for T in (Float16, Float32, Float64)
        y = @inferred(NaNMath.acosh(T(0.5)))
        @test y isa T
        @test isnan(y)
        y = NaNMath.acosh(T(2.1))
        @test y isa T
        @test !isnan(y)
        @test y === acosh(T(2.1))
    end
end

@testset "BigFloat (#95)" begin
    # Run at two non-default precisions: neither a Float64 detour (53 bits) nor a
    # hard-coded precision can satisfy both.
    @testset "precision = $p" for p in (64, 1024)
        setprecision(BigFloat, p) do
            # NOTE: `big"0.5"` is parsed at macro-expansion time at the *default*
            # precision and ignores `setprecision`, so build the inputs here instead.
            half, two = BigFloat("0.5"), BigFloat("2.0")

            # In-domain: correctly rounded at the active precision, matching Base exactly.
            for (f, g, x) in ((NaNMath.sin, sin, half), (NaNMath.cos, cos, half),
                              (NaNMath.tan, tan, half), (NaNMath.asin, asin, half),
                              (NaNMath.acos, acos, half), (NaNMath.atanh, atanh, half),
                              (NaNMath.log1p, log1p, half), (NaNMath.acosh, acosh, two),
                              (NaNMath.log, log, two), (NaNMath.log2, log2, two),
                              (NaNMath.log10, log10, two), (NaNMath.sqrt, sqrt, two))
                y = @inferred(f(x))
                @test y isa BigFloat
                @test precision(y) == p
                @test y == g(x)
            end

            # Out-of-domain: NaN rather than a DomainError, at the active precision.
            for (f, x) in ((NaNMath.sin, BigFloat(Inf)), (NaNMath.cos, BigFloat(Inf)),
                           (NaNMath.tan, BigFloat(Inf)), (NaNMath.asin, two),
                           (NaNMath.acos, two), (NaNMath.acosh, half),
                           (NaNMath.atanh, two), (NaNMath.log, -two),
                           (NaNMath.log2, -two), (NaNMath.log10, -two),
                           (NaNMath.log1p, -two), (NaNMath.sqrt, -two))
                y = @inferred(f(x))
                @test y isa BigFloat
                @test isnan(y)
                @test precision(y) == p
            end
        end
    end

    # The result takes the global precision at call time, not the argument's, as in Base.
    x = BigFloat("0.5"; precision = 64)
    setprecision(BigFloat, 256) do
        @test precision(NaNMath.sin(x)) == 256
        @test NaNMath.sin(x) == sin(x)
    end

    # `lgamma` has no `Base` counterpart, so it still hits the `::Real` guard.
    @test_throws MethodError NaNMath.lgamma(BigFloat("2.0"))
end

# A `Real` that is not an `AbstractFloat` and that `float` leaves unchanged, e.g.
# `ForwardDiff.Dual`. `convert`, `oftype` and `one` fall back to the `Number` methods.
struct FloatFixedPoint <: Real
    x::Float64
end
Base.float(y::FloatFixedPoint) = y
Base.promote_rule(::Type{FloatFixedPoint}, ::Type{<:Real}) = FloatFixedPoint
Base.:<(a::FloatFixedPoint, b::FloatFixedPoint) = a.x < b.x
Base.abs(y::FloatFixedPoint) = FloatFixedPoint(abs(y.x))
Base.isfinite(y::FloatFixedPoint) = isfinite(y.x)
for f in (:sin, :cos, :tan, :asin, :acos, :acosh, :atanh, :log, :log2, :log10,
          :log1p, :sqrt)
    @eval Base.$f(y::FloatFixedPoint) = FloatFixedPoint((Base.$f)(y.x))
end

@testset "`Real` fixed points of `float`" begin
    # Previously a `MethodError`, and a `StackOverflowError` for `sqrt`.
    for (f, g, x) in ((NaNMath.sin, sin, 0.5), (NaNMath.cos, cos, 0.5),
                      (NaNMath.tan, tan, 0.5), (NaNMath.asin, asin, 0.5),
                      (NaNMath.acos, acos, 0.5), (NaNMath.atanh, atanh, 0.5),
                      (NaNMath.log1p, log1p, 0.5), (NaNMath.acosh, acosh, 2.0),
                      (NaNMath.log, log, 2.0), (NaNMath.log2, log2, 2.0),
                      (NaNMath.log10, log10, 2.0), (NaNMath.sqrt, sqrt, 2.0))
        y = @inferred(f(FloatFixedPoint(x)))
        @test y isa FloatFixedPoint
        @test y.x === g(x)
    end

    for (f, x) in ((NaNMath.sin, Inf), (NaNMath.cos, Inf), (NaNMath.tan, Inf),
                   (NaNMath.asin, 2.0), (NaNMath.acos, 2.0), (NaNMath.acosh, 0.5),
                   (NaNMath.atanh, 2.0), (NaNMath.log, -2.0), (NaNMath.log2, -2.0),
                   (NaNMath.log10, -2.0), (NaNMath.log1p, -2.0), (NaNMath.sqrt, -2.0))
        y = @inferred(f(FloatFixedPoint(x)))
        @test y isa FloatFixedPoint
        @test isnan(y.x)
    end

    @test_throws MethodError NaNMath.lgamma(FloatFixedPoint(2.0))
end
