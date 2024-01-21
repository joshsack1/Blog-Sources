#%% Add in packages
using DataFrames, FredData, Plots
#%% Set up FRED
key = ENV["FRED_API_KEY"]
f = Fred(key)
#%% Get data for OPHPBS
# Quarterly Data Starts at 1947-01-01
# Quarterly Data Ends at 2023-07-01
#%% Look at wage data
# Hourly Wages for Production and Nonsupervisory Workers: AHETPI. Monthly From 1964-01-01 -> 2023-12-01
# Total Private Production and Nonsupervisory Eployees: CES0500000006. Monthly From 1964-01-01 -> 2023-12-01
# Average Hourly Wages for all private employees: CES0500000003. Monthly From 2006-03-01 -> 2023-12-01
# Private Employment: USPRIV. Montly from 1939-01-01 to 2023-12-01
#%% Higher returns to Higher Wage Employees
# Third Quartile: LEU0252916200Q
# First Quartile: LEU0252916100
"A Function to pull out the data from FRED and return a well formed dataframe"
function pull_data(indicator::String, chosen_name::String)
    download = get_data(f, indicator)
    raw = download.data[:,3:4]
    sym_name = Symbol(chosen_name)
    return rename(raw, [:date, sym_name])
end
