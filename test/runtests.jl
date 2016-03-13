using NaNMath
using Base.Test

@test isnan(NaNMath.log(-10))
@test isnan(NaNMath.log1p(-100))
@test isnan(NaNMath.pow(-1.5,2.3))
@test isnan(NaNMath.sqrt(-5))
@test NaNMath.sqrt(5) == Base.sqrt(5)
@test NaNMath.sum([1., 2., NaN]) == 3.0
@test isnan(NaNMath.sum([NaN, NaN]))
@test NaNMath.sum(Float64[]) == 0.0
@test NaNMath.sum([1f0, 2f0, NaN32]) === 3.0f0
@test NaNMath.maximum([1., 2., NaN]) == 2.0
@test NaNMath.minimum([1., 2., NaN]) == 1.0
@test NaNMath.mean([1., 2., NaN]) == 1.5
@test NaNMath.var([1., 2., NaN]) == 0.5
@test NaNMath.std([1., 2., NaN]) == 0.7071067811865476
