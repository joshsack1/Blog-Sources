using Plots
#%% Include previously define functions
include("analysis.jl")
include("data.jl")
#%% Read in data from each different type of inflation
sources = ["CPIAUCSL", "CPILFESL", "PCEPI", "PCEPILFE"]
raw_data = pull_index.(sources)
add_lags!.(raw_data)
apc_dfs = apc_df.(raw_data)

#%% Create the most recent base-effects curve
nov23 = plot(
    1:24,
    collect(values(apc_dfs[1][end, 1:24]));
    label="CPI",
    title="November 2023",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
    legend=:right,
)
plot!(1:24, collect(values(apc_dfs[2][end, 1:24])); label="Core CPI")
plot!(1:24, collect(values(apc_dfs[3][end, 1:24])); label="PCE")
plot!(1:24, collect(values(apc_dfs[4][end, 1:24])); label="Core PCE")
hline!([2]; label="Fed Target", color=:black, linestyle=:dash, linewidth=2)
# savefig(nov23, "November-2023.png")
##%% Create a plot for june 2022
jun23 = plot(
    1:24,
    collect(values(apc_dfs[1][end - 17, 1:24]));
    label="CPI",
    title="June 2022",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
    legend=:topright,
)
plot!(1:24, collect(values(apc_dfs[2][end - 17, 1:24])); label="Core CPI")
plot!(1:24, collect(values(apc_dfs[3][end - 17, 1:24])); label="PCE")
plot!(1:24, collect(values(apc_dfs[4][end - 17, 1:24])); label="Core PCE")
hline!([2]; label="Fed Target", color=:black, linestyle=:dash, linewidth=2)
savefig(jun23, "June-2022.png")
#%% Create plots for regression analysis
params = estimate_parameters.(apc_dfs)
past48 = plot(
    apc_dfs[1].date[(end - 48):end],
    params[1][1][(end - 48):end];
    ribbon=params[1][2][(end - 48):end],
    label="CPI",
    yflip=true,
    title="Estimate of 24 Month Slope Coefficent",
    xlabel="Date",
)
plot!(
    apc_dfs[2].date[(end - 48):end],
    params[2][1][(end - 48):end];
    ribbon=params[2][2][(end - 48):end],
    label="Core CPI",
    yflip=true,
)
plot!(
    apc_dfs[3].date[(end - 48):end],
    params[3][1][(end - 48):end];
    ribbon=params[3][2][(end - 48):end],
    label="PCE",
    yflip=true,
)
plot!(
    apc_dfs[4].date[(end - 48):end],
    params[4][1][(end - 48):end];
    ribbon=params[4][2][(end - 48):end],
    label="Core PCE",
    yflip=true,
)
hline!([0]; label="No Trend", color=:black, linestyle=:dash, linewidth=2)
savefig(past48, "48m-Slope-Trend.png")
