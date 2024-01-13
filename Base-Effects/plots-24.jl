using Plots
using ShiftedArrays: lead
using StatsPlots
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
#%% Save figure
savefig(nov23, "November-2023.png")
##%% Create a plot for May 2021
may21 = plot(
    1:24,
    collect(values(apc_dfs[1][end - 30, 1:24]));
    label="CPI",
    title="May 2021",
    xlabel="Months",
    ylabel="Annualized Inflation Rate",
    legend=:topright,
)
plot!(1:24, collect(values(apc_dfs[2][end - 30, 1:24])); label="Core CPI")
plot!(1:24, collect(values(apc_dfs[3][end - 30, 1:24])); label="PCE")
plot!(1:24, collect(values(apc_dfs[4][end - 30, 1:24])); label="Core PCE")
hline!([2]; label="Fed Target", color=:black, linestyle=:dash, linewidth=2)
#%% Save figure
savefig(may21, "June-2022.png")
#%% Create plots for regression analysis
params = estimate_parameters.(apc_dfs)
past60 = plot(
    apc_dfs[1].date[(end - 60):end],
    params[1][1][(end - 60):end];
    ribbon=2.0 .* params[1][2][(end - 60):end],
    label="CPI",
    yflip=true,
    title="Estimate of 24 Month Slope Coefficent (95 % CI)",
    xlabel="Date",
)
plot!(
    apc_dfs[2].date[(end - 60):end],
    params[2][1][(end - 60):end];
    ribbon=2.0 .* params[2][2][(end - 60):end],
    label="Core CPI",
    yflip=true,
)
plot!(
    apc_dfs[3].date[(end - 60):end],
    params[3][1][(end - 60):end];
    ribbon=2.0 .* params[3][2][(end - 60):end],
    label="PCE",
    yflip=true,
)
plot!(
    apc_dfs[4].date[(end - 60):end],
    params[4][1][(end - 60):end];
    ribbon=2.0 .* params[4][2][(end - 60):end],
    label="Core PCE",
    yflip=true,
)
hline!([0]; label="No Trend", color=:black, linestyle=:dash, linewidth=2)
#%% Save figure
savefig(past60, "60m-Slope-Trend.png")
#%% Create a plot of coefficents against inflation one year out
"A function that will take a DataFrame and add a lead of a specific variable"
function add_lead!(df::DataFrame, sym_name::String, lead::Int64=12)
    lead_name = sym_name * "_lead" * string(lead)
    lead_symbol = Symbol(lead_name)
    return transform!(df, Symbol(sym_name) => (x -> lead(x, lead)) => lead_symbol)
end
#%% Create vectors of inflation rates one year ahead and plot them against the slope coefficents
#%% cpi lead variables
cpi_lead1 = lead(apc_dfs[1].pi1m, 6)
cpi_lead3 = lead(apc_dfs[1].pi3m, 6)
cpi_lead6 = lead(apc_dfs[1].pi6m, 6)
cpi_lead12 = lead(apc_dfs[1].pi12m, 6)
cpi_lead18 = lead(apc_dfs[1].pi18m, 6)
cpi_lead24 = lead(apc_dfs[1].pi24m, 6)
#%% Create other lead variables
core_cpi_lead12 = lead(apc_dfs[2].pi12m, 6)
pce_lead12 = lead(apc_dfs[3].pi12m, 6)
core_pce_lead12 = lead(apc_dfs[4].pi12m, 6)
#%% Filter the data by times when the parameter was two standard deviations away from zero
evaluation_df = DataFrame(;
    cpi=cpi_lead12[1:(end - 6)] - apc_dfs[1].pi12m[1:(end - 6)],
    core_cpi=core_cpi_lead12[1:(end - 6)] - apc_dfs[2].pi12m[1:(end - 6)],
    pce=pce_lead12[1:(end - 6)] - apc_dfs[3].pi12m[1:(end - 6)],
    core_pce=core_pce_lead12[1:(end - 6)] - apc_dfs[4].pi12m[1:(end - 6)],
    cpi_slope=params[1][1][1:(end - 6)],
    core_cpi_slope=params[2][1][1:(end - 6)],
    pce_slope=params[3][1][1:(end - 6)],
    core_pce_slope=params[4][1][1:(end - 6)],
    cpi_err=params[1][2][1:(end - 6)],
    core_cpi_err=params[2][2][1:(end - 6)],
    pce_err=params[3][2][1:(end - 6)],
    core_pce_err=params[4][2][1:(end - 6)],
)
#%% Cut the missing values out of that df
dropmissing!(evaluation_df)
#%% Create an indicator function to determine if a value is greater than two standard deviations away from zero
ind(param, err) = abs(param) > 2 * err
#%% Add columns with indicators
evaluation_df.cpi_ind = ind.(evaluation_df.cpi_slope, 2.0 .* evaluation_df.cpi_err)
evaluation_df.core_cpi_ind =
    ind.(evaluation_df.core_cpi_slope, 2.0 .* evaluation_df.core_cpi_err)
evaluation_df.pce_ind = ind.(evaluation_df.pce_slope, 2.0 .* evaluation_df.pce_err)
evaluation_df.core_pce_ind =
    ind.(evaluation_df.core_pce_slope, 2.0 .* evaluation_df.core_pce_err)
#%% Create scatter plots for each inflation measure
pred_value = scatter(
    evaluation_df.cpi_slope[evaluation_df.cpi_ind],
    evaluation_df.cpi[evaluation_df.cpi_ind];
    label="CPI",
    framestyle=:origin,
    alpha=0.5,
    title="12 Month Inflation Rate Change, 6 Months Ahead",
    xlabel="Slope Coefficent",
)

scatter!(
    evaluation_df.core_cpi_slope[evaluation_df.core_cpi_ind],
    evaluation_df.core_cpi[evaluation_df.core_cpi_ind];
    label="Core CPI",
    alpha=0.5,
)

scatter!(
    evaluation_df.pce_slope[evaluation_df.pce_ind],
    evaluation_df.pce[evaluation_df.pce_ind];
    label="PCE",
    alpha=0.5,
)

scatter!(
    evaluation_df.core_pce_slope[evaluation_df.core_pce_ind],
    evaluation_df.core_pce[evaluation_df.core_pce_ind];
    label="Core PCE",
    alpha=0.5,
)
#%% Save figure
savefig(pred_value, "correlation.png")
