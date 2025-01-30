using YFinance, DataFrames, Plots, PlotThemes
theme(:mute)
#%%
income_statement = get_Fundamental(
    "MSTR", "income_statement", "annual", "2019-12-31", "2024-12-31"
)
#%%
mstr = DataFrame(;
    date=income_statement["timestamp"],
    pretax_income=income_statement["PretaxIncome"],
    tax=income_statement["TaxProvision"],
    net_income=income_statement["NetIncome"],
)
#%% Create a general plot showing how taxpayers have subsidized Microstrategy over the past few years
# First, add in TTM Data
# 2024-12-31T00:00:00 -968255000 -561530000 -406725000
push!(mstr, (Date("2024-12-31"), -968255000, -561530000, -406725000))
#%%
mstr_subsidy = -sum(mstr.tax)
mstr_subsidy = mstr_subsidy / 1_000_000_000
clean_subsidy = round(mstr_subsidy; digits=2)
#%%
mstr_plot = plot(
    mstr.date,
    mstr.pretax_income ./ 1000;
    label="Pretax Income",
    legend=:bottomleft,
    xlabel="Year Ending",
    ylabel="\$('000)",
    title="2020-4: MSTR Recieved \$ $clean_subsidy B in Tax Subsidies",
    yformatter = :plain,
    linewidth=2,
)
plot!(mstr.date, mstr.net_income ./ 1000; label="Net Income", linewidth=2)
#%%
bar_colors = [v < 0 ? :green : :red for v in mstr.tax]
bar!(mstr.date, -1.0 .* mstr.tax ./ 1000; label="Tax Subsidy", alpha=0.5, color=bar_colors)
hline!([0.0]; label="", linewidth=2, linecolor=:black)
#%% Save the figure
savefig(mstr_plot, "MSTR-Tax/mstr_tax_subsidy.png")
