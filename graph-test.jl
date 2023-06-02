using Plots
using Polynomials
using Distributions
using LinearAlgebra

# 1d6
# 8 hp
# What is shortest and longest set of dice rolls that can kill an 8 hp monster

# [ 6, 2]

function RollDice(number, sides, rolls)
    v = zeros(Int, sides * number)
    a = 0
    for _ = 1:rolls
        a = 0
        for _ = 1:number
            a += rand(1:sides)
        end
        v[a] += 1
    end
    return v
end

x = RollDice(3, 6, 1000)

bar(x,
    title = "3d6 1000 rolls",
    xlabel = "Outcome",
    ylabel = "Occurences")
plot!(x)




#     pfit = polyfit(x, 2)
    
# μ = 0  # Mean
# σ = 1.5  # Standard deviation
# normal_distribution = Normal(μ, σ)

# # Generate the x-axis values for the plot
# x_values = range(-5σ, 5σ, length=1000)

# # Evaluate the PDF at each x-axis value
# pdf_values = pdf.(normal_distribution, x_values)

# # Create a plot of the normal distribution
# plot(x_values, pdf_values,
#     title="Normal Distribution (μ=$(μ), σ=$(σ))",
#     xlabel="x",
#     ylabel="PDF(x)",
#     legend=false,
#     linewidth=2
# )