#%% Add packages
using FredData, Plots, DataFrames
#%% Set up Fred
key = ENV["FRED_API_KEY"]
f = Fred(key)
#%% Create a vector of the two series we need to create the plot
data_series = ["CLF16OV", "PAYEMS"]
#%% Pull The Data for each going back to january 1948
data = get_data.(Ref(f), data_series, observation_start="1948-01-01")
#%% Create each dataframe
df = data[1].data
#%% rename the values to civilian labor force
rename!(df, :value => :labor_force)
#%% add in the employment data to that the main dataframe
df.employment = data[2].data.value
#%% create a column that is the employment rate of the labor force as a percentage
df.employment_rate = df.employment ./ df.labor_force .* 100
#%% Plot the whole series, against a horizontal line at the final value
long_plot = plot(
    df.date,
    df.employment_rate;
    label="Employment Rate",
    legend=:bottomright,
    title="Employment Rate of the Labor Force",
    xlabel="Date",
    ylabel="Rate (%)",
    color = :black,
)
hline!([df.employment_rate[end]], label = "Biden Record (So Far)", color = :blue)
#%% Save the plot
savefig(long_plot, "long_plot.png")
#%% Create a plot for the last five years
short_plot = plot(
    df.date[end-60:end],
    df.employment_rate[end-60:end];
    label="Employment Rate",
    legend=:bottomright,
    title="Employment Rate of the Labor Force",
    xlabel="Date",
    ylabel="Rate (%)",
    color = :black,
)
vline!([df.date[end-35]], label = "Biden Inaguration", color = :green)
hline!([df.employment_rate[end-45]], label = "Trump Record", color = :red)
hline!([df.employment_rate[end]], label = "Biden Record (So Far)", color = :blue)
vline!([df.date[end-18]], label = "June 2022", color = :purple)
#%% Save the plot
savefig(short_plot, "short_plot.png")
