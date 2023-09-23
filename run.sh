#!/usr/bin/env bash
{
  julia --project=. -i -e '
using Revise, Pkg
Pkg.resolve()
Revise.includet("EigenValues.jl")
main(args...; kw...) = EigenValues.main(args...; kw...)
main()
'
  exit
}