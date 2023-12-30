
using Plots
#%% Include previously define functions
include("analysis.jl")
include("data.jl")
#%% Read in data from each different type of inflation
sources = ["CPIAUCSL", "CPILFESL", "PCEPI", "PCEPILFE"]
raw_data = pull_index.(sources)
add_lags!.(raw_data, Ref(12))
apc_dfs = apc_df.(raw_data)

#%% Create the most recent base-effects curve
nov23 = plot(
    1:12,
    collect(values(apc_dfs[1][end, 1:12]));
    label="CPI",
    title="November 2023",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
    legend=:right,
)
plot!(1:12, collect(values(apc_dfs[2][end, 1:12])); label="Core CPI")
plot!(1:12, collect(values(apc_dfs[3][end, 1:12])); label="PCE")
plot!(1:12, collect(values(apc_dfs[4][end, 1:12])); label="Core PCE")
hline!([0]; label="No Trend", color=:black, linestyle=:dash, linewidth=2)
savefig(nov23, "November-2023-12.png")
#%% Create a plot for june 2022
jun23 = plot(
    1:12,
    collect(values(apc_dfs[1][end - 17, 1:12]));
    label="CPI",
    title="June 2022",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
    legend=:topright,
)
plot!(1:12, collect(values(apc_dfs[2][end-17, 1:12])); label="Core CPI")
plot!(1:12, collect(values(apc_dfs[3][end-17, 1:12])); label="PCE")
plot!(1:12, collect(values(apc_dfs[4][end-17, 1:12])); label="Core PCE")
hline!([0]; label="No Trend", color=:black, linestyle=:dash, linewidth=2)
savefig(jun23, "June-2022-12.png")
