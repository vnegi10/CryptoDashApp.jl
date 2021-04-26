function plot_price_ma_trade_data(index::Int64, duration::Int64, window::Int64)
    # Retrieve data from various helper functions    
    Price_df, _ , Vol_df = get_price_data_single(currencies[index])

    # Make sure that duration does not exceed the number of rows - max(windows) in the DataFrame
    # This allows calculation of MA for the longest duration
    if duration > size(Price_df)[1]-maximum(windows)
        duration = size(Price_df)[1]-maximum(windows)
    end

    ################# Daily average data #################
    trace1 = PlotlyJS.scatter(;x = Price_df[1:duration,:Date], y = Price_df[1:duration,2], mode="markers+lines", name = "$(currencies[index]) price")

    ################# Moving averages data #################
    sort!(Price_df, :Date) # oldest date first, newest at the bottom
    Price_SMA, Price_WMA, Price_EMA = moving_averages(Price_df, duration, window)

    trace2 = PlotlyJS.scatter(;x = Price_df[!,:Date][end-length(Price_SMA)+1:end], y = Price_SMA, mode="lines", name = "$(names(Price_df)[2]) SMA over $(window) days")
    trace3 = PlotlyJS.scatter(;x = Price_df[!,:Date][end-length(Price_WMA)+1:end], y = Price_WMA, mode="lines", name = "$(names(Price_df)[2]) WMA over $(window) days")
    trace4 = PlotlyJS.scatter(;x = Price_df[!,:Date][end-length(Price_EMA)+1:end], y = Price_EMA, mode="lines", name = "$(names(Price_df)[2]) EMA over $(window) days")

    ################# Daily trade data #################
    sort!(Price_df, :Date, rev = true) # newest date first, oldest at the bottom
    trace5 = PlotlyJS.bar(;x = Price_df[1:duration,:Date], y = Price_df[1:duration,2].*Vol_df[1:duration,2] , mode="markers+lines", name = "$(currencies[index]) daily trade")

    return trace1, trace2, trace3, trace4, trace5
end

function plot_candle_vol_data(index::Int64, duration::Int64)

    # Retrieve data from various helper functions    
    _ , Candle_df, Vol_df = get_price_data_single(currencies[index]) 

    # Make sure that duration does not exceed the number of rows in the DataFrame
    if duration > size(Candle_df)[1]
        duration = size(Candle_df)[1]
    end
    
    ################# Daily candlestick data #################
    open_col, high_col, low_col, close_col = [Float64[] for i = 1:4]

    for i = 1:duration
        push!(open_col, Candle_df[!,2][i][1])
        push!(high_col, Candle_df[!,2][i][2])
        push!(low_col, Candle_df[!,2][i][3])
        push!(close_col, Candle_df[!,2][i][4])
    end
 
    trace1 = PlotlyJS.candlestick(; x = Candle_df[1:duration,:Date], open = open_col, high = high_col, low = low_col,
                                   close = close_col, name = "$(currencies[index])")        
    
    
    ################# Daily volume data #################
    trace2 = PlotlyJS.bar(;x = Vol_df[1:duration,:Date], y = Vol_df[1:duration,2], name = "$(currencies[index]) volume")

    return trace1, trace2
end

function plot_cumul_daily_return_hist(index::Int64, duration::Int64)

    # Retrieve data from various helper functions    
    Price_df , _ , _ = get_price_data_single(currencies[index]) 

    # Make sure that duration does not exceed the number of rows in the DataFrame
    if duration > size(Price_df)[1]
        duration = size(Price_df)[1]
    end

    # Reverse the order (oldest date first, newest at the bottom)
    sort!(Price_df, :Date)     
    
    ################# Cumulative return #################

    trace1 = PlotlyJS.scatter(; x = Price_df[end-duration+2:end,:Date], y = (cumsum(diff(Price_df[end-duration+1:end,2])) ./ Price_df[end-duration+1, 2]) .* 100,
                                mode="markers+lines", name = "$(currencies[index]) cumulative return")
    
    ################# Daily return #################

    X = Price_df[end-duration+2:end,:Date]
    Y = (diff(Price_df[end-duration+1:end,2]) ./ Price_df[end-duration+1:end-1,2]) .* 100

    # Split into two datasets (green: positive change, red: negative change)

    green_X, red_X = [Date[] for i = 1:2]
    green_Y, red_Y = [Float64[] for i = 1:2]
    
    for i = 1:length(Y)
        if Y[i] ≥ 0.0
            push!(green_Y, Y[i])
            push!(green_X, X[i])
        else
            push!(red_Y, Y[i])
            push!(red_X, X[i])
        end
    end

    green_share = round((length(green_Y)/length(Y))*100, digits = 2)
    red_share = 100.0 - green_share

    trace2_green = PlotlyJS.bar(; x = green_X, y = green_Y, marker_color = "green", name = "$(currencies[index]) increase, share = $(green_share) %")
    trace2_red   = PlotlyJS.bar(; x = red_X, y = red_Y, marker_color = "red", name = "$(currencies[index]) decrease, share = $(red_share) %")
    
    ################# Daily change histogram / Daily volatility #################

    σ = round(std(Y), digits = 2)
    trace3 = plotly_hist(Y, 75; normalize = false)

    return trace1, trace2_green, trace2_red, trace3, σ, duration
end

function plotly_hist(x::AbstractVector{T}, nbins::Integer; normalize::Bool = true) where T <: Number

    # use StatsBase to create a histogram object
    hist = StatsBase.fit(Histogram, x, nbins = nbins, closed = :left)

    # obtain bar positions -> center of each interval
    bins = similar(x, length(hist.edges[1]) - 1)
    edges = hist.edges[1]

    for k in eachindex(bins)
        bins[k] = (edges[k] + edges[k + 1]) * 0.5
    end

    if normalize
        y = hist.weights ./ length(x) # we need a new array
    else
        y = hist.weights
    end

    trace = bar(x = bins, y = y)

    return trace
end

function plot_fcas_data(index::Int64)

    us, fs, ds, ms, fr = get_ratings_data(currencies[index])

    ################# FCAS metrics data #################
    trace1 = PlotlyJS.bar(;x = ["Utility", "FCAS", "Developer", "Market maturity"], y = [us, fs, ds, ms], width = 0.25)
    return trace1, fr
end

