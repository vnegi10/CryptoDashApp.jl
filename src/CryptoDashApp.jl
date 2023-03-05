module CryptoDashApp

export run_app

using AlphaVantage,
      DataFrames,
      Dates,
      PlotlyJS,
      Dash,
      DashHtmlComponents,
      DashCoreComponents,
      CSV,
      Statistics,
      StatsBase,
      GLM,
      HTTP,
      JSON,
      DelimitedFiles

include("app.jl")

include("getdataAV.jl")
include("getdataCG.jl")

include("plotsAV.jl")
include("plotsCG.jl")

include("request.jl")
include("helpers.jl")

end # module