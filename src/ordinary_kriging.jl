## Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

@doc doc"""
  Ordinary Kriging

  *INPUTS*:

    * X  ∈ ℜ^(mxn) - matrix of data locations
    * z  ∈ ℜⁿ      - vector of observations for X
    * cov          - covariance model
  """ ->
type OrdinaryKriging{T<:Real,V} <: AbstractEstimator
  # input fields
  X::AbstractMatrix{T}
  z::AbstractVector{V}
  cov::CovarianceModel

  # state fields
  C::AbstractMatrix{T}

  function OrdinaryKriging(X, z, cov)
    @assert size(X, 2) == length(z) "incorrect data configuration"
    C = pairwise(cov, X)
    new(X, z, cov, C)
  end
end

OrdinaryKriging(X, z, cov) = OrdinaryKriging{eltype(X),eltype(z)}(X, z, cov)

function estimate{T<:Real,V}(estimator::OrdinaryKriging{T,V}, xₒ::AbstractVector{T})
  X = estimator.X; z = estimator.z; cov = estimator.cov
  C = estimator.C
  nobs = length(z)

  # evaluate covariance at location
  c = Float64[cov(norm(X[:,j]-xₒ)) for j=1:nobs]

  # solve linear system
  A = [C ones(nobs); ones(nobs)' 0]
  b = [c; 1]
  λ = A \ b

  # return estimate and variance
  z⋅λ[1:nobs], cov(0) - b⋅λ
end