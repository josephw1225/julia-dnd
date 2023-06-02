using Plots
using Tables
using Polynomials
using Distributions
using LinearAlgebra
using DataFrames

soul1 = Soul(10, 0, 6, 13)
soul2 = Soul(10, 0, 4, 13)
turnOrder = true

maxTurns = maximum([soul1.health, soul2.health])
maxTurns = maxTurns * maxTurns

soul1Won = zeros(Int64, maxTurns)
soul2Won = zeros(Int64, maxTurns)
for _ in 1:trials
    if turnOrder
        turnToEnd = Encounter(soul1, soul2)
        if turnToEnd > 0
            soul1Won[turnToEnd] += 1
        else
            soul2Won[turnToEnd*-1] += 1
        end
    else
        turnToEnd = Encounter(soul2, soul1)
        if turnToEnd > 0
            soul2Won[turnToEnd] += 1
        else
            soul1Won[turnToEnd*-1] += 1
        end
    end
end

fightEndProb = zeros(Float64, maxTurns)
soul1NormalPrp = zeros(Float64, maxTurns)
soul2NormalPrp = zeros(Float64, maxTurns)
for i in eachindex(playerWon)
    if soul1Won[i] > 0 || soul2Won[i] > 0
        fightEndProb[i] = (soul1Won[i] + soul2Won[i]) / trials

        soul1NormalPrp[i] = soul1Won[i] / trials
        soul2NormalPrp[i] = fightEndProb[i] - soul1NormalPrp[i]
    else
        fightEndProb[i] = 0
    end
end

idx = findmax(fightEndProb)
probCap = fightEndProb[idx[2]] / 50.0
idx = findnext(x -> x < probCap, fightEndProb, idx[2])
fightEndProbDraw = view(fightEndProb, 1:idx)
soul1NormalPrpDraw = view(soul1NormalPrp, 1:idx)
soul2NormalPrpDraw = view(soul2NormalPrp, 1:idx)
 
df = DataFrame("F End"=>fightEndProbDraw, "Soul1"=>soul1NormalPrpDraw, "Soul2"=>soul2NormalPrpDraw)

if turnOrder
    title = "Blue first turn | $trials trials"
else
    title = "Red first turn | $trials trials"
end

# l = @layout [
#     a{0.3w} [grid(3,3)
#              b{0.2h}  ]
# ]
# plot(
#     [fightEndProbDraw soul1NormalPrpDraw],
#     layout = 2,
#     legend = false, seriestype = [:bar :bar],
#     title = ["Blue first turn | $trials trials" "" ""],
# )

bar(fightEndProbDraw, 
    hover=fightEndProbDraw,
    title=title,
    xaxis=1:maxTurns,
    xlabel="Turns",
    ylabel="Occurences",
    color=:red,
    normalize=:pdf,
    label="$(soul2.health)HP $(soul2.armorClass)AC d$(soul2.damage) dmg")
bar!(soul1NormalPrpDraw,
    color=:blue,
    label="$(soul1.health)HP $(soul1.armorClass)AC d$(soul1.damage) dmg")