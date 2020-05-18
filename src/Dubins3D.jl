"""
    Dubins3D

Implementation of 2D/3D Dubins maneuver
"""
module Dubins3D

include("dubinsmaneuver3d.jl")

export DubinsManeuver2D
export DubinsManeuver3D, getLowerBound, getUpperBound, compute_sampling

end