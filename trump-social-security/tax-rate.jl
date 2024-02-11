using Plots, PlotThemes
#%% Set the theme to mute
theme(:mute)
#%% Design a function that takes income as an input and returns the tax rate for Social Security and Medicare
function tax_rate(income::Float64)
    @assert(income >= 0.0, "Income must be non-negative")
    liability = 0.0
    if income < 168600.0
        liability += 0.124 * income
    else
        liability += 0.124 * 168600.0
    end
    if income < 200000
        liability += 0.029 * income
    else
        liability += 0.029 * 200000 + 0.038 * (income - 200000)
    end
    return liability / income
end
#%% Create a plot showing your payroll tax rate on income from $0 to $500,000
yrange = 1.0:1.0:500.0
plot(
    yrange,
    100.0 .* tax_rate.((1000.0 .* yrange));
    xlabel="Income (\$ Thousand)",
    ylabel="Tax Rate (%)",
    label="Tax Rate",
    lw=2,
    legend=:topright,
    title="Payroll Tax Rate",
)
vline!([168.6], label="Social Security Cap")
vline!([200.0], label="Medicare Surtax")
#%% Save Figure
savefig("trump-social-security/payroll-tax-rate.png")
#%% 
plot(yrange, tax_rate.(1000.0 .*yrange), xlabel = "Income (\$ Thousand)", ylabel = "Tax Rate (%)", label = "Tax Rate", legend = :right)
vline!([168.6], label="Social Security Cap")
vline!([200.0], label="Medicare Surtax")
plot!(twinx(),yrange, yrange .* tax_rate.(1000.0 .*yrange), color = :green, label = "Tax Liability (\$ Thousands)", legend = :topright)
#%% Save the figure
savefig("trump-social-security/payroll-tax-rate-2.png")
