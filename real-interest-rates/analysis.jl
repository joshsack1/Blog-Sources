#%% Read in packages
using DataFrames, LinearAlgebra, GLM
#%% Create functions for analytical purposes
function create_x_vec(df::DataFrame)
    lags = size(df, 2) - 1
    x_vec = convert.(Ref(Float64), collect(1:lags))
    return x_vec, lags
end
#%%
function estimate_parameters(df::DataFrame)
    rows = size(df, 1)
    X, lags = create_x_vec(df)
    estimates = []
    errors = []
    for i in 1:rows
        y = collect(values(df[i, 1:Int(lags)]))
        mat = hcat(X, y)
        tmp_df = DataFrame(mat, ["months", "apc"])
        reg = lm(@formula(apc ~ months), tmp_df)
        push!(estimates, coef(reg)[2])
        push!(errors, stderror(reg)[2])
    end
    return estimates, errors
end
