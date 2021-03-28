function plot_price_vol_data(index::Int64, duration::Int64, window::Int64)

    # Retrieve data from various helper functions    
    Price_df, Candle_df, Vol_df = get_price_data_single(currencies[index])    
        
    # Make sure that duration does not exceed the number of rows - max(windows) in the DataFrame
    # This allows calculation of MA for the longest duration
    if duration > size(Price_df)[1]-maximum(windows)
        duration = size(Price_df)[1]-maximum(windows)
    end

    ################# Daily average data #################
    trace1 = PlotlyJS.scatter(;x = Price_df[1:duration,:Date], y = Price_df[1:duration,2], mode="markers+lines", name = "$(currencies[index]) price")
    
    ################# Daily volume data #################
    trace2 = PlotlyJS.bar(;x = Vol_df[1:duration,:Date], y = Vol_df[1:duration,2], name = "$(currencies[index]) volume")

    ################# Daily candlestick data #################
    open_col = Array{Float64}(undef,0)
    high_col = Array{Float64}(undef,0)
    low_col = Array{Float64}(undef,0)
    close_col = Array{Float64}(undef,0)

    for i = 1:duration
        push!(open_col, Candle_df[!,2][i][1])
        push!(high_col, Candle_df[!,2][i][2])
        push!(low_col, Candle_df[!,2][i][3])
        push!(close_col, Candle_df[!,2][i][4])
    end

    trace3 = PlotlyJS.candlestick(; x = Candle_df[1:duration,:Date], open = open_col, high = high_col, low = low_col,
                                  close = close_col, name = "$(currencies[index])")

    ################# Moving averages data #################
    Price_df_rev, Price_SMA, Price_WMA, Price_EMA = moving_averages(Price_df, duration, window, currencies[index])

    trace4 = PlotlyJS.scatter(;x = Price_df_rev[!,:Date][end-length(Price_SMA)+1:end], y = Price_SMA, mode="lines", name = "$(names(Price_df)[2]) SMA over $(window) days")
    trace5 = PlotlyJS.scatter(;x = Price_df_rev[!,:Date][end-length(Price_WMA)+1:end], y = Price_WMA, mode="lines", name = "$(names(Price_df)[2]) WMA over $(window) days")
    trace6 = PlotlyJS.scatter(;x = Price_df_rev[!,:Date][end-length(Price_EMA)+1:end], y = Price_EMA, mode="lines", name = "$(names(Price_df)[2]) EMA over $(window) days")
    
    return trace1, trace2, trace3, trace4, trace5, trace6
end

function plot_fcas_data(index::Int64)

    us, fs, ds, ms, fr = get_ratings_data(currencies[index])

    ################# FCAS metrics data #################
    trace7 = PlotlyJS.bar(;x = ["Utility", "FCAS", "Developer", "Market maturity"], y = [us, fs, ds, ms], name = "Overall rating is $(fr)", width = 0.25)
    return trace7
end

