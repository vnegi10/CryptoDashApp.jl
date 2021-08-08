module CryptoDashApp

export run_app

using AlphaVantage, DataFrames, Dates, PlotlyJS, Dash, DashHtmlComponents, 
      DashCoreComponents, CSV, Statistics, StatsBase, GLM

include("CryptoFunctions.jl")
include("GetDataFunctions.jl")
include("PlotFunctions.jl")
include("ConfigureApp.jl")

end # module
