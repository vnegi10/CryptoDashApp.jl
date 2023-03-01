module CryptoDashApp

export run_app

using AlphaVantage, DataFrames, Dates, PlotlyJS, Dash, CSV,
      Statistics, StatsBase, GLM, HTTP, JSON, Query,
      DelimitedFiles

include("app.jl")

include("getdataAV.jl")
include("getdataCG.jl")

include("plotsAV.jl")
include("plotsCG.jl")

include("helper.jl")

end # module