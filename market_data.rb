require 'open-uri'
require 'csv'
require 'mechanize'

ticker = 'GOOG'

agent = Mechanize.new
page = agent.get("http://finance.yahoo.com/q/hp?s=#{ticker}+Historical+Prices")

dl_csv = page.link_with(:text => 'Download to Spreadsheet').href

puts dl_csv

def read(url)
 CSV.new(open(url), :headers => :first_row).each do |line|
   puts " GOOG || #{line['Date']} || #{line['Close']} || #{line['Adj Close']} "
 end
end

read(dl_csv)