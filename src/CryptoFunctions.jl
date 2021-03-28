function raw_to_df(raw_data)
    df = DataFrame(raw_data[1])
    df_names = Symbol.(vcat(raw_data[2]...))
    df = DataFrames.rename(df, df_names)

    timestamps = df[!,:timestamp]

    select!(df, Not([:timestamp]))

    for col in eachcol(df)
        col = Float64.(col)
    end

    df[!,:Date] = Date.(timestamps)
    return df
end

function average_price_df(currency::String, df_in::DataFrame, df_out_price::DataFrame, df_out_candle::DataFrame)
    
    if isempty(names(df_out_price))
        df_out_price[!,:Date] = df_in[!,:Date]
    end    
    
    df_out_price[!,Symbol("$currency")] = (df_in[!,Symbol("open (EUR)")] + df_in[!,Symbol("high (EUR)")] + df_in[!,Symbol("low (EUR)")] + df_in[!,Symbol("close (EUR)")])/4

    candle_col = []
    for i in 1:size(df_in)[1]
        push!(candle_col, (df_in[!,Symbol("open (EUR)")][i], df_in[!,Symbol("high (EUR)")][i], df_in[!,Symbol("low (EUR)")][i], df_in[!,Symbol("close (EUR)")][i]))
    end

    if isempty(names(df_out_candle))
        df_out_candle[!,:Date] = df_in[!,:Date]
    end
    df_out_candle[!,Symbol("$currency")] = candle_col    
end

function vol_df(currency::String, df_in::DataFrame, df_out_vol::DataFrame)
    if isempty(names(df_out_vol))
        df_out_vol[!,:Date] = df_in[!,:Date]
    end 

    df_out_vol[!,Symbol("$currency")] = df_in[!,:volume]
end

function moving_averages(Price_df::DataFrame, duration::Int64, window::Int64, currency::String)
        
    # Reverse the order of the DataFrame, oldest date first, newest at the bottom
    Price_df_rev = DataFrame()
    Price_df_rev[!,:Date] = Price_df[!,:Date][end:-1:1]
    Price_df_rev[!,Symbol("$(currency)")] = Price_df[!,2][end:-1:1]

    Price_col = Price_df_rev[end-duration+1-window+1:end,2]
    rows1 = length(Price_col)
    Price_SMA = Array{Float64}(undef,0)    
    Price_WMA = Array{Float64}(undef,0)
    Price_EMA = Array{Float64}(undef,0)

    weights = collect(1:window)/(window*(window+1)/2) 
    k = 2/(window+1)
    
    # Calculate different Moving Averages
    for i = 1:rows1-(window-1)
        # Simple Moving Average (SMA)
        push!(Price_SMA, mean(Price_col[i:i+(window-1)]))

        # Weighted Moving Average
        push!(Price_WMA, sum(Price_col[i:i+(window-1)].*weights))

        # Exponential Moving Average
        SMA = mean(Price_col[i:i+(window-1)])
        EMA = (Price_col[i+(window-1)]*k)+(SMA*(1-k))
        push!(Price_EMA, EMA) 
    end 
    
    return Price_df_rev, Price_SMA, Price_WMA, Price_EMA
end