require 'open-uri'
require 'csv'
require 'mechanize'

#################################################################################
# Collect End of Day Market Prices

ticker = 'GOOG'

agent = Mechanize.new
page = agent.get("http://finance.yahoo.com/q/hp?s=#{ticker}+Historical+Prices")

dl_csv = page.link_with(:text => 'Download to Spreadsheet').href

puts dl_csv

def read(url, ticker)
 CSV.new(open(url), :headers => :first_row).each do |line|
   puts " #{ticker} || #{line['Date']} || #{line['Close']} || #{line['Adj Close']} "
 end
end

read(dl_csv, ticker)

#################################################################################

# Collect Current Market Prices

tickers = ["GOOG", "AAPL", "NOK"]
plus = '+'

ticker_string = ''

tickers.each_with_index do |ticker, idx|
  ticker_string = ticker_string.concat(ticker.to_s)
  if idx < tickers.count-1
    ticker_string = ticker_string+plus
  end
end


url = "http://finance.yahoo.com/d/quotes.csv?s=#{ticker_string}&f=sd1t1l1"

 CSV.new(open(url)).each do |line|
   puts "#{line[0]}|| #{line[1]} || #{line[2]} || #{line[3]}"
 end

# s = symbol
# n = name
# l1 = Last Trade (Price Only)
# d1 = Last Trade Date
# t1 = Last Trade Time
# o = open
# h = Day's High
# g = Day's Low
# d = Dividend/Share
# r = P/E Ratio