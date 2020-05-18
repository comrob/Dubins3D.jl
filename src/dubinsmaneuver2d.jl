"""
Classical 2D Dubins Curve
"""
struct DubinsStruct
    t::Float64
    p::Float64
    q::Float64
    length::Float64
    case::String
end

"""
Classical 2D Dubins Curve
"""
mutable struct DubinsManeuver2D
    qi::Vector{Float64}
    qf::Vector{Float64}
    rhomin::Float64
    maneuver::DubinsStruct
end

"""
Classical 2D Dubins Curve
"""
function DubinsManeuver2D(qi, qf; rhomin=1., minLength = nothing, disable_CCC = false)
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

    sa, ca = sincos(a)
    sb, cb = sincos(b)

    # CSC
    pathLSL = _LSL(maneuver, a, b, d, sa, ca, sb, cb)
    pathRSR = _RSR(maneuver, a, b, d, sa, ca, sb, cb)
    pathLSR = _LSR(maneuver, a, b, d, sa, ca, sb, cb)
    pathRSL = _RSL(maneuver, a, b, d, sa, ca, sb, cb)

    if disable_CCC
        _paths = [pathLSL, pathRSR, pathLSR, pathRSL]
    else
        # CCC
        pathRLR = _RLR(maneuver, a, b, d, sa, ca, sb, cb)
        pathLRL = _LRL(maneuver, a, b, d, sa, ca, sb, cb)
        _paths = [pathLSL, pathRSR, pathLSR, pathRSL, pathRLR, pathLRL]
    end

    if (abs(d) < maneuver.rhomin * 1e-5 && abs(a) < maneuver.rhomin * 1e-5 && abs(b) < maneuver.rhomin * 1e-5)      
        dist_2D = maximum(abs.(maneuver.qi[1:2] - maneuver.qf[1:2]))
        if dist_2D < maneuver.rhomin * 1e-5
            pathC = _C(maneuver)
            _paths = [pathC]
        end
    end
    
    a(x) = x.length
    sort!(_paths, by=a)    
        
    if (minLength === nothing)
        maneuver.maneuver = _paths[1]
    else    
        for p in _paths
            if p.length >= minLength
                maneuver.maneuver = p
                break
            end
        end
        
        if (maneuver.maneuver === nothing)        
            inf = Inf
            maneuver.maneuver = DubinsManeuver2D(inf, inf, inf, inf, "XXX")
        end
    end

    return maneuver
end

########## LSL ##########
@inline function _LSL(self, a, b, d, sa, ca, sb, cb) 
    aux = atan(cb - ca, d + sa - sb)
    t = mod2pi(-a + aux)
    p = sqrt(2 + d^2 - 2*cos(a-b) + 2*d*(sa-sb))
    q = mod2pi(b - aux)
    length = (t+p+q) * self.rhomin        
    case = "LSL"
    return DubinsStruct(t, p, q, length, case)
end

########## RSR ##########
@inline function _RSR(self, a, b, d, sa, ca, sb, cb) 
    aux = atan(ca-cb, d-sa+sb)         
    t = mod2pi(a - aux)
    p = sqrt(2 + d^2 - 2*cos(a-b) + 2*d*(sb-sa))
    q = mod2pi(mod2pi(-b) + aux)   
    length = (t+p+q) * self.rhomin        
    case = "RSR"
    return DubinsStruct(t, p, q, length, case)
end

########## LSR ##########
@inline function _LSR(self, a, b, d, sa, ca, sb, cb)
    aux1 = -2 + d^2 + 2*cos(a-b) + 2*d*(sa+sb)       
    if (aux1 > 0)      
        p = sqrt(aux1)
        aux2 = atan(-ca-cb, d+sa+sb) - atan(-2/p)
        t = mod2pi(-a + aux2)
        q = mod2pi(-mod2pi(b) + aux2)
    else        
        t = p = q = Inf
    end
    length = (t+p+q) * self.rhomin
    case = "LSR"
    return DubinsStruct(t, p, q, length, case)
end
    
