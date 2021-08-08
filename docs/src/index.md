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

### MACD + Signal
- Left plot shows the daily average price data along with 12-day and 26-day EMAs. These are used to calculate the Moving Average Convergence Divergence (MACD) indicator, which is shown on the right.

- Right plot shows the MACD (26-day EMA subtracted from 12-day EMA) along with its signal line (9-day EMA of the MACD). A buy signal occurs when MACD crosses the signal line from below, and a sell signal occurs when the crossing is from above. Distance between the MACD and the signal line is shown via bars in the same plot, with green bars (bullish momentum) indicating the region where MACD > signal, and red bars (bearish momentum) for the opposite. For more description, see [link.](https://www.investopedia.com/terms/m/macd.asp)

### Linear regression channel
- This metric can be used to identify trends and their direction. Plot shows a linear regression line that is the best fit to the data available for the selected duration. The **upper channel** line runs parallel to the linear regression line, and is located two standard deviations above it. Same goes for the **lower channel** line except that it's located two standard deviations below. 

- When the price drops below the lower channel, it is considered as a buy signal. Similarly, price rising above the upper channel leads to a sell signal. If the price spends time outside the channel, it could indicate that a trend reversal is imminent. 

- Plot title also contains $R^2$, which is a statistical measure representing the proportion of variation in the dependent variable that is explained by different features (independent variables) in this model. A value closer to 1 (maximum) indicates a good fit. The linear regression channel metric will therefore not be very useful when $R^2 < 0.50$.

### Fundamental Cryptocurrency Asset Score (FCAS) data
- This metric tells us about the market health of an asset. In the case of cryptocurrencies, they are user activity, developer behavior, and market maturity, which are provided by [Flipside Crypto](https://app.flipsidecrypto.com/tracker/all-coins).

## Run app
```@docs
run_app(port::Int64, key::String)
```






