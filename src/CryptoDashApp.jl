module CryptoDashApp

export run_app

using AlphaVantage, DataFrames, Dates, PlotlyJS, Dash, DashHtmlComponents, DashCoreComponents, CSV, Statistics

include("CryptoFunctions.jl")
include("GetDataFunctions.jl")
include("PlotFunctions.jl")

# Parameters to interact with the web app
currencies = ["BTC", "ETH", "LTC", "BCH", "ETC", "ADA", "XTZ", "KNC", "LINK", "XRP", "ZEC", "DASH", "XLM", "XMR", "EOS"]
currencies_index = 1:length(currencies)
modes = ["Average price + Daily trade", "Candlestick + Volume", "FCAS data"]
modes_index = 1:length(modes)
durations = [7, 14, 30, 90, 180, 270, 365, 500, 750, 1000]
windows = [1, 5, 10, 30, 50, 75]

function run_app(port::Int64, key::String)

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
            style = (width = "50%", display = "inline-block", padding="2% 25%"),
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
        t1, t2, t3, t4, t5, t6, t7 = plot_price_vol_data(pair_ID, duration_ID, window_ID)
        
        if mode_ID == 1
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
            P1 = Plot([t1, t5, t6, t7], layout1) # plots daily average price and three diferent moving averages               
            P2 = Plot(t3, layout2)               # plots daily market cap
            return [P1 P2]
        elseif mode_ID == 2
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
            P1 = Plot(t4, layout1) # plots candlestick data
            P2 = Plot(t2, layout2) # plots daily volume
            return [P1 P2]
        elseif mode_ID == 3
            t8, fr = plot_fcas_data(pair_ID)
            layout1 = Layout(;title="FCAS metrics data for $(currencies[pair_ID]), overall rating = $(fr)",
                xaxis = attr(title="Type of metric", showgrid=true, zeroline=true),
                yaxis = attr(title="Score", showgrid=true, zeroline=true),
                height = 500,
                width = 1000,
                paper_bgcolor="white"            
            ) 
            P1 = Plot(t8, layout1)  # plots FCAS metrics
        end
    end

    # Allows access from a web browser, port can be changed, currently set to 8056
    run_server(app, "0.0.0.0", port)
end

end # module
