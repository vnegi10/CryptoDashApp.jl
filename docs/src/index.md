# User Guide
---

## Overview
CryptoDashApp.jl creates a dashboard that allows the user to monitor historical cryptocurrency market data and calculate some key technical indicators. Data is obtained from Alpha Vantage for which an API key is necessary. Free API keys can be created [here.](https://www.alphavantage.co/support/#api-key)

Do note that the number of API calls are restricted to five per minute and 500 requests per day (more than enough for our app). We somewhat circumvent the former limitation by saving the data to the disk in the form of CSV files. Before downloading fresh data for a given date, older files are deleted.

## App UI
Data type and currency of interest can be selected via drop-down lists. Currently, data for only one currency can be viewed at a time. Averaging window (for calculating various moving averages) and historical timeframe can be selected via checkboxes.

The plots are interactive, which means you can hover your cursor over the data points to see their value, and also zoom into a particular region. There is also an option to download the plot as a png file. By clicking on the legends, you can turn off the display for that data, which is useful for example when you want to look at only a certain type of data.

## Available modes

### Average price + Daily trade
- Left plot shows the daily average price for a given currency. Averaging is done by taking the mean of open, close, high and low price for all days. When a moving average window other than 1-day is selected, the SMA (Simple Moving Average), WMA (Weighted Moving Average) and EMA (Exponential Moving Average) are also visible.

- Right plot shows the daily trade data, which is simply the product of volume (number of coins) multiplied by the average price.

### Candlestick + Volume
- Left plot shows the candlestick data for selected timeframe. 

- Right plot shows the daily volume (number of coins) for the selected timeframe.

### Cumulative + Daily return
- Left plot shows the cumulative return that will be obtained from a given starting date

- Right plot shows the daily return distribution. Green indicates an increase in price, whereas red indicates the opposite. Percentage share of green/red is also indicated in the legend.

### Daily volatility
- This plot shows the distribution of the daily price change for a given currency over the specified timeframe. A wider distribution (higher 3σ) indicates a more volatile behavior.

### Fundamental Cryptocurrency Asset Score (FCAS) data
- This metric tells us about the market health of an asset. In the case of cryptocurrencies, they are user activity, developer behavior, and market maturity, which are provided by [Flipside Crypto](https://app.flipsidecrypto.com/tracker/all-coins).

## Run app
```@docs
run_app(port::Int64, key::String)
```





