################# Plots for AlphaVantage data #################

function plot_price_ma_trade_data(index::Int64,
                                  duration::Int64,
                                  window::Int64,
                                  key::String = KEY)

    # Retrieve data from various helper functions
    df_price, _, df_vol = @mock get_price_data_single(currencies[index], key)

    # Make sure that duration does not exceed the number of rows - max(windows) in the DataFrame
    # This allows calculation of MA for the longest duration
    if duration > size(df_price)[1] - maximum(windows)
        duration = size(df_price)[1] - maximum(windows)
    end

    ################# Daily average data #################
    trace1 = PlotlyJS.scatter(;
        x = df_price[1:duration, :Date],
        y = df_price[1:duration, 2],
        mode = "markers+lines",
        name = "$(currencies[index]) price",
    )

    ################# Moving averages data #################
    sort!(df_price, :Date) # oldest date first, newest at the bottom
    price_SMA, price_WMA, price_EMA = moving_averages(df_price, duration, window)

    trace2 = PlotlyJS.scatter(;
        x = df_price[!, :Date][end-length(price_SMA)+1:end],
        y = price_SMA,
        mode = "lines",
        name = "$(names(df_price)[2]) SMA over $(window) days",
    )
    trace3 = PlotlyJS.scatter(;
        x = df_price[!, :Date][end-length(price_WMA)+1:end],
        y = price_WMA,
        mode = "lines",
        name = "$(names(df_price)[2]) WMA over $(window) days",
    )
    trace4 = PlotlyJS.scatter(;
        x = df_price[!, :Date][end-length(price_EMA)+1:end],
        y = price_EMA,
        mode = "lines",
        name = "$(names(df_price)[2]) EMA over $(window) days",
    )

    ################# Daily trade data #################
    sort!(df_price, :Date, rev = true) # newest date first, oldest at the bottom
    trace5 = PlotlyJS.bar(;
        x = df_price[1:duration, :Date],
        y = df_price[1:duration, 2] .* df_vol[1:duration, 2],
        mode = "markers+lines",
        name = "$(currencies[index]) daily trade",
    )

    return trace1, trace2, trace3, trace4, trace5
end

function plot_price_bollinger_bands(index::Int64,
                                    duration::Int64,
                                    window::Int64,
                                    key::String = KEY)

    df_price, _, _ = @mock get_price_data_single(currencies[index], key)

    if duration > size(df_price)[1] - maximum(windows)
        duration = size(df_price)[1] - maximum(windows)
    end

    sort!(df_price, :Date) # oldest date first, newest at the bottom
    price_SMA, _, _ = moving_averages(df_price, duration, window)
    Price_σ = moving_std(df_price, duration, window)

    ################# Raw price data #################

    trace1 = PlotlyJS.scatter(;
        x = df_price[!, :Date][end-length(price_SMA)+1:end],
        y = df_price[!, 2][end-length(price_SMA)+1:end],
        mode = "markers+lines",
        name = "$(currencies[index]) price",
    )

    ################# SMA and Bollinger bands #################

    trace2 = PlotlyJS.scatter(;
        x = df_price[!, :Date][end-length(price_SMA)+1:end],
        y = price_SMA,
        mode = "lines",
        name = "$(names(df_price)[2]) SMA over $(window) days",
    )

    trace3 = PlotlyJS.scatter(;
        x = df_price[!, :Date][end-length(price_SMA)+1:end],
        y = price_SMA .+ 2 * Price_σ,
        mode = "markers",
        name = "Upper band (+2σ)",
    )

    trace4 = PlotlyJS.scatter(;
        x = df_price[!, :Date][end-length(price_SMA)+1:end],
        y = price_SMA .- 2 * Price_σ,
        mode = "markers",
        name = "Lower band (-2σ)",
    )

    return trace1, trace2, trace3, trace4
end

