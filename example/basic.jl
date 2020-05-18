module BasicTest

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

end