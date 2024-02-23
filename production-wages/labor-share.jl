#%% Set up environment
using DataFrames, FredData, Plots, PlotThemes, Dates
#%% Set the Plot Theme
theme(:mute)
#%% Set up Fred
key = ENV["FRED_API_KEY"]
f = Fred(key)
#%% Get the Data
labor_share_raw =
    get_data(
        f, "PRS85006172"; observation_start="1963-01-01", observation_end="2019-12-31"
    ).data
#%% Create an actual labor share dataframe
labor_share = DataFrame(;
    date=labor_share_raw.date, annualized_change=labor_share_raw.value
)
#%% Create a quarterly change column
labor_share.quarterly_change = labor_share.annualized_change / 4.0
#%% 1963 = 62.638 from Penn World Table 10.01
ls = [62.638]
for i in 2:length(labor_share.quarterly_change)
    push!(ls, ls[i - 1] * (1 + labor_share.quarterly_change[i] / 100))
end
#%% Create a plot of the labor share
labor_share.calculated = ls
labor_share.calculated_capital = 100 .- labor_share.calculated
#%% Create the actual plot
labor_share_plot = plot(
    labor_share.date,
    labor_share.calculated;
    xlabel="Date",
    ylabel="Labor Share (%)",
    title="Labor Share of Nonfarm Business Sector: 1963-2019",
    label = "Calculated Labor Share",
    legend=:bottomleft,
)
vspan!(
    labor_share_plot,
    [Date(1980, 1, 1), Date(1980, 7, 1)];
    color=:gray,
    alpha=0.2,
    label="Recession",
)
vspan!(labor_share_plot, [Date(1969, 12, 1), Date(1970, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(labor_share_plot, [Date(1973, 11, 1), Date(1975, 3, 1)]; color=:gray, alpha=0.2, label="")
vspan!(labor_share_plot, [Date(1981, 7, 1), Date(1982, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(labor_share_plot, [Date(1990, 7, 1), Date(1991, 3, 1)]; color=:gray, alpha=0.2, label="")
vspan!(labor_share_plot, [Date(2001, 3, 1), Date(2001, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(labor_share_plot, [Date(2007, 12, 1), Date(2009, 6, 1)]; color=:gray, alpha=0.2, label="")
#%% Save the figure
savefig(labor_share_plot, "pre-covid-labor-share.png")
#%% Create a capital share plot
capital_plot = plot(
    labor_share.date,
    labor_share.calculated_capital;
    xlabel="Date",
    ylabel="Capital Share (%)",
    title="Capital Share of Nonfarm Business Sector: 1963-2019",
    label = "Calculated Capital Share",
    legend=:topleft,
)
vspan!(
    capital_plot,
    [Date(1980, 1, 1), Date(1980, 7, 1)];
    color=:gray,
    alpha=0.2,
    label="Recession",
)
vspan!(capital_plot, [Date(1969, 12, 1), Date(1970, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(capital_plot, [Date(1973, 11, 1), Date(1975, 3, 1)]; color=:gray, alpha=0.2, label="")
vspan!(capital_plot, [Date(1981, 7, 1), Date(1982, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(capital_plot, [Date(1990, 7, 1), Date(1991, 3, 1)]; color=:gray, alpha=0.2, label="")
vspan!(capital_plot, [Date(2001, 3, 1), Date(2001, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(capital_plot, [Date(2007, 12, 1), Date(2009, 6, 1)]; color=:gray, alpha=0.2, label="")
#%% Save the figure
savefig(capital_plot, "pre-covid-capital-share.png")

