# include("dubinsmaneuver2d.jl")
include("vertical.jl")

"""
    DubinsManeuver3D struct

This struct contains all necessary information about the maneuver.
  * qi - initial configuration (x, y, z, heading, pitch)
  * qf - final configuration (x, y, z, heading, pitch)
  * rhomin - minimum turning radius
  * pitchlims - limits of the pitch angle [pitch_min, pitch_max] 
    where pitch_min < 0.0   
  * path - array containing horizontal and vertical Dubins paths
  * length - total length of the 3D maneuver 
"""
mutable struct DubinsManeuver3D
    qi::Vector{Float64}
    qf::Vector{Float64}

    rhomin::Float64
    pitchlims::Vector{Float64}

    path::Vector{DubinsManeuver2D}
    length::Float64
end        
        
"""
    DubinsManeuver3D(qi, qf, rhomin, pitchlims)

Create 3D Dubins path between two configurations qi, qf
    * qi - initial configuration (x, y, z, heading, pitch)
    * qf - final configuration (x, y, z, heading, pitch)
    * rhomin - minimum turning radius
    * pitchlims - limits of the pitch angle [pitch_min, pitch_max] 
"""
function DubinsManeuver3D(qi::Vector{Float64}, qf::Vector{Float64}, 
        rhomin::Float64, pitchlims::Vector{Float64})
    maneuver = DubinsManeuver3D(qi, qf, rhomin, pitchlims, [], -1.)

    # Delta Z (height)
    zi = maneuver.qi[3]
    zf = maneuver.qf[3]
    dz = zf - zi
    
    # Multiplication factor of rhomin in [1, 1000]
    a = 1.0
    b = 1.0

    fa = try_to_construct(maneuver, maneuver.rhomin * a)
    fb = try_to_construct(maneuver, maneuver.rhomin * b)

    while length(fb) < 2
        b *= 2.0
        fb = try_to_construct(maneuver, maneuver.rhomin * b)
    end

    if length(fa) > 0
        maneuver.path = fa
    else
        if length(fb) < 2
            error("No maneuver exists")
        end
    end

    # Binary searchs
    # while abs(b-a) > 10e-5:
    #     c = (a+b) / 2.0
    #     #print("Binary search ", [a, b])
    #     fc = self.try_to_construct(self.rhomin * c)

    #     if len(fc) > 0:
    #         b = c
    #         fb = fc
    #     else:
    #         a = c

    # Local optimalization between horizontal and vertical radii
    step = 0.1
    while abs(step) > 1e-10
        c = b + step
        if c < 1.0
            c = 1.0
        end
        fc = try_to_construct(maneuver, maneuver.rhomin * c)
        if length(fc) > 0
            if fc[2].maneuver.length < fb[2].maneuver.length
                b = c
                fb = fc
                step *= 2.
                continue
            end
        end
        step *= -0.1
    end
    
    maneuver.path = fb
    Dlat, Dlon = fb
    maneuver.length = Dlon.maneuver.length
    return maneuver
end

function compute_sampling(self::DubinsManeuver3D; numberOfSamples::Integer = 1000)
    Dlat, Dlon = self.path
    # Sample points on the final path
    points = []
    lena = Dlon.maneuver.length
    rangeLon = lena .* collect(0:numberOfSamples-1) ./ (numberOfSamples-1)

    for ran in rangeLon   
        offsetLon = ran
        qSZ = getCoordinatesAt(Dlon, offsetLon)
        qXY = getCoordinatesAt(Dlat, qSZ[1])
        push!(points, [qXY[1], qXY[2], qSZ[2], qXY[3], qSZ[3]])
    end
    
    points
end

function try_to_construct(self::DubinsManeuver3D, horizontal_radius::Float64)
    qi2D = self.qi[[1,2,4]]
    qf2D = self.qf[[1,2,4]]

    #@show qi2D, qf2D

    Dlat = DubinsManeuver2D(qi2D, qf2D; rhomin = horizontal_radius)    
    
    # After finding a long enough 2D curve, calculate the Dubins path on SZ axis
    qi3D = [0., self.qi[3], self.qi[5]]
    qf3D = [Dlat.maneuver.length, self.qf[3], self.qf[5]]

    vertical_curvature = sqrt(1. /self.rhomin/self.rhomin - 1. /horizontal_radius/horizontal_radius)
    if vertical_curvature < 1e-5
        return []
    end

    vertical_radius = 1. / vertical_curvature
    # Dlon = Vertical1D(qi3D, qf3D, vertical_radius, self.pitchlims)
    Dlon = DubinsManeuver2D(qi3D, qf3D; rhomin = vertical_radius)

    if Dlon.maneuver.case == "RLR" || Dlon.maneuver.case == "RLR"
        return []
    end

    if Dlon.maneuver.case[1] == 'R'
        if self.qi[5] - Dlon.maneuver.t < self.pitchlims[1]
            return []
        end
    else
        if self.qi[5] + Dlon.maneuver.t > self.pitchlims[2]
            return []
        end
    end
    
    # Final 3D path is formed by the two curves (Dlat, Dlon)
    return [Dlat, Dlon]
end

function getLowerBound(qi, qf, rhomin=1, pitchlims=[-pi/4, pi/2])
    maneuver = DubinsManeuver3D(qi, qf, rhomin, pitchlims, [], -1.)

    spiral_radius = rhomin * ( (cos(max(-pitchlims[1], pitchlims[2]))) ^ 2 )

    qi2D = [maneuver.qi[i] for i in [1,2,4]]
    qf2D = [maneuver.qf[i] for i in [1,2,4]]
    Dlat = DubinsManeuver2D(qi2D, qf2D; rhomin = spiral_radius)  

    qi3D = [0, maneuver.qi[3], maneuver.qi[5]]
    qf3D = [Dlat.maneuver.length, maneuver.qf[3], maneuver.qf[5]]

    Dlon = Vertical(qi3D, qf3D, maneuver.rhomin, maneuver.pitchlims)

    if Dlon.maneuver.case == "XXX"
        # TODO - update Vertical1D such that it compute the shortest prolongation
        maneuver.length = 0.0
        return maneuver
    end

    maneuver.path = [Dlat, Dlon]
    maneuver.length = Dlon.maneuver.length
    return maneuver
end

function getUpperBound(qi, qf, rhomin=1, pitchlims=[-pi/4, pi/2])
    maneuver = DubinsManeuver3D(qi, qf, rhomin, pitchlims, [], -1.)

    safeRadius = sqrt(2) * maneuver.rhomin

    p1 = qi[1:2]
    p2 = qf[1:2]
    diff = p2 - p1
    dist = sqrt(diff[1]^2 + diff[2]^2)
    if dist < 4.0 * safeRadius
        maneuver.length = Inf
        return maneuver
    end    

    qi2D = [maneuver.qi[i] for i in [1,2,4]]
    qf2D = [maneuver.qf[i] for i in [1,2,4]]
    Dlat = DubinsManeuver2D(qi2D, qf2D; rhomin = safeRadius)  

    qi3D = [0, maneuver.qi[3], maneuver.qi[5]]
    qf3D = [Dlat.maneuver.length, maneuver.qf[3], maneuver.qf[5]]

    Dlon = Vertical(qi3D, qf3D, safeRadius, maneuver.pitchlims)

    if Dlon.maneuver.case == "XXX"
        # TODO - update Vertical1D such that it compute the shortest prolongation
        maneuver.length = Inf
        return maneuver
    end

    maneuver.path = [Dlat, Dlon]
    maneuver.length = Dlon.maneuver.length
    return maneuver
end