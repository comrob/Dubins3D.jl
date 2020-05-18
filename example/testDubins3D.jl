module BasicTest

using Printf

include("../src/Dubins3D.jl")
using .Dubins3D

include("instances3D.jl")

function print_results(data, name)
  println("NAME ", name , " -------------  ")
  for i in 1:length(data)
    d = data[i]
    qi = d[1]
    qf = d[2]
    dubins = DubinsManeuver3D(qi, qf, rhomin, pitchmax)

    t = @timed DubinsManeuver3D(qi, qf, rhomin, pitchmax)

    lb = getLowerBound(qi, qf, rhomin, pitchmax)
    ub = getUpperBound(qi, qf, rhomin, pitchmax)
    best_lb = lb.length

    print(join([
      "$(@sprintf("%6s %d", name, i))",
      "$(@sprintf(" L[m]:%9.3f", dubins.length))",
      "$(@sprintf(" T[ms]: %5.3f", (t[2]) * 1000))",
      "$(@sprintf(" LB[m]: %8.3f", lb.length))",
      "$(@sprintf(" GAP[%%]: %6.3f", 100.0*(dubins.length - best_lb)/dubins.length))",
      "\n",
    ]," "))
  end
end

print_results(LONG, "Long")
print_results(SHORT, "Short")
print_results(BEARD, "Beard")
print_results(OTHERS, "Others")
print_results(HOTA, "Hota")

COUNT = 100

print("END -------------  \n\n")

function bold(best, text)
  if best
    return "\\textbf{" * text * "}"
  else
    return "        " * text * " "
  end
end

function text_value(value)
  if value > 100000000.0
    return "    --- "
  else
    return "$(@sprintf("%8.2f", value))"
  end
end

function text_value_gap(value)
  if isnan(value)
    return "    --- "
  else
    return "$(@sprintf("%8.3f", value))"
  end
end

end