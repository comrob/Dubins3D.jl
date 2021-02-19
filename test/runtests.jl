using Test
using Printf
using Dubins3D

include("instances3D.jl")

function print_results(data, name)
    @testset "Instances: $(name)" begin
        for (i, (qi, qf)) in enumerate(data)
            dubins = DubinsManeuver3D(qi, qf, rhomin, pitchlims)
  
            t = @timed DubinsManeuver3D(qi, qf, rhomin, pitchlims)
  
            lb = getLowerBound(qi, qf, rhomin, pitchlims)
            ub = getUpperBound(qi, qf, rhomin, pitchlims)
            best_lb = lb.length

            @test lb.length <= dubins.length + 1e-5
            @test dubins.length <= ub.length + 1e-5
  
            print(join([
        "$(@sprintf("%6s %d", name, i))",
        "$(@sprintf(" L:%9.2f", dubins.length))",
        #"$(@sprintf(" T: %5.3f", (t[2]) * 1000))",
        "$(@sprintf(" LB: %8.2f", lb.length))",
        "$(@sprintf(" UB: %8.2f", ub.length))",
        "$(@sprintf(" GAP[%%]: %6.2f", 100.0 * (dubins.length - best_lb) / dubins.length))",
        "\n",
      ]," "))
        end
    end
end

print_results(LONG, "Long")
print_results(SHORT, "Short")
print_results(BEARD, "Beard")
print_results(OTHERS, "Others")
print_results(HOTA, "Hota")