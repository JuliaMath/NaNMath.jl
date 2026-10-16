module ChainRulesCoreExt

using NaNMath: NaNMath
using ChainRulesCore: ChainRulesCore, NoTangent, unthunk

# For these types `NaNMath.sqrt` calls the intrinsic `sqrt_llvm`, which AD can't differentiate through
const IEEEFloat = Union{Float16, Float32, Float64}

# Zero (co)tangents are strong zeros: otherwise they would turn into `NaN` when multiplied with
# the derivative `Inf` at `x = 0` or `NaN` at `x < 0`, e.g. in `ifelse(x > 0, NaNMath.sqrt(x), 0)`.
# `abs` gives the derivative `Inf` instead of `-Inf` at `x = -0.0`, where `Ω = -0.0`.
function _sqrt_tangent(Δ, Ω)
    ∂ = Δ / 2abs(Ω)
    return iszero(Δ) ? zero(∂) : ∂
end

function ChainRulesCore.frule((_, Δx), ::typeof(NaNMath.sqrt), x::IEEEFloat)
    Ω = NaNMath.sqrt(x)
    return Ω, _sqrt_tangent(Δx, Ω)
end

function ChainRulesCore.rrule(::typeof(NaNMath.sqrt), x::IEEEFloat)
    Ω = NaNMath.sqrt(x)
    sqrt_pullback(ΔΩ) = (NoTangent(), _sqrt_tangent(unthunk(ΔΩ), Ω))
    return Ω, sqrt_pullback
end

end