function plot_candle_vol_data(index::Int64,
                              duration::Int64,
                              key::String = KEY)

    # Retrieve data from various helper functions
    _, df_candle, df_vol = @mock get_price_data_single(currencies[index], key)

    # Make sure that duration does not exceed the number of rows in the DataFrame
    if duration > size(df_candle)[1]
        duration = size(df_candle)[1]
    end

    ################# Daily candlestick data #################
    open_col, high_col, low_col, close_col = [Float64[] for i = 1:4]

    for i = 1:duration
        push!(open_col, df_candle[!, 2][i][1])
        push!(high_col, df_candle[!, 2][i][2])
        push!(low_col, df_candle[!, 2][i][3])
        push!(close_col, df_candle[!, 2][i][4])
    end

    trace1 = PlotlyJS.candlestick(;
        x = df_candle[1:duration, :Date],
        open = open_col,
        high = high_col,
        low = low_col,
        close = close_col,
        name = "$(currencies[index])",
    )


    ################# Daily volume data #################
    trace2 = PlotlyJS.bar(;
        x = df_vol[1:duration, :Date],
        y = df_vol[1:duration, 2],
        name = "$(currencies[index]) volume",
    )

    return trace1, trace2
end

function plot_cumul_daily_return_hist(index::Int64,
                                      duration::Int64,
                                      key::String = KEY)

    # Retrieve data from various helper functions
    df_price, _, _ = @mock get_price_data_single(currencies[index], key)

    # Make sure that duration does not exceed the number of rows in the DataFrame
    if duration > size(df_price)[1]
        duration = size(df_price)[1]
    end

    # Reverse the order (oldest date first, newest at the bottom)
    sort!(df_price, :Date)

    ################# Cumulative return #################

    trace1 = PlotlyJS.scatter(;
        x = df_price[end-duration+2:end, :Date],
        y = (
            cumsum(diff(df_price[end-duration+1:end, 2])) ./ df_price[end-duration+1, 2]
        ) .* 100,
        mode = "markers+lines",
        name = "$(currencies[index]) cumulative return",
    )

    ################# Daily return #################

    X = df_price[end-duration+2:end, :Date]
    Y = (diff(df_price[end-duration+1:end, 2]) ./ df_price[end-duration+1:end-1, 2]) .* 100

    # Split into two datasets (green: positive change, red: negative change)
    green_Y = Y[Y.≥0.0]
    green_X = X[Y.≥0.0]

    red_Y = Y[Y.<0.0]
    red_X = X[Y.<0.0]

    green_share = round((length(green_Y) / length(Y)) * 100, digits = 2)
    red_share = 100.0 - green_share

    trace2_green = PlotlyJS.bar(;
        x = green_X,
        y = green_Y,
        marker_color = "green",
        name = "$(currencies[index]) increase, share = $(green_share) %",
    )
    trace2_red = PlotlyJS.bar(;
        x = red_X,
        y = red_Y,
        marker_color = "red",
        name = "$(currencies[index]) decrease, share = $(red_share) %",
    )

    ################# Daily change histogram / Daily volatility #################

    σ = round(std(Y), digits = 2)
    trace3 = plotly_hist(Y, 75; normalize = false)

    return trace1, trace2_green, trace2_red, trace3, σ, duration
end

function plotly_hist(
    x::AbstractVector{T},
    nbins::Integer;
    normalize::Bool = true,
) where {T<:Number}

    # use StatsBase to create a histogram object
    hist = StatsBase.fit(Histogram, x, nbins = nbins, closed = :left)

    # obtain bar positions -> center of each interval
    bins = similar(x, length(hist.edges[1]) - 1)
    edges = hist.edges[1]

    for k in eachindex(bins)
        bins[k] = (edges[k] + edges[k+1]) * 0.5
    end

    if normalize
        y = hist.weights ./ length(x) # we need a new array
    else
        y = hist.weights
    end

    trace = bar(x = bins, y = y)

    return trace
end

