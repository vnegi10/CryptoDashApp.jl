################# Parameters to interact with the web app #################

currencies = ["BTC", "LTC", "BCH", "ETH", "KNC", "LINK", "ETC", "BNB", "ADA", "XTZ", "EOS", "XRP", "XLM", "ZEC", "DASH", "XMR", "DOT", "UNI"]
currencies_index = 1:length(currencies)
modes = ["Average price + Daily trade", "Candlestick + Volume", "Cumulative + Daily return", "Daily volatility", "FCAS data"]
modes_index = 1:length(modes)
durations = [7, 14, 30, 90, 180, 270, 365, 500, 750, 1000]
windows = [1, 5, 10, 30, 50, 75, 100]


################# Run the app #################

function run_app(port::Int64, key::String)

    # Check if "data" folder exists, if not, create a new one
    if isdir("data")
        @info "data folder exists, cleanup action will be performed!"
    else
        mkdir("data")
        @info "New data folder has been created"
    end

    # Cleanup csv files from previous days
    try
        main_dir = pwd()
        cd("data")
        files = readdir()
        rx1 = r"data"
        rx2 = r".csv"
        for file in files
            ts = Dates.unix2datetime(stat(file).mtime)
            file_date = Date(ts)
            if file_date != Dates.today() && occursin(rx1, file) && occursin(rx2, file)
                rm(file)
            end
        end
        cd(main_dir)    
    catch
        println("Unable to perform cleanup action")
    end

    # Set API key
    AlphaVantage.global_key!(key)
        
    # UI part of the tool
    app = dash()

    app.layout = html_div() do
        html_h1("Crypto Dashboard",
                style= (
                textAlign = "center",
                )
        ),
        html_div(
            children = [
                dcc_dropdown(
                    id = "mode_ID",
                    options = [
                        (label = "$(modes[i])", value = i) for i in modes_index
                    ],
                    value = 1,
                ),
                dcc_dropdown(
                    id = "pair_ID",
                    options = [
                        (label = "$(currencies[i])", value = i) for i in currencies_index
                    ],
                    value = 1,
                ),
                dcc_radioitems(
                    id = "window_ID",
                    options = [(label = "$(i)-day", value = i) for i in windows],
                    value = 1,
                ),
                dcc_radioitems(
                    id = "duration_ID",
                    options = [(label = "$(i)d", value = i) for i in durations],
                    value = 7,
                ),
            ],
            style = (width = "50%", display = "inline-block", padding="5% 25%"),
        ),
        
        html_div(style = (width="100%", display="inline-block", padding="2% 25%")) do
            dcc_graph(id = "graph")
        end
    end

    callback!(
        app,
        Output("graph", "figure"),
        Input("mode_ID", "value"),
        Input("pair_ID", "value"), 
        Input("window_ID", "value"),
        Input("duration_ID", "value"),
    ) do mode_ID, pair_ID, window_ID, duration_ID
                
        if mode_ID == 1
            t1, t2, t3, t4, t5 = plot_price_ma_trade_data(pair_ID, duration_ID, window_ID)

            layout1 = Layout(;title="Daily average price data for $(currencies[pair_ID])",
                xaxis = attr(title="Time", showgrid=true, zeroline=true, linewidth=1.0),
                yaxis = attr(title="Price [euros]", showgrid=true, zeroline=true, linewidth=1.0),
                height = 500,
                width = 1000,
                paper_bgcolor="white"            
            )  
            layout2 = Layout(;title="Daily trade data (volume x price) for $(currencies[pair_ID])",
                xaxis = attr(title="Time", showgrid=true, zeroline=true, linewidth=1.0),
                yaxis = attr(title="Daily trade [euros]", showgrid=true, zeroline=true, linewidth=1.0),
                height = 500,
                width = 1000,
                paper_bgcolor="white"            
            ) 
            P1 = Plot([t1, t2, t3, t4], layout1) # plots daily average price and three diferent moving averages               
            P2 = Plot(t5, layout2)               # plots daily market cap
            return [P1 P2]

        elseif mode_ID == 2
            t1, t2 = plot_candle_vol_data(pair_ID, duration_ID)

            layout1 = Layout(;title="Candlestick data for $(currencies[pair_ID])",
                xaxis=attr(title="Time", showgrid=true, zeroline=true),
                yaxis=attr(title="Price [euros]", zeroline=true),
                height = 500,
                width = 1000,
            )
            layout2 = Layout(;title="Daily volume data for $(currencies[pair_ID])",
                xaxis=attr(title="Time", showgrid=true, zeroline=true),
                yaxis=attr(title="Volume [Number of coins]", zeroline=true),
                height = 100,
                width = 200
            )
            P1 = Plot(t1, layout1) # plots candlestick data
            P2 = Plot(t2, layout2) # plots daily volume
            return [P1 P2]
        
        elseif mode_ID == 3
            t1, t2_green, t2_red, _ , _ , _ = plot_cumul_daily_return_hist(pair_ID, duration_ID)

            layout1 = Layout(;title="Cumulative return for $(currencies[pair_ID])",
                xaxis=attr(title="Time", showgrid=true, zeroline=true),
                yaxis=attr(title="Return [in %]", zeroline=true),
                height = 500,
                width = 1000,
            )
            layout2 = Layout(;title="Daily return for $(currencies[pair_ID])",
                xaxis=attr(title="Time", showgrid=true, zeroline=true),
                yaxis=attr(title="Return [in %]", zeroline=true),
                height = 500,
                width = 1000,
                barmode = "group",
            )

            P1 = Plot(t1, layout1)                 # plots cumulative return %
            P2 = Plot([t2_green, t2_red], layout2) # plots daily change %
            return [P1 P2]

        elseif mode_ID == 4
            _ , _ , _ , t1 , σ, duration = plot_cumul_daily_return_hist(pair_ID, duration_ID)

            layout1 = Layout(;title="Distribution of daily price change for $(currencies[pair_ID]) over $(duration) days, 3σ = $(round(3*σ, digits = 2)) %",
                xaxis=attr(title="Change [in %]", showgrid=true, zeroline=true),
                yaxis=attr(title="Number of counts", zeroline=true),
                height = 500,
                width = 1000,
            )

            P1 = Plot(t1, layout1)      # plots histogram of daily price change
            return [P1]

        elseif mode_ID == 5
            t1, fr = plot_fcas_data(pair_ID)
            layout1 = Layout(;title="FCAS metrics data for $(currencies[pair_ID]), overall rating = $(fr)",
                xaxis = attr(title="Type of metric", showgrid=true, zeroline=true),
                yaxis = attr(title="Score", showgrid=true, zeroline=true),
                height = 500,
                width = 1000,
                paper_bgcolor="white"            
            ) 
            P1 = Plot(t1, layout1)  # plots FCAS metrics
        end
    end

    # Allows access from a web browser, port can be changed, currently set to 8056
    run_server(app, "0.0.0.0", port)
end