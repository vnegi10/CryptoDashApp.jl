# CryptoDashApp.jl

[![Build status (Github Actions)](https://github.com/vnegi10/CryptoDashApp.jl/workflows/CI/badge.svg)](https://github.com/vnegi10/CryptoDashApp.jl/actions)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://vnegi10.github.io/CryptoDashApp.jl/stable)

Interactive visualization of historical price (currently only in EUR), health metrics, candlestick
and volume data for various cryptocurrencies. Data are obtained via API queries to Alpha Vantage. 
The app is written in Julia and makes use of Dash.jl along with its react framework to generate a 
dashboard style view accessible via a browser. Different moving averages are also calculated and 
plotted along with the daily average price data. Averaging window can be selected by the user.

Functionality of the app will be extended in the future by adding more technical indicators. 
**Contributions are most welcome!**

## How to use?

** This package is currently not compatible with Julia 1.8 due to issues with its dependencies.**

This package is available via the General registry. Add it to your working Julia environment by
doing the following in the REPL:
* Press ']' to enter Pkg prompt

```julia
pkg> add CryptoDashApp
```   

Once all the packages are downloaded, you can make use of the **CryptoDashApp** module from the
REPL itself or within a script by executing:

```julia
julia> using CryptoDashApp
julia> run_app(8056, "your key") # where 8056 is the port
```  

Free API key can be obtained from [here.](https://www.alphavantage.co/support/#api-key)
    
Now, open a new tab in your browser and check if you can access http://0.0.0.0:8056/ or http://127.0.0.1:8056/

First plot will take a few seconds to appear, wait patiently! If you are running this app for the
first time, or on a different date, new data will be retrieved from Alpha Vantage, and then saved
to CSV files on disk. Keep in mind that the free API key imposes a limit of five calls/minute, 
which means you won't be able to load data for more than five currencies in quick succession. In 
case you see an error, wait for a while and then try again.

## App demo

<img src="https://media.giphy.com/media/gn6DV7p7Wbh15FdWMX/giphy.gif"/>

For better visual quality, visit this [link.](https://link.eu1.storjshare.io/s/juiaacgfta5f4o5p3zy4lxnn4ckq/videos/gifs/CryptoDashApp_demo_2022_06_19.gif)