#%% Add in packages
using DataFrames, FredData, Plots, PlotThemes, Dates
#%% Set up Plot Theme
theme(:mute)
#%% Set up FRED
key = ENV["FRED_API_KEY"]
f = Fred(key)
#%% Get median and average incomes from 1974 to 2019
series = ["MEPAINUSA672N", "MAPAINUSA672N"]
income_raw = get_data.(Ref(f), series, observation_end="2019-12-31")
income_data = [income_raw[i].data for i in eachindex(income_raw)]
#%% Create a merged dataframe
income_df = DataFrame(;
    date=income_data[1].date, median=income_data[1].value, average=income_data[2].value
)
#%% Create a comparative plot
raw_y_plot = plot(
    income_df.date,
    income_df.median;
    label="Median Real Income",
    xlabel="Year",
    ylabel="Income (2022 USD)",
    title="1974-2019: Average Outpaced Median Income",
    formatter=:plain,
)
plot!(income_df.date, income_df.average; label="Average Real Income")
vspan!(
    raw_y_plot,
    [Date(1980, 1, 1), Date(1980, 7, 1)];
    color=:gray,
    alpha=0.2,
    label="Recession",
)
vspan!(raw_y_plot, [Date(1981, 7, 1), Date(1982, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(raw_y_plot, [Date(1990, 7, 1), Date(1991, 3, 1)]; color=:gray, alpha=0.2, label="")
vspan!(raw_y_plot, [Date(2001, 3, 1), Date(2001, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(raw_y_plot, [Date(2007, 12, 1), Date(2009, 6, 1)]; color=:gray, alpha=0.2, label="")
#%% Plot the evolution of the ratio of average to median income
income_df.ratio = income_df.average ./ income_df.median
plot!(
    twinx(),
    income_df.date,
    income_df.ratio;
    label="Ratio",
    color=:red,
    legend=:top,
    ylabel="Average/Median Real Income",
)
#%% Save the figure
savefig(raw_y_plot, "production-wages/pre-covid-ave-med.png")
#%% Create a gini coefficent plot
gini_data = get_data(f, "SIPOVGINIUSA"; observation_end="2019-12-31").data
#%% Create a gini plot
gini_plot = plot(
    gini_data.date,
    gini_data.value;
    legend=false,
    title="Gini Coefficent: 1963-2019",
    xlabel="Year",
    ylabel="Gini Coefficent",
)
vspan!(
    raw_y_plot,
    [Date(1980, 1, 1), Date(1980, 7, 1)];
    color=:gray,
    alpha=0.2,
    label="Recession",
)
vspan!(gini_plot, [Date(1969, 12, 1), Date(1970, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(gini_plot, [Date(1973, 11, 1), Date(1975, 3, 1)]; color=:gray, alpha=0.2, label="")
vspan!(gini_plot, [Date(1981, 7, 1), Date(1982, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(gini_plot, [Date(1990, 7, 1), Date(1991, 3, 1)]; color=:gray, alpha=0.2, label="")
vspan!(gini_plot, [Date(2001, 3, 1), Date(2001, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(gini_plot, [Date(2007, 12, 1), Date(2009, 6, 1)]; color=:gray, alpha=0.2, label="")
#%% Save the figure
savefig(gini_plot, "production-wages/pre-covid-gini.png")
#%% Get set up for wealth plot
wealth_series = ["WFRBLB50107", "WFRBLN40080", "WFRBLN09053", "WFRBLT01026"]
wealth_raw = get_data.(Ref(f), wealth_series, observation_end="2019-12-31")
#%% Create a merged dataframe
wealth_data = [wealth_raw[i].data for i in eachindex(wealth_raw)]
##%% set up the main dataframe
wealth_df = DataFrame(;
    date=wealth_data[1].date,
    bottom_50=wealth_data[1].value,
    middle_40=wealth_data[2].value,
    most_10=wealth_data[3].value,
    top_1=wealth_data[4].value,
)
#%% Create relative data columns
wealth_df.bottom_perf = 100.0 * wealth_df.bottom_50 / wealth_df.bottom_50[1]
wealth_df.middle_perf = 100.0 * wealth_df.middle_40 / wealth_df.middle_40[1]
wealth_df.most_perf = 100.0 * wealth_df.most_10 / wealth_df.most_10[1]
wealth_df.top_perf = 100.0 * wealth_df.top_1 / wealth_df.top_1[1]
#%% Create a relative wealth plot
wealth_plot = plot(
    wealth_df.date,
    wealth_df.bottom_perf;
    label="Bottom 50%",
    title="1989-2019: The Rich did Much Better",
    xlabel="Year",
    ylabel="Wealth (Q2 1989=100)",
)
plot!(wealth_df.date, wealth_df.middle_perf; label="50 - 90%")
plot!(wealth_df.date, wealth_df.most_perf; label="90 - 99%")
plot!(wealth_df.date, wealth_df.top_perf; label="Top 1%")
vspan!(wealth_plot, [Date(1990, 7, 1), Date(1991, 3, 1)]; color=:gray, alpha=0.2, label="Recession")
vspan!(wealth_plot, [Date(2001, 3, 1), Date(2001, 11, 1)]; color=:gray, alpha=0.2, label="")
vspan!(wealth_plot, [Date(2007, 12, 1), Date(2009, 6, 1)]; color=:gray, alpha=0.2, label="")
#%% Save the figure
savefig(wealth_plot, "production-wages/pre-covid-wealth.png")
