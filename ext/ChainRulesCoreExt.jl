module ChainRulesCoreExt

using NaNMath: NaNMath
using ChainRulesCore: @scalar_rule

# For these types `NaNMath.sqrt` calls the intrinsic `sqrt_llvm`, which AD can't differentiate through
@scalar_rule NaNMath.sqrt(x::Union{Float16, Float32, Float64}) inv(2Ω)

end
