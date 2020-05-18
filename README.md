# 3D Dubins Paths

This pakage provides 3D Dubins paths between two prescribed configuration. It provides smooth trajectories for fixed-wing aircraft while both curvature and pitch angle constraints are met.

Full description is provided in the following paper.
```
@INPROCEEDINGS{VANA-ICRA-20, 
    AUTHOR       = {Váňa, Petr and Neto, Armando Alves and Faigl, Jan and Macharet, Douglas G}, 
    TITLE        = {Minimal 3D Dubins Path with Bounded Curvature and Pitch Angle}, 
    BOOKTITLE    = {2020 IEEE International Conference on Robotics and Automation (ICRA)}, 
    YEAR         = {2020}, 
    ORGANIZATION = {IEEE}
} 
```

## 3D Dubins path example

<img src="https://raw.githubusercontent.com/petvana/images/master/dubins3d/example-3d.png" width="500">
(Green represents the provided path, red is based on the minimum turing radius.)


### Installation

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/comrob/Dubins3D.jl"))
```
## Basic usage

See example/basic.jl

```julia
using Dubins3D

# Convert degreees to radians
deg2rad(x) = pi * x / 180.

# Initial and final configurations [x, y, z, heading angle, pitch angle]
qi = [200., 500., 200., deg2rad(180.), deg2rad(-5.)]
qf = [500., 350., 100., deg2rad(0.), deg2rad(-5.)]
# Minimum turning radius
rhomin = 40.
# Pich angle constraints [min_pitch, max_pitch]
pitchmax = deg2rad.([-15., 20.])

maneuver = DubinsManeuver3D(qi, qf, rhomin, pitchmax)

# Length of the 3D Dubins path
@show maneuver.length

# Sample the manever by 500 samples
samples = compute_sampling(maneuver; numberOfSamples = 500)
# First and last samples - should be equal to qi and qf
@show samples[1]
@show samples[end]
```
