
include("dubinsmaneuver2d.jl")

function Vertical(qi, qf, rhomin, pitchmax)
    maneuver = DubinsManeuver2D(qi, qf, rhomin, DubinsStruct(0.0, 0.0, 0.0, Inf, ""))

    dx = maneuver.qf[1] - maneuver.qi[1]
    dy = maneuver.qf[2] - maneuver.qi[2]
    D = sqrt(dx^2 + dy^2)

    # Distance normalization
    d = D/maneuver.rhomin       

    # Normalize the problem using rotation
    rotationAngle = mod2pi(atan(dy, dx))
    a = mod2pi(maneuver.qi[3] - rotationAngle)
    b = mod2pi(maneuver.qf[3] - rotationAngle)
    
    # CSC
    pathLSL = _LSL(maneuver)
    pathRSR = _RSR(maneuver)
    pathLSR = _LSR(maneuver, pitchmax)
    pathRSL = _RSL(maneuver, pitchmax)
    _paths = [pathLSR ,pathLSL, pathRSR, pathRSL]
    
    a(x) = x.length
    sort!(_paths, by=a)   
        
    for p in _paths
        # chech if the turns are too long (do not meet pitch constraint)
        if abs(p.t) < pi && abs(p.q) < pi
            # check the inclination based on pitch constraint
            center_angle = maneuver.qi[3] + ((p.case[1] == 'L') ? p.t : - p.t)
            if ((center_angle < pitchmax[1]) || (center_angle > pitchmax[2]))
                continue
            end
            maneuver.maneuver = p
            break
        end
    end
    
    if maneuver.maneuver === nothing           
        maneuver.maneuver = DubinsStruct(Inf, Inf, Inf, Inf, "XXX")
    end

    return maneuver
end

########## LSL ##########
function _LSL(self)
    theta1 = self.qi[3]
    theta2 = self.qf[3]

    if theta1 <= theta2
        # start/end points
        p1 = self.qi[1:2]
        p2 = self.qf[1:2]

        radius = self.rhomin

        c1, s1 = radius * cos(theta1), radius * sin(theta1)
        c2, s2 = radius * cos(theta2), radius * sin(theta2)

        # origins of the turns
        o1 = p1 + [ -s1, c1]
        o2 = p2 + [ -s2, c2]

        diff = o2 - o1
        center_distance = sqrt(diff[1]^2 + diff[2]^2)
        centerAngle = atan(diff[2], diff[1])
                
        t = mod2pi(-theta1 + centerAngle)
        p = center_distance / radius
        q = mod2pi(theta2 - centerAngle)

        if t > pi
            t = 0.0
            q = theta2 - theta1
            turn_end_y = o2[2] - radius * cos(theta1)
            diff_y = turn_end_y - p1[2] 
            if abs(theta1) > 1e-5 && (diff_y < 0 == theta1 < 0)
                p = diff_y / sin(theta1) / radius
            else
                t = p = q = Inf
            end
        end
        if q > pi
            t = theta2 - theta1
            q = 0.0
            turn_end_y = o1[2] - radius * cos(theta2)
            diff_y = p2[2] - turn_end_y 
            if abs(theta2) > 1e-5 && (diff_y < 0 == theta2 < 0)
                p = diff_y / sin(theta2) / radius
            else
                t = p = q = Inf
            end
        end
    else
        t = p = q = Inf
    end
    
    length = (t+p+q) * self.rhomin        
    case = "LSL"
    
    return DubinsStruct(t, p, q, length, case)
end

########## RSR ##########
function _RSR(self)
    theta1 = self.qi[3]
    theta2 = self.qf[3]

    if theta2 <= theta1
        # start/end points
        p1 = self.qi[1:2]
        p2 = self.qf[1:2]

        radius = self.rhomin

        c1, s1 = radius * cos(theta1), radius * sin(theta1)
        c2, s2 = radius * cos(theta2), radius * sin(theta2)

        # origins of the turns
        o1 = p1 + [ s1, -c1]
        o2 = p2 + [ s2, -c2]

        diff = o2 - o1
        center_distance = sqrt(diff[1]^2 + diff[2]^2)
        centerAngle = atan(diff[2], diff[1])
                
        t = mod2pi(theta1 - centerAngle)
        p = center_distance / radius
        q = mod2pi(-theta2 + centerAngle)

        if t > pi
            t = 0.0
            q = -theta2 + theta1
            turn_end_y = o2[2] + radius * cos(theta1)
            diff_y = turn_end_y - p1[2] 
            if abs(theta1) > 1e-5 && (diff_y < 0 == theta1 < 0)
                p = diff_y / sin(theta1) / radius
            else
                t = p = q = Inf
            end
        end
        if q > pi
            t = -theta2 + theta1
            q = 0.0
            turn_end_y = o1[2] + radius * cos(theta2)
            diff_y = p2[2] - turn_end_y 
            if abs(theta2) > 1e-5 && (diff_y < 0 == theta2 < 0)
                p = diff_y / sin(theta2) / radius
            else
                t = p = q = Inf
            end
        end
    else
        t = p = q = Inf
    end
    
    length = (t+p+q) * self.rhomin        
    case = "RSR"
    
    return DubinsStruct(t, p, q, length, case)
