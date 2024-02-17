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
    ylabel="Income (USD)",
    title = "1974-2019: Average Outpaced Median Income",
    formatter=:plain,
)
plot!(income_df.date, income_df.average; label="Average Real Income")
vspan!(raw_y_plot, [Date(1980, 1, 1), Date(1980, 7, 1)], color = :gray, alpha = 0.2, label = "Recession")
vspan!(raw_y_plot, [Date(1981, 7, 1), Date(1982, 11, 1)], color = :gray, alpha = 0.2, label = "")
vspan!(raw_y_plot, [Date(1990, 7, 1), Date(1991, 3, 1)], color = :gray, alpha = 0.2, label = "")
vspan!(raw_y_plot, [Date(2001, 3, 1), Date(2001, 11, 1)], color = :gray, alpha = 0.2, label = "")
vspan!(raw_y_plot, [Date(2007, 12, 1), Date(2009, 6, 1)], color = :gray, alpha = 0.2, label = "")
#%% Plot the evolution of the ratio of average to median income
income_df.ratio = income_df.average ./ income_df.median
plot!(twinx(), income_df.date, income_df.ratio; label="Ratio", color=:red, legend = :top, ylabel = "Average/Median Real Income")
#%% Save the figure
savefig(raw_y_plot, "pre-covid-ave-med.png")
