#%% Use Packages
using FredData, DataFrames, Plots, Dates, StatsPlots
#%% Set up FRED
key = ENV["FRED_API_KEY"]
f = Fred(key)
##%% Get Data on Deficit as a Percentage of GDP
deficit_output_value =
    get_data(
        f, "FYFSGDA188S"; observation_start="1979-01-01", observation_end="2019-01-01"
    ).data
#%%
defict_output_change =
    get_data(
        f,
        "FYFSGDA188S";
        observation_start="1979-01-01",
        observation_end="2019-01-01",
        units="pch",
    ).data

#%% Get Data on GDP Growth
real_gdp_growth =
    get_data(
        f, "A191RL1Q225SBEA"; observation_start="1979-01-01", observation_end="2020-02-01"
    ).data
#%% Get Data on Unemployment
unemployment_rate =
    get_data(
        f,
        "UNRATE";
        observation_start="1979-01-01",
        observation_end="2019-01-01",
        frequency="a",
        aggregation_method="avg",
    ).data

#%% Change in Real Gross Private Domestic Investment
real_gross_private_domestic_investment_change =
    get_data(
        f,
        "GPDIC1";
        observation_start="1979-01-01",
        observation_end="2020-02-01",
        units="pc1",
    ).data
#%% Get annual GDP Data and Federal Tax Data from 1979 - 2019
#%%
output = get_data(f, "GDPA"; observation_start="1979-01-01", observation_end="2019-01-01").data
#%% 
corp_tax = get_data(f, "FCTAX"; observation_start="1979-01-01", observation_end="2019-01-01").data
#%% Create a combined dataframe
corp_tax_df = DataFrame(
    date = corp_tax.date,
    corp_tax = corp_tax.value,
    output = output.value,
)
#%% Crate a column for the share of output
corp_tax_df.share = 100 .* (corp_tax_df.corp_tax ./ corp_tax_df.output)
#%% Create a plot of corporate tax revenue
corp_tax_plot = plot(
    corp_tax_df[(end - 24):end, :date],
    corp_tax_df[(end - 24):end, :corp_tax];
    label="Corporate Tax Revenue",
    ylabel="Dollars (Billions)",
    xlabel="Year",
    color=:black,
    legend=:topleft,
    title="Corporate Tax Revenue",
)
hline!(corp_tax_plot, [corp_tax_df.corp_tax[end]]; label="2019 Revenue", color=:black, linestyle=:dash)
vline!(corp_tax_plot, [Date(2017, 1, 1)]; label="Trump Inauguration", color=:red)
vline!(
    corp_tax_plot,
    [Date(2018, 1, 1)];
    label="Trump Tax Cuts",
    color=:red,
    linestyle=:dash,
)
vspan!(corp_tax_plot, [Date(2007,12,1), Date(2009,6,1)]; label="Great Recession", color=:gray, alpha=0.2)
vspan!(corp_tax_plot, [Date(2001,3,1), Date(2001,11,1)]; label="Dot Com", color=:gray, alpha=0.2)
#%% save the figure
savefig(corp_tax_plot, "corp_tax_rev.png")
#%% Look at the share of GDP Represented by Corporate Tax Revenue
rev_share = plot(
    corp_tax_df[:, :date],
    corp_tax_df[:, :share];
    label="Corporate Tax Revenue",
    ylabel="Percentage Points",
    xlabel="Year",
    color=:black,
    legend=false,
    title="Corporate Tax Revenue as a Share of GDP",
)
vspan!(rev_share, [Date(2007,12,1), Date(2009,6,1)]; label="Great Recession", color=:gray, alpha=0.2)
vspan!(rev_share, [Date(2001,3,1), Date(2001,11,1)]; label="Dot Com", color=:gray, alpha=0.2)
vspan!(rev_share, [Date(1990,1,1), Date(1991,3,1)]; label="Recession", color=:gray, alpha=0.2)
vspan!(rev_share, [Date(1981,7,1), Date(1982,11,1)]; label="Recession", color=:gray, alpha=0.2)
vspan!(rev_share, [Date(1980,1,1), Date(1980,7,1)]; label="Recession", color=:gray, alpha=0.2)
hline!(rev_share, [corp_tax_df.share[end]]; label="2019 Revenue", color=:black, linestyle=:dash)
#%% Save the figure
savefig(rev_share, "corp_tax_rev_share.png")
#%% Create a basic plot showing the deficit trend
def_trend = plot(
    deficit_output_value[(end - 9):end, :date],
    deficit_output_value[(end - 9):end, :value];
    label="Deficit",
    ylabel="Federal Surplus, % of GDP",
    xlabel="Year",
    color=:black,
    yflip=true,
    legend=:top,
    title="Trump Made America Borrow Again",
)
vline!(def_trend, [Date(2017, 1, 1)]; label="Trump Inauguration", color=:red)
vline!(def_trend, [Date(2018, 1, 1)]; label="Trump Tax Cuts", color=:red, linestyle=:dash)
#%% Save the figure
savefig(def_trend, "def_trend.png")
#%% Create a first plot, looking at deficits along with unemployment
def_trend_obama_trump = plot(
    deficit_output_value[(end - 9):end, :date],
    deficit_output_value[(end - 9):end, :value];
    label="Deficit",
    ylabel="Surplus, % of GDP",
    xlabel="Year",
    color=:black,
    yflip=true,
    legend=:top,
)
plot!(
    twinx(),
    unemployment_rate[(end - 9):end, :date],
    unemployment_rate[(end - 9):end, :value];
    label="Unemployment",
    color=:blue,
    ylabel="Unemployment Rate, %",
    legend=:left,
)
vline!(def_trend_obama_trump, [Date(2017, 1, 1)]; label="Trump Inauguration", color=:red)
vline!(
    def_trend_obama_trump,
    [Date(2018, 1, 1)];
    label="Trump Tax Cuts",
    color=:red,
    linestyle=:dash,
)
#%% Save the figure
savefig(def_trend_obama_trump, "def_trend_obama_trump.png")
#%% Create a second plot, that compares the trend of deficits to the trend of GDP growth
def_g_trend_obama_trump = plot(
    deficit_output_value[(end - 9):end, :date],
    deficit_output_value[(end - 9):end, :value];
    label="Deficit",
    ylabel="Surplus, % of GDP",
    xlabel="Year",
    color=:black,
    yflip=true,
    legend=false,
)
plot!(
    twinx(),
    real_gdp_growth[(end - 36):end, :date],
    real_gdp_growth[(end - 36):end, :value];
    label="Real GDP Growth",
    ylabel="Real GDP Growth, %",
    color=:blue,
    legend=:bottomright,
)
vline!(def_g_trend_obama_trump, [Date(2017, 1, 1)]; label="Trump Inauguration", color=:red)
vline!(
    def_g_trend_obama_trump,
    [Date(2018, 1, 1)];
    label="Trump Tax Cuts",
    color=:red,
    linestyle=:dash,
)
#%% Create a compund plot with both plots stacked
first_plot = plot(
    def_trend_obama_trump,
    def_g_trend_obama_trump;
    layout=(2, 1),
    title="Tump: Increasing Borrowing in a Strong Economy",
)
#%% Save the figure
savefig(first_plot, "first_plot.png")
#%% Create stephists comparing growth under Obama and Trump
growth_hist = histogram(
    real_gdp_growth[(end - 11):(end - 1), :value];
    # label="Real GDP Growth",
    xlabel="Real GDP Growth, %",
    ylabel="Frequency",
    color=:red,
    bins=10,
    normalize=:pdf,
    label="Trump Pre-Covid",
    # legend=:topright,
    title="Distribution of Quarterly Real GDP Growth Rates",
)
histogram!(
    real_gdp_growth[(end - 28):(end - 12), :value];
    # label="Real GDP Growth",
    xlabel="Real GDP Growth, %",
    ylabel="Frequency",
    color=:blue,
    bins=10,
    normalize=:pdf,
    label="Obama 2",
    legend=:topleft,
)
#%% Save the figure
savefig(growth_hist, "growth_hist.png")
#%% Create a plot of real gross private investment change
investment_trend = plot(
    real_gross_private_domestic_investment_change[(end - 27):end, :date],
    real_gross_private_domestic_investment_change[(end - 27):end, :value];
    label="Investment",
    ylabel="Percent Change from One Year Earlier",
    xlabel="Date",
    color=:black,
    legend=:topright,
    title="Real Gross Domestic Private Investment: 2013-19",
)
hline!(investment_trend, [0]; label="Zero", color=:black, linestyle=:dash)
vline!(investment_trend, [Date(2017, 1, 1)]; label="Trump Inauguration", color=:red)
vline!(
    investment_trend,
    [Date(2018, 1, 1)];
    label="Trump Tax Cuts",
    color=:red,
    linestyle=:dash,
)
#%% Save the figure
savefig(investment_trend, "investment_trend.png")
