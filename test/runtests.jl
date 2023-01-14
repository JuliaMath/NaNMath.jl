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
@test isnan(NaNMath.sqrt(-3.2f0)) && NaNMath.sqrt(-3.2f0) isa Float32
@test isnan(NaNMath.sqrt(-BigFloat(7.0))) && NaNMath.sqrt(-BigFloat(7.0)) isa BigFloat 
@test isnan(NaNMath.sqrt(-7)) && NaNMath.sqrt(-7) isa Float64 
@inferred NaNMath.sqrt(5)
@inferred NaNMath.sqrt(5.0)
@inferred NaNMath.sqrt(5.0f0)
@inferred NaNMath.sqrt(-5)
@inferred NaNMath.sqrt(-5.0)
@inferred NaNMath.sqrt(-5.0f0)
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
