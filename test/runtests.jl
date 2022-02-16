using NaNMath
using Test

@test isnan(NaNMath.log(-10))
@test isnan(NaNMath.log1p(-100))
@test isnan(NaNMath.pow(-1.5,2.3))
@test isnan(NaNMath.pow(-1.5f0,2.3f0))
@test isnan(NaNMath.pow(-1.5,2.3f0))
@test isnan(NaNMath.pow(-1.5f0,2.3))
@test NaNMath.pow(-1,2) isa Float64
@test NaNMath.pow(-1.5f0,2) isa Float32
@test NaNMath.pow(-1.5f0,2//1) isa Float32
@test NaNMath.pow(-1.5f0,2.3f0) isa Float32
@test NaNMath.pow(-1.5f0,2.3) isa Float64
@test NaNMath.pow(-1.5,2) isa Float64
@test NaNMath.pow(-1.5,2//1) isa Float64
@test NaNMath.pow(-1.5,2.3f0) isa Float64
@test NaNMath.pow(-1.5,2.3) isa Float64
@test isnan(NaNMath.sqrt(-5))
@test NaNMath.sqrt(5) == Base.sqrt(5)
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

@testset "findmin/findmax" begin
    xvals = [
        [1., 2., 3., 3., 1.],
        [missing, missing],
        [missing, 1.0],
        [1.0, missing],
        (1., 2, 3., 3, 1),
        (x=1, y=3, z=-4, w=-2),
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

    x = [3, missing, NaN, -1]
    @test NaNMath.findmin(x) === (missing, 2)
    @test NaNMath.findmax(x) === (missing, 2)
    @test NaNMath.findmin(identity, x) === (missing, 2)
    @test NaNMath.findmax(identity, x) === (missing, 2)
    @test NaNMath.findmin(sin, x) === (missing, 2)
    @test NaNMath.findmax(sin, x) === (missing, 2)

    x = Dict(:x => 3, :w => 2, :y => -1.0, :z => NaN)
    @test NaNMath.findmin(x) === (-1.0, :y)
    @test NaNMath.findmax(x) === (3, :x)
    @test NaNMath.findmin(identity, x) === (-1.0, :y)
    @test NaNMath.findmax(identity, x) === (3, :x)
    @test NaNMath.findmin(-, x) === (-3, :x)
    @test NaNMath.findmax(-, x) === (1.0, :y)

    x = Dict(:x => :a, :w => :b, :y => :c, :z => :d)
    y = Dict(:a => 3, :b => 2, :c => -1.0, :d => NaN)
    f = k -> y[k]
    @test NaNMath.findmin(f, x) === (-1.0, :y)
    @test NaNMath.findmax(f, x) === (3, :x)
end

@testset "argmin/argmax" begin
    xvals = [
        [1., 2., 3., 3., 1.],
        [missing, missing],
        [missing, 1.0],
        [1.0, missing],
        (1., 2, 3., 3, 1),
        (x=1, y=3, z=-4, w=-2),
        Dict(:a => 1.0, :b => 1.0, :d => 3.0, :c => 2.0),
    ]
    @testset for x in xvals
        @test NaNMath.argmin(x) === argmin(x)
        @test NaNMath.argmax(x) === argmax(x)
        @test NaNMath.argmin(identity, x) === argmin(identity, x)
        @test NaNMath.argmax(identity, x) === argmax(identity, x)
        x isa Dict || @test NaNMath.argmin(sin, x) === argmin(sin, x)
        x isa Dict || @test NaNMath.argmax(sin, x) === argmax(sin, x)
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
    @test NaNMath.argmin(x) === 2
    @test NaNMath.argmax(x) === 2
    @test NaNMath.argmin(identity, x) === missing
    @test NaNMath.argmax(identity, x) === missing
    @test NaNMath.argmin(-, x) === missing
    @test NaNMath.argmax(-, x) === missing

    x = Dict(:x => 3, :w => 2, :z => -1.0, :y => NaN)
    @test NaNMath.argmin(x) === :z
    @test NaNMath.argmax(x) === :x
    @test NaNMath.argmin(identity, x) === argmin(identity, x)
    @test NaNMath.argmax(identity, x) === argmax(identity, x)

    x = (:a, :b, :c, :d)
    y = Dict(:a => 3, :b => 2, :c => -1.0, :d => NaN)
    f = k -> y[k]
    @test NaNMath.argmin(f, x) === :c
    @test NaNMath.argmax(f, x) === :a
end