end

########## LSR ##########
function _LSR(self, pitchmax)
    theta1 = self.qi[3]
    theta2 = self.qf[3]

    # start/end points
    p1 = self.qi[1:2]
    p2 = self.qf[1:2]

    radius = self.rhomin

    c1, s1 = radius * cos(theta1), radius * sin(theta1)
    c2, s2 = radius * cos(theta2), radius * sin(theta2)

    # origins of the turns
    o1 = p1 + [-s1,  c1]
    o2 = p2 + [ s2, -c2]

    diff = o2 - o1
    center_distance = sqrt(diff[1]^2 + diff[2]^2)

    # not constructible
    if center_distance < 2 * radius
        diff[1] = sqrt(4.0 * radius * radius - diff[2] * diff[2])
        alpha = pi/2.0
    else
        alpha = asin(2.0 * radius / center_distance)
    end
        
    centerAngle = atan(diff[2], diff[1]) + alpha

    if centerAngle < pitchmax[2]
        t = mod2pi(-theta1 + centerAngle)
        p = sqrt(max(0.0, center_distance * center_distance - 4.0 * radius * radius)) / radius
        q = mod2pi(-theta2 + centerAngle)
    else
        centerAngle = pitchmax[2]
        t = mod2pi(-theta1 + centerAngle)
        q = mod2pi(-theta2 + centerAngle)

        # points on boundary between C and S segments
        c1, s1 = radius * cos(centerAngle), radius * sin(centerAngle)
        c2, s2 = radius * cos(centerAngle), radius * sin(centerAngle)
        w1 = o1 - [-s1,  c1]
        w2 = o2 - [ s2, -c2]

        p = (w2[2] - w1[2]) / sin(centerAngle) / radius
    end

    length = (t+p+q) * self.rhomin
    case = "LSR"
    
    return DubinsStruct(t, p, q, length, case)
end
    
    
########## RSL ##########
function _RSL(self, pitchmax)
    theta1 = self.qi[3]
    theta2 = self.qf[3]

    # start/end points
    p1 = self.qi[1:2]
    p2 = self.qf[1:2]

    radius = self.rhomin

    c1, s1 = radius * cos(theta1), radius * sin(theta1)
    c2, s2 = radius * cos(theta2), radius * sin(theta2)

    # origins of the turns
    o1 = p1 + [ s1, -c1]
    o2 = p2 + [-s2,  c2]

    diff = o2 - o1
    center_distance = sqrt(diff[1]^2 + diff[2]^2)

    # not constructible
    if center_distance < 2 * radius
        diff[1] = sqrt(4.0 * radius * radius - diff[2] * diff[2])
        alpha = pi/2.0
    else
        alpha = asin(2.0 * radius / center_distance)
    end
        
    centerAngle = atan(diff[2], diff[1]) - alpha

    if centerAngle > pitchmax[1]
        t = mod2pi(theta1 - centerAngle)
        p = sqrt(max(0.0, center_distance * center_distance - 4.0 * radius * radius)) / radius
        q = mod2pi(theta2 - centerAngle)
    else
        centerAngle = pitchmax[1]
        t = mod2pi(theta1 - centerAngle)
        q = mod2pi(theta2 - centerAngle)

        # points on boundary between C and S segments
        c1, s1 = radius * cos(centerAngle), radius * sin(centerAngle)
        c2, s2 = radius * cos(centerAngle), radius * sin(centerAngle)
        w1 = o1 - [ s1, -c1]
        w2 = o2 - [-s2,  c2]

        p = (w2[2] - w1[2]) / sin(centerAngle) / radius
    end

    length = (t+p+q) * self.rhomin
    case = "RSL"
    
    return DubinsStruct(t, p, q, length, case)
end

