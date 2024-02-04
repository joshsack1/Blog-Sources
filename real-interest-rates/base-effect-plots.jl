using Plots
using ShiftedArrays: lead
using StatsPlots, Dates
#%% Set up PlotThemes
using PlotThemes
theme(:mute)
#%% Include previously define functions
include("analysis.jl")
include("data.jl")
#%% Read in data from each different type of inflation
# Replicate plots in first post
sources = ["CPIAUCSL", "CPILFESL", "PCEPI", "PCEPILFE"]
raw_data = pull_index.(sources)
add_lags!.(raw_data)
apc_dfs = apc_df.(raw_data)
#%% Create november 2023
nov23 = plot(
    1:24,
    collect(values(apc_dfs[1][end - 1, 1:24]));
    label="CPI",
    title="November 2023",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
    legend=:bottomright,
)
plot!(1:24, collect(values(apc_dfs[2][end - 1, 1:24])); label="Core CPI")
plot!(1:24, collect(values(apc_dfs[3][end - 1, 1:24])); label="PCE")
plot!(1:24, collect(values(apc_dfs[4][end - 1, 1:24])); label="Core PCE")
hline!([2]; lable="Fed Target", color=:black, linestyle=:dash, linewidth=2)
#%% Save the figure
savefig(nov23, "nov23.png")
#%% Create a plot for december 2023
#
nov23 = plot(
    1:24,
    collect(values(apc_dfs[1][end, 1:24]));
    label="CPI",
    title="December 2023",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
    legend=:bottomright,
)
plot!(1:24, collect(values(apc_dfs[2][end, 1:24])); label="Core CPI")
plot!(1:24, collect(values(apc_dfs[3][end, 1:24])); label="PCE")
plot!(1:24, collect(values(apc_dfs[4][end, 1:24])); label="Core PCE")
hline!([2]; label="Fed Target", color=:black, linestyle=:dash, linewidth=2)
#%% Save the figure
savefig(nov23, "dec23.png")

#%% Create a plot showing the december 2023 data's effect on coefficents
params = estimate_parameters.(apc_dfs)
#%% Create a past 61 plot
past61 = plot(
    apc_dfs[1].date[(end - 61):end],
    params[1][1][(end - 61):end];
    ribbon=2.0 .* params[1][2][(end - 61):end],
    label="CPI",
    yflip=true,
    title="Estimate of 24 Month Slope Coefficent (95 % CI)",
    xlabel="Date",
)
plot!(
    apc_dfs[2].date[(end - 61):end],
    params[2][1][(end - 61):end];
    ribbon=2.0 .* params[2][2][(end - 61):end],
    label="Core CPI",
    yflip=true,
)
plot!(
    apc_dfs[3].date[(end - 61):end],
    params[3][1][(end - 61):end];
    ribbon=2.0 .* params[3][2][(end - 61):end],
    label="PCE",
    yflip=true,
)
plot!(
    apc_dfs[4].date[(end - 61):end],
    params[4][1][(end - 61):end];
    ribbon=2.0 .* params[4][2][(end - 61):end],
    label="Core PCE",
    yflip=true,
)
hline!([0]; label="No Trend", color=:black, linestyle=:dash, linewidth=2)
vline!(past61, [Date(2023, 11, 1)]; label="Last Update", color=:black, linestyle=:dash)
#%% Save the figure
savefig(past61, "past61.png")

#%% Make a comparison between the PCE curves in november and december
pce_comp = plot(
    1:24,
    collect(values(apc_dfs[3][end - 1, 1:24]));
    label="PCE November 2023",
    title="PCE Base Effect Curve: November vs December 2023",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
)
plot!(1:24, collect(values(apc_dfs[3][end, 1:24])); label="PCE December 2023")
plot!(1:24, collect(values(apc_dfs[4][end - 1, 1:24])); label="Core PCE November 2023")
plot!(1:24, collect(values(apc_dfs[4][end, 1:24])); label="Core PCE December 2023")
hline!(pce_comp, [2.0]; label="Fed Target", color=:black, linestyle=:dash, linewidth=2)
#%% Save the figure
savefig(pce_comp, "pce_comp.png")
