function raw_to_df(raw_data)

    # Argument ":auto" is required to generate column names in latest version of DataFrames.jl (v1.2.1)    
    df = DataFrame(raw_data[1], :auto)
    df_names = Symbol.(vcat(raw_data[2]...))
    df = DataFrames.rename(df, df_names)

    timestamps = df[!, :timestamp]

    select!(df, Not([:timestamp]))

    for col in eachcol(df)
        col = Float64.(col)
    end

    df[!, :Date] = Date.(timestamps)
    return df
end

function average_df_price(currency::String, df_in::DataFrame)

    df_out_price, df_out_candle = [DataFrame() for i = 1:2]

    df_out_price[!, :Date] = df_in[!, :Date]

    df_out_price[!, Symbol("$currency")] =
        (
            df_in[!, Symbol("open (EUR)")] +
            df_in[!, Symbol("high (EUR)")] +
            df_in[!, Symbol("low (EUR)")] +
            df_in[!, Symbol("close (EUR)")]
        ) / 4

    candle_col = Any[]
    for i = 1:size(df_in)[1]
        push!(
            candle_col,
            (
                df_in[!, Symbol("open (EUR)")][i],
                df_in[!, Symbol("high (EUR)")][i],
                df_in[!, Symbol("low (EUR)")][i],
                df_in[!, Symbol("close (EUR)")][i],
            ),
        )
    end

    df_out_candle[!, :Date] = df_in[!, :Date]

    df_out_candle[!, Symbol("$currency")] = candle_col

    return df_out_price, df_out_candle
end

function df_vol(currency::String, df_in::DataFrame)

    df_out_vol = DataFrame()

    df_out_vol[!, :Date] = df_in[!, :Date]
    df_out_vol[!, Symbol("$currency")] = df_in[!, :volume]

    return df_out_vol
end

function moving_averages(df_price::DataFrame, duration::Int64, window::Int64)

    # df_price should have date order - oldest to latest
    Price_col = df_price[end-duration+1-window+1:end, 2]
    rows1 = length(Price_col)
    price_SMA, price_WMA, price_EMA = [Float64[] for i = 1:3]

    weights = collect(1:window) / (window * (window + 1) / 2)
    k = 2 / (window + 1)

    # Calculate different Moving Averages
    for i = 1:rows1-(window-1)
        # Simple Moving Average (SMA)
        push!(price_SMA, mean(Price_col[i:i+(window-1)]))

        # Weighted Moving Average
        push!(price_WMA, sum(Price_col[i:i+(window-1)] .* weights))

        # Exponential Moving Average
        SMA = mean(Price_col[i:i+(window-1)])
        EMA = (Price_col[i+(window-1)] * k) + (SMA * (1 - k))
        push!(price_EMA, EMA)
    end

    return price_SMA, price_WMA, price_EMA
end

function moving_std(df_price::DataFrame, duration::Int64, window::Int64)

    # df_price should have date order - oldest to latest
    Price_col = df_price[end-duration+1-window+1:end, 2]
    rows1 = length(Price_col)

    Price_std = Float64[]

    for i = 1:rows1-(window-1)
        # Standard deviation over the period SMA is also being calculated
        push!(Price_std, std(Price_col[i:i+(window-1)]))
    end

    return Price_std
end

function calculate_ema(Price_col::Vector{Float64}, window::Int64)

    k(window) = 2 / (window + 1)
    price_EMA = Float64[]
    rows = length(Price_col)

    for i = 1:rows-(window-1)

        SMA = mean(Price_col[i:i+(window-1)])
        EMA = (Price_col[i+(window-1)] * k(window)) + (SMA * (1 - k(window)))
        push!(price_EMA, EMA)
    end

    return price_EMA
end

function calculate_macd(
    df_price::DataFrame,
    window_long::Int64 = 26,
    window_short::Int64 = 12,
    window_signal::Int64 = 9,
)

    # df_price should have date order - oldest to latest    
    Price_col = df_price[!, 2]

    # Calculate 26 (long) and 12 (short) period EMA
    price_EMA_short = calculate_ema(Price_col, window_short)
    price_EMA_long = calculate_ema(Price_col, window_long)

    # Make EMA_long and EMA_short equal	
    EMA_short_col = price_EMA_short[window_long-window_short+1:end]

    # Calculate MACD = EMA_short - EMA_long
    MACD_col = EMA_short_col - price_EMA_long

    # Calculate signal line (9 period EMA of MACD)	
    Signal_col = calculate_ema(MACD_col, window_signal)

    df_ema = DataFrame(
        date = df_price[window_long+window_signal-1:end, :Date],
        Raw = df_price[window_long+window_signal-1:end, 2],
        EMA_long = price_EMA_long[window_signal:end],
        EMA_short = EMA_short_col[window_signal:end],
        MACD = MACD_col[window_signal:end],
        Signal = Signal_col,
    )

    return df_ema
end