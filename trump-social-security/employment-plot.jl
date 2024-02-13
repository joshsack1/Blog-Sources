#%% Include packages
using Plots, FredData, DataFrames, Dates, PlotThemes
#%% Set the plot theme as mute
theme(:mute)
#%% Pull data from FRED
key = ENV["FRED_API_KEY"]
f = Fred(key)
#%% Pull employment data
data =
    get_data(f, "PAYEMS"; observation_start="2016-07-01").data
#%% Plot the data
emp_plot = plot(
    data.date,
    data.value;
    title="Employment Declined Under Trump",
    xlabel="Date",
    ylabel="All Nonfarm Employees (thousands)",
    label="Employment",
    formatter = :plain,
    legend = :bottomright,
)
vline!(emp_plot, [Date(2017, 1, 20)], label="Trump Inauguration")
vline!(emp_plot, [Date(2021, 1, 20)], label="Biden Inauguration")
hline!(emp_plot, [data.value[7]], label = " ")
#%% Save the figure
savefig(emp_plot, "trump-social-security/employment-plot.png")
