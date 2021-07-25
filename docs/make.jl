using Documenter
using CryptoDashApp

makedocs(
    sitename = "CryptoDashApp.jl",
    format = Documenter.HTML(),
    modules = [CryptoDashApp]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/vnegi10/CryptoDashApp.jl.git",
    devbranch = "main"
)
