#%% Read in data
using FredData, DataFrames
using ShiftedArrays: lag
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
"A function to calculate the annualized percent change based on a lag"
function annualized_percent_change(current::Vector{Float64}, lagged::Vector{Float64}, lags::Int64)
    percent_change = (current .- lagged) ./ lagged
    apc = ((1 .+ percent_change) .^ (12/lags)) .- 1
    return 100.0 .* apc
end

"A function to create a dataframe of annualized percent changes based on a dataframe of lags"
function apc_df(df::DataFrame)
    lags = size(df, 2) - 2
    clean_df = dropmissing!(df[lags+1:end, :])
    current = clean_df[:, :value]
    lag_collection = []
    for i in 1:lags 
        string_name = "l" * string(i)
        symbol_name = Symbol(string_name)
        push!(lag_collection, clean_df[:, symbol_name])
    end
    inter = annualized_percent_change.(Ref(current), lag_collection, 1:lags)
    data_mat = hcat(inter...)
    col_names = ["pi" * string(i) * "m" for i in 1:lags]
    rdf = DataFrame(data_mat, col_names)
    rdf.date = clean_df.date
    return rdf
end