function plot_macd_signal(index::Int64,
                          duration::Int64,
                          key::String = KEY)

    # Retrieve data from various helper functions
    df_price, _, _ = @mock get_price_data_single(currencies[index], key)

    # Make sure that duration does not exceed the number of rows in the DataFrame
    if duration > size(df_price)[1]
        duration = size(df_price)[1]
    end

    sort!(df_price, :Date)                            # oldest date first, newest at the bottom

    df_price = df_price[end-duration+1-26-9+1:end, :] # filter based on selected duration and effective 
    # window size of 26+9

    df_ema_all = calculate_macd(df_price)             # get EMA and MACD data into a DataFrame


    ################# Daily average, EMA-12 and EMA-26 data #################
    trace1 = PlotlyJS.scatter(;
        x = df_ema_all[!, :date],
        y = df_ema_all[!, :Raw],
        mode = "markers+lines",
        name = "Daily average",
    )

    trace2 = PlotlyJS.scatter(;
        x = df_ema_all[!, :date],
        y = df_ema_all[!, :EMA_long],
        mode = "markers+lines",
        name = "EMA-26",
    )

    trace3 = PlotlyJS.scatter(;
        x = df_ema_all[!, :date],
        y = df_ema_all[!, :EMA_short],
        mode = "markers+lines",
        name = "EMA-12",
    )


    ################# MACD and its signal data #################
    trace4 = PlotlyJS.scatter(;
        x = df_ema_all[!, :date],
        y = df_ema_all[!, :MACD],
        mode = "markers+lines",
        name = "MACD",
    )

    trace5 = PlotlyJS.scatter(;
        x = df_ema_all[!, :date],
        y = df_ema_all[!, :Signal],
        mode = "markers+lines",
        name = "Signal (EMA-9)",
    )


    ################# Distance between MACD and its signal line #################

    X = df_ema_all[!, :date]
    Y = df_ema_all[!, :MACD] - df_ema_all[!, :Signal]

    # Split into two datasets (green: positive change, red: negative change)
    green_Y = Y[Y.≥0.0]
    green_X = X[Y.≥0.0]

    red_Y = Y[Y.<0.0]
    red_X = X[Y.<0.0]

    trace6_green = PlotlyJS.bar(;
        x = green_X,
        y = green_Y,
        marker_color = "green",
        name = "MACD above signal ",
    )

    trace6_red = PlotlyJS.bar(;
        x = red_X,
        y = red_Y,
        marker_color = "red",
        name = "MACD below signal",
    )

    return trace1, trace2, trace3, trace4, trace5, trace6_green, trace6_red

end

function plot_linear_regression(index::Int64,
                                duration::Int64,
                                key::String = KEY)

    # Retrieve data from various helper functions
    df_price, _, _ = @mock get_price_data_single(currencies[index], key)

    # Make sure that duration does not exceed the number of rows in the DataFrame
    if duration > size(df_price)[1]
        duration = size(df_price)[1]
    end

    # Filter on duration and create index column (model fit does not work with dates)	
    df_fit = sort!(df_price[1:duration, :])
    df_fit.Index = 1:size(df_fit)[1]

    # Rename column to price to make df_fit generic
    rename!(df_fit, Dict(Symbol(names(df_fit)[2]) => "Price"))

    # Get model parameters and R²
    model_params = lm(@formula(Price ~ Index), df_fit)
    R² = round(r2(model_params), digits = 2)

    # Predicted data
    price_from_model = Float64.(predict(model_params, df_fit))

    # Get standard deviation σ
    σ = std(price_from_model)

    ################# Raw price data #################

    trace1 = PlotlyJS.scatter(;
        x = df_fit[!, :Date],
        y = df_fit[!, :Price],
        mode = "markers+lines",
        name = "Actual price",
    )

    ################# Linear regression channel #################

    trace2 = PlotlyJS.scatter(;
        x = df_fit[!, :Date],
        y = price_from_model,
        mode = "lines",
        name = "Linear regression line",
    )

    trace3 = PlotlyJS.scatter(;
        x = df_fit[!, :Date],
        y = price_from_model .+ 2 * σ,
        mode = "markers",
        name = "Upper channel (+2σ)",
    )

    trace4 = PlotlyJS.scatter(;
        x = df_fit[!, :Date],
        y = price_from_model .- 2 * σ,
        mode = "markers",
        name = "Lower channel (-2σ)",
    )

    return trace1, trace2, trace3, trace4, R²
end