########## RSL ##########
@inline function _RSL(self, a, b, d, sa, ca, sb, cb)
    aux1 = d^2 - 2 + 2*cos(a-b) - 2*d*(sa+sb)
    if (aux1 > 0)    
        p = sqrt(aux1)
        aux2 = atan(ca+cb, d-sa-sb) - atan(2/p)
        t = mod2pi(a - aux2)
        q = mod2pi(mod2pi(b) - aux2) 
    else       
        t = p = q = Inf
    end            
    length = (t+p+q) * self.rhomin
    case = "RSL";
    return DubinsStruct(t, p, q, length, case)
end

########## RLR ##########
@inline function _RLR(self, a, b, d, sa, ca, sb, cb)
    aux = (6 - d^2 + 2*cos(a-b) + 2*d*(sa-sb))/8;
    if (abs(aux) <= 1)       
        p = mod2pi(-acos(aux));   
        t = mod2pi(a - atan(ca-cb, d-sa+sb) + p/2)
        q = mod2pi(a - b - t + p)
    else       
        t = p = q = Inf
    end 
    length = (t+p+q) * self.rhomin  
    case = "RLR"
    return DubinsStruct(t, p, q, length, case)
end
    

########## LRL ##########
@inline function _LRL(self, a, b, d, sa, ca, sb, cb)
    aux = (6 - d^2 + 2*cos(a-b) + 2*d*(-sa+sb))/8;
    if (abs(aux) <= 1)       
        p = mod2pi(-acos(aux))
        t = mod2pi(-a + atan(-ca+cb, d+sa-sb) + p/2)
        q = mod2pi(b - a - t + p)
    else      
        t = p = q = Inf
    end 
    length = (t+p+q) * self.rhomin      
    case = "LRL"
    return DubinsStruct(t, p, q, length, case)
end    
    
########## C ##########
@inline function _C(self)
    t = 0.
    p = 2*pi
    q = 0.
    length = (t+p+q) * self.rhomin
    case = "RRR"
    return DubinsStruct(t, p, q, length, case)
end

function getCoordinatesAt(self, offset)
    # Offset normalizado
    noffset = offset/self.rhomin       

    # Translação para a origem
    qi = [0., 0., self.qi[3]]        

    # Gerando as configurações intermediárias            
    l1 = self.maneuver.t
    l2 = self.maneuver.p
    q1 = getPositionInSegment(self, l1, qi, self.maneuver.case[1]) # Final do segmento 1
    q2 = getPositionInSegment(self, l2, q1, self.maneuver.case[2]) # Final do segmento 2

    # Obtendo o restante das configurações
    if (noffset < l1)
        q = getPositionInSegment(self, noffset, qi, self.maneuver.case[1])
    elseif (noffset < (l1+l2))
        q = getPositionInSegment(self, noffset-l1, q1, self.maneuver.case[2])
    else
        q = getPositionInSegment(self, noffset-l1-l2, q2, self.maneuver.case[3])        
    end
    # Translação para a posição anterior
    q[1] = q[1] * self.rhomin + self.qi[1]
    q[2] = q[2] * self.rhomin + self.qi[2]
    q[3] = mod2pi(q[3])         
    
    return q
end
        
function getPositionInSegment(self, offset, qi, case)
    q = [0., 0., 0.]
    if (case == 'L')
        q[1] = qi[1] + sin(qi[3]+offset) - sin(qi[3])
        q[2] = qi[2] - cos(qi[3]+offset) + cos(qi[3])
        q[3] = qi[3] + offset
    elseif (case == 'R')
        q[1] = qi[1] - sin(qi[3]-offset) + sin(qi[3])
        q[2] = qi[2] + cos(qi[3]-offset) - cos(qi[3])
        q[3] = qi[3] - offset
    elseif (case == 'S')
        q[1] = qi[1] + cos(qi[3]) * offset
        q[2] = qi[2] + sin(qi[3]) * offset
        q[3] = qi[3]
    end
    return q  
end          

function getSamplingPoints(self, res=0.1)
    points = []    
    range = 0.0:res:self.maneuver.length
    for offset in range
        push!(points, getCoordinatesAt(self, offset))
    end
    return points
end

