function raw_to_df(raw_data)

    # Argument ":auto" is required to generate column names in latest version of DataFrames.jl (v1.2.1)    
    df = DataFrame(raw_data[1], :auto) 
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

function average_price_df(currency::String, df_in::DataFrame)
    
    df_out_price, df_out_candle  = [DataFrame() for i = 1:2]

    df_out_price[!,:Date] = df_in[!,:Date]        
    
    df_out_price[!,Symbol("$currency")] = (df_in[!,Symbol("open (EUR)")] + df_in[!,Symbol("high (EUR)")] + df_in[!,Symbol("low (EUR)")] + df_in[!,Symbol("close (EUR)")])/4

    candle_col = Any[]
    for i in 1:size(df_in)[1]
        push!(candle_col, (df_in[!,Symbol("open (EUR)")][i], df_in[!,Symbol("high (EUR)")][i], df_in[!,Symbol("low (EUR)")][i], df_in[!,Symbol("close (EUR)")][i]))
    end

    df_out_candle[!,:Date] = df_in[!,:Date]
    
    df_out_candle[!,Symbol("$currency")] = candle_col 
    
    return df_out_price, df_out_candle
end

function vol_df(currency::String, df_in::DataFrame)

    df_out_vol = DataFrame()

    df_out_vol[!,:Date] = df_in[!,:Date]    
    df_out_vol[!,Symbol("$currency")] = df_in[!,:volume]

    return df_out_vol
end

function moving_averages(Price_df::DataFrame, duration::Int64, window::Int64)
    
    # Price_df should have date order - oldest to latest
    Price_col = Price_df[end-duration+1-window+1:end,2]
    rows1 = length(Price_col)
    Price_SMA, Price_WMA, Price_EMA = [Float64[] for i = 1:3]

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
    
    return Price_SMA, Price_WMA, Price_EMA
end

function calculate_ema(Price_col::Vector{Float64}, window::Int64)

    k(window) = 2/(window+1)
	Price_EMA = Float64[]
	rows = length(Price_col)
	
	for i = 1:rows-(window-1)
		
		SMA = mean(Price_col[i:i+(window-1)])
        EMA = (Price_col[i+(window-1)]*k(window)) + 
		      (SMA*(1-k(window)))
        push!(Price_EMA, EMA) 
	end
	
	return Price_EMA
end

function calculate_macd(Price_df::DataFrame, window_long::Int64 = 26, 
                        window_short::Int64 = 12, window_signal::Int64 = 9)
	
	# Price_df should have date order - oldest to latest    
	Price_col = Price_df[!, 2]	
	
	# Calculate 26 (long) and 12 (short) period EMA
	Price_EMA_short = calculate_ema(Price_col, window_short)	
	Price_EMA_long = calculate_ema(Price_col, window_long)		
	
	# Make EMA_long and EMA_short equal	
	EMA_short_col = Price_EMA_short[window_long - window_short + 1:end]
	
	# Calculate MACD = EMA_short - EMA_long
	MACD_col = EMA_short_col - Price_EMA_long
	
	# Calculate signal line (9 period EMA of MACD)	
	Signal_col = calculate_ema(MACD_col, window_signal)
	
	df_ema = DataFrame(date = Price_df[window_long+window_signal-1:end, :Date], 
                      Raw = Price_df[window_long+window_signal-1:end, 2], 
                      EMA_long = Price_EMA_long[window_signal:end], 
                      EMA_short = EMA_short_col[window_signal:end], 
                      MACD = MACD_col[window_signal:end], Signal = Signal_col)	
	
	return df_ema
end	

