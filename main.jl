#%% Include analytical methods
include("analysis.jl")
#%% Read in data
using FredData
# Note that I have set an environment variable FRED_API_KEY
#%%
key = ENV["FRED_API_KEY"]
f = Fred(key)
#%% Create a function to pull in an index of interest
# List of identifiers: [CPIAUCSL, CPILFESL, PCEPI, PCEPILFE]
"A Function that will return a dataframe of an index and its values from January 1959 to the most recent observation"
function pull_index(identifier::String)
    fred_result = get_data(f, identifier; observation_start="1959-01-01", frequency="m")
    raw_df = fred_result.data
    clean_df = DataFrame(; date=raw_df.date, value=raw_df.value)
    return clean_df
end
#%% Create a function to add lags for up to two years
"A function that will add (default 24) lags to a dataframe"
function add_lags!(df::DataFrame, lag_length::Int=24)
    for i in 1:lag_length
        string_name = "l" * string(i)
        symbol_name = Symbol(string_name)
        transform!(df, :value => (x -> lag(x, i)) => symbol_name)
    end
end
#%% Using these lagged values, add columns for the annualized percent change in the index at each lag
# THIS SHOULD RETURN A NEW DATAFRAME
