using Pkg
Pkg.activate(pwd())

using CryptoDashApp
load_keys()
run_app(8010)