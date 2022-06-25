# Generate plots for CoinGecko data

function plot_dev_comm_data(index::Int64)

    # Convert currency symbol to lowercase and fetch data from CoinGecko
    df_dev, df_comm = get_dev_comm_data(lowercase(currencies[index]))

    ################# Developer data #################
    trace1 = PlotlyJS.bar(;
        x = df_dev[!, :Metric],
        y = df_dev[!, :Value],
        name = "Developer data",
    )

    ################# Community data #################
    trace2 = PlotlyJS.bar(;
        x = df_comm[!, :Metric],
        y = df_comm[!, :Value],
        name = "Community data",
    )

    return trace1, trace2
end

function plot_exchange_vol_data(index::Int64, num_exchanges::Int64 = 10)

    # Convert currency symbol to lowercase and fetch data from CoinGecko
    df_ex_vol = get_exchange_vol_data(lowercase(currencies[index]), num_exchanges)

    ################# Coin volume data #################
    trace1 = PlotlyJS.bar(;
        x = df_ex_vol[!, :Name],
        y = df_ex_vol[!, :Coin_volume],
        name = "Volume data in coins",
    )

    ################# USD volume data #################   
    trace2 = PlotlyJS.bar(;
        x = df_ex_vol[!, :Name],
        y = df_ex_vol[!, :USD_volume],
        name = "Volume data in USD",
    )

    return trace1, trace2
end

function plot_overall_vol_data(duration::Int64, num_exchanges::Int64 = 10)

    # Collect all traces for all exchanges
    all_traces = GenericTrace{Dict{Symbol,Any}}[]

    # Fetch overall volume data from CoinGecko for given historical duration
    df_ex_vol = get_overall_vol_data(duration, num_exchanges)

    if ~isempty(df_ex_vol)

        # First column is for duration
        exchanges = names(df_ex_vol)[2:end]

        for i = 1:length(exchanges)

            trace = PlotlyJS.bar(;
                x = df_ex_vol[!, :Time],
                y = df_ex_vol[!, i+1],
                mode = "markers+lines",
                name = "$(exchanges[i])",
            )

            push!(all_traces, trace)
        end
    end

    return all_traces
end