#%% Read in packages
using Plots, Dates
#%% Set up PlotThemes
using PlotThemes
theme(:mute)
#%% Call data functions
include("data.jl")
#%% Pull what needs to be pulled for PCI inflation
pci = pull_index("PCEPI")
add_lags!(pci)
pci_lags = apc_df(pci)
#%% Create a dataframe for pci lags that will be easier to work with
pci_df = DataFrame(;
    date=pci_lags.date,
    pci1=pci_lags.pi1m,
    pci3=pci_lags.pi3m,
    pci6=pci_lags.pi6m,
    pci12=pci_lags.pi12m,
    pci18=pci_lags.pi18m,
    pci24=pci_lags.pi24m,
)
#%% Pull data for the federal funds rates at monthly and daily frequencies
ffr_monthly = get_data(f, "DFF"; observation_start="1959-01-01", frequency="m", aggregation_method="avg").data[
    1:(end - 1), 3:4
]
#%% Pull the daily federal funds rate data
ffr = get_data(f, "DFF"; observation_start="1959-01-01").data[:, 3:4]
#%% Pull data on the five year treasury breakeven rate
# This is the difference between the five year treasury and the five year TIPS
br5 = get_data(f, "T5YIE").data[:, 3:4]
#%% Pull Cleveland Fed's Five Year Inflation Expectations
exp5 = get_data(f, "EXPINF5YR").data[:, 3:4]
#%% Create a plot for real interest rates based on five year breakevens and expectations
#%% Start by copying the data for ffr into a new dataframe that can be easily manipulated
five_year_ffr_daily = DataFrame(; date=ffr.date, ffr=ffr.value)
five_year_daily = outerjoin(five_year_ffr_daily, br5; on=:date)
dropmissing!(five_year_daily)
#%% Create a new column for the real interest rate
five_year_daily.real = five_year_daily.ffr .- five_year_daily.value
#%% Create the same thing for the monthly data
five_year_ffr_monthly = DataFrame(; date=ffr_monthly.date, ffr=ffr_monthly.value)
five_year_monthly = outerjoin(five_year_ffr_monthly, exp5; on=:date)
dropmissing!(five_year_monthly)
five_year_monthly.real = five_year_monthly.ffr .- five_year_monthly.value
#%% Create a five year plot
five_year_plot = plot(
    five_year_monthly.date[(end - 60):end],
    five_year_monthly.real[(end - 60):end];
    label="Expectations",
    title="Real Interest Rate Based On Five Year Inflation",
    xlabel="Date",
    ylabel="Real Rate",
)
plot!(
    five_year_daily.date[(end - 1327):end],
    five_year_daily.real[(end - 1327):end];
    label="Breakevens",
)
vline!(
    five_year_plot,
    [Date(2023, 7, 1)];
    label="Last Hike",
    color=:black,
    linestyle=:dash,
    linewidth=2,
)
#%% Save the figure
savefig(five_year_plot, "five_year_real.png")

#%% Create a plot looking at one year real interest rates
ffr_monthly = DataFrame(; date=ffr_monthly.date, ffr=ffr_monthly.value)
#%% Cleveland Fed one Year ahead inflation expectations
exp1 = get_data(f, "EXPINF1YR").data[:, 3:4]
rename!(exp1, :value => :exp1)
#%% University of Michigan One Year Ahead Inflation Expectations
uom = get_data(f, "MICH").data[:, 3:4]
rename!(uom, :value => :uom)
#%% Cut my useful dataframes down to the time from january 2019
pci_cut = pci_df[pci_df.date .>= Date(2019, 1, 1), :]
ffr_cut = ffr_monthly[ffr_monthly.date .>= Date(2019, 1, 1), :]
exp1_cut = exp1[exp1.date .>= Date(2019, 1, 1), :]
uom_cut = uom[uom.date .>= Date(2019, 1, 1), :]
#%% Join each of these dataframes into one
pci_and_ffr = outerjoin(pci_cut, ffr_cut; on=:date)
pci_and_ffr.real1 = pci_and_ffr.ffr .- pci_and_ffr.pci1
pci_and_ffr.real3 = pci_and_ffr.ffr .- pci_and_ffr.pci3
pci_and_ffr.real6 = pci_and_ffr.ffr .- pci_and_ffr.pci6
pci_and_ffr.real12 = pci_and_ffr.ffr .- pci_and_ffr.pci12
pci_and_ffr.real18 = pci_and_ffr.ffr .- pci_and_ffr.pci18
pci_and_ffr.real24 = pci_and_ffr.ffr .- pci_and_ffr.pci24
#%% join in inflation expectations
pci_and_ffr_exp1 = outerjoin(pci_and_ffr, exp1_cut; on=:date)
pci_and_ffr_exp1.real_exp = pci_and_ffr_exp1.ffr .- pci_and_ffr_exp1.exp1
#%% Add UOM 
main_df = outerjoin(pci_and_ffr_exp1, uom_cut; on=:date)
main_df.real_uom = main_df.ffr .- main_df.uom
#%% Create the main plot 
real_plot = plot(
    main_df.date,
    main_df.real3;
    label="3mPCI",
    title="Real Interest Rates",
    xlabel="Date",
    ylabel="Real Rate",
)
# plot!(main_df.date, main_df.real3; label="3mPCI")
plot!(main_df.date, main_df.real6; label="6mPCI")
plot!(main_df.date, main_df.real12; label="12mPCI")
plot!(main_df.date, main_df.real18; label="18mPCI")
# plot!(main_df.date, main_df.real24; label="24mPCI")
plot!(main_df.date, main_df.real_exp; label="FBCLE1Y")
plot!(main_df.date, main_df.real_uom; label="UOM")
vline!(real_plot, [Date(2023, 7, 1)]; label="Last Hike", color=:black, linestyle=:dash, linewidth=2)
#%% Save the figure
savefig(real_plot, "real_interest_rates.png")
