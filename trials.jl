struct Soul
    health::Int
    hit::Int
    damage::Int
    armorClass::Int
end

function Encounter(soul1::Soul, soul2::Soul)

    s1hp = soul1.health
    s2hp = soul2.health

    turnIndex = 0
    while s1hp > 0 && s2hp > 0 # While anyone has any HP
        # Soul 1 always goes first
        if rand(1:20) + soul1.hit > soul2.armorClass
            s2hp -= rand(1:soul1.damage)
        end
        if s2hp > 0 # Soul 2 can only attack if it's still alive :)
            if rand(1:20) + soul2.hit > soul1.armorClass
                s1hp -= rand(1:soul2.damage)
            end
        end
        turnIndex += 1
    end

    if s1hp < 1
        turnIndex *= -1 # negative = Soul 1 lost
    end

    return turnIndex
end

##################################################################
# Visualization A
##################################################################
function CalculateEncounter(soul1::Soul, soul2::Soul, turnOrder::Bool = true, trials::Int = 100000)
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
        
end

player = Soul(10, 0, 6, 13)
goblin = Soul(10, 0, 4, 13)

CalculateEncounter(player, goblin)
CalculateEncounter(player, goblin, false)