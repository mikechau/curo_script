# Full Nav Calc V.0.0.4
require 'date'

transactions = [
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.0, :qty => 15.0},
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.0, :qty => 15.0},
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 12.0, :qty => 5.0},
                {:date => '2011-04-17', :action => "BUY", :ticker => "AAPL", :price => 12.0, :qty => 5.0},
                {:date => '2011-04-19', :action => "SELL", :ticker => "AAPL", :price => 10.0, :qty => 20.0},
                {:date => '2011-04-22', :action => "SELL", :ticker => "AAPL", :price => 15.0, :qty => 5.0},
                {:date => '2011-05-01', :action => "BUY", :ticker => "AAPL", :price => 12.0, :qty => 55.0},
                {:date => '2011-05-02', :action => "BUY", :ticker => "AAPL", :price => 13.0, :qty => 55.0},
                {:date => '2011-05-04', :action => "SELL", :ticker => "AAPL", :price => 13.0, :qty => 100.0},
                {:date => '2011-05-04', :action => "SELL", :ticker => "AAPL", :price => 13.0, :qty => 10.0},
                {:date => '2011-05-19', :action => "BUY", :ticker => "AAPL", :price => 100.0, :qty => 5000.0},
                {:date => '2011-05-20', :action => "BUY", :ticker => "AAPL", :price => 101.0, :qty => 500.0},
                {:date => '2011-05-25', :action => "SELL", :ticker => "AAPL", :price => 100.0, :qty => 500.0},
                {:date => '2011-06-09', :action => "BUY", :ticker => "GOOG", :price => 100.0, :qty => 500.0},
                {:date => '2011-06-12', :action => "SELL", :ticker => "GOOG", :price => 55.0, :qty => 100.0}
               ]

eod_prices = [
              {:date => '2011-04-15', :ticker => 'AAPL', :eod_price => 9.0},
              {:date => '2011-04-16', :ticker => 'AAPL', :eod_price => 10.0},
              {:date => '2011-04-17', :ticker => 'AAPL', :eod_price => 11.0},
              {:date =>'2011-04-18', :ticker => 'AAPL', :eod_price => 12.0},
              {:date => '2011-04-19', :ticker => 'AAPL', :eod_price => 11.0},
              {:date => '2011-04-20', :ticker => 'AAPL', :eod_price => 13.0},
              {:date => '2011-04-21', :ticker => 'AAPL', :eod_price => 12.0},
              {:date => '2011-04-22', :ticker => 'AAPL', :eod_price => 14.0},
              {:date => '2011-05-01', :ticker => 'AAPL', :eod_price => 17.0},
              {:date => '2011-05-02', :ticker => 'AAPL', :eod_price => 19.0},
              {:date => '2011-05-03', :ticker => 'AAPL', :eod_price => 22.0},
              {:date => '2011-05-04', :ticker => 'AAPL', :eod_price => 22.0},
              {:date => '2011-05-05', :ticker => 'AAPL', :eod_price => 22.0},
              {:date => '2011-05-06', :ticker => 'AAPL', :eod_price => 22.0},
              {:date => '2011-05-21', :ticker => 'AAPL', :eod_price => 31.0},
              {:date => '2011-05-22', :ticker => 'AAPL', :eod_price => 31.0},
              {:date => '2011-06-04', :ticker => 'AAPL', :eod_price => 10.0},
              {:date => '2011-06-09', :ticker => 'AAPL', :eod_price => 10.0},
              {:date => '2011-06-09', :ticker => 'GOOG', :eod_price => 55.0},
              {:date => '2011-06-10', :ticker => 'GOOG', :eod_price => 100.0},
              {:date => '2011-06-11', :ticker => 'GOOG', :eod_price => 99.0},
              {:date => '2011-06-20', :ticker => 'GOOG', :eod_price => 604.0}
             ]

###### EMPTY ARRAYS ###### 

open_positions = []

trades_array = []
sells_log = []

###### Taking arrays to create a main array to work with ###### 

#loop through the transactions array
transactions.each_with_index do |trade,idx|

############# BUY CHECK
  if trade[:action] == 'BUY'

  # shovel the transactions hash into trades_array
  trades_array << {:date => trade[:date], :desc => trade[:action], :ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty]}

  ###############################################

    #check if Buy exists in open_positions array, if not add to array
    if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:qty] > 0 && o[:date] == trade[:date] && o[:mark] != true} 
      matching_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:mark] != true}
      last_index = (matching_positions.count) - 1
      matching_positions[last_index][:qty] += trade[:qty]
    else
      open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty], :log => 'BUY'}
        if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && Date.parse(o[:date]) < Date.parse(trade[:date])}
          matching_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && Date.parse(o[:date]) < Date.parse(trade[:date])}
          last_index = (matching_positions.count) - 1
          add_previous_qty = matching_positions[last_index][:qty]
          last_position = (open_positions.count) - 1
          open_positions[last_position][:qty] += add_previous_qty
        end
    end

    unique_prices = transactions.select {|o| o[:ticker] == trade[:ticker]}.uniq! {|t| t[:price]}
    if unique_prices != nil
      unique_prices.each_with_index do |uq, idx|
        check_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == uq[:price]}
        check_pos_count = check_positions.count - 1
        check_positions.each_with_index do |pos, idx|
          if idx < check_pos_count
            pos[:mark] = true
          end
        end
      end
    end
  ###############################################

############# SELL CHECK    
  elsif trade[:action] == 'SELL'

  ###############################################
    
    if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0 && o[:mark] != true}
      ops = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0 && o[:mark] != true}
      qty_sold = trade[:qty]
      ops.each do |op|
        if qty_sold > 0 && qty_sold >= op[:qty]
          remainder = qty_sold - op[:qty]
          op_decrease = qty_sold - remainder
          qty_subtracted = op[:qty] - op_decrease
          open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted, :sold => op_decrease, :log => 'SELL'}
          sells_log << {:date => trade[:date], :desc => 'SELL', :ticker => trade[:ticker], :price => op[:price], :qty => op_decrease, :sell_price => trade[:price]}
          qty_sold = remainder
        elsif qty_sold > 0 && qty_sold < op[:qty]
          qty_subtracted = op[:qty] - qty_sold
          open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted, :sold => qty_sold, :log => 'SELL'}
          sells_log << {:date => trade[:date], :desc => 'SELL', :ticker => trade[:ticker], :price => op[:price], :qty => qty_sold, :sell_price => trade[:price]}
          break
        else
          puts "ERROR with qty_sold if: #{op} :: #{trade} :: #{qty_sold}"
        end 
      end
    end

    unique_prices = transactions.select {|o| o[:ticker] == trade[:ticker]}.uniq! {|t| t[:price]}
    if unique_prices != nil
      unique_prices.each_with_index do |uq, idx|
        check_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == uq[:price]}
        check_pos_count = check_positions.count - 1
        check_positions.each_with_index do |pos, idx|
          if idx < check_pos_count
            pos[:mark] = true
          end
        end
      end
    end     

  ###############################################

  else
    puts '[BUY/SELL] - ERROR: Action not BUY or SELL!'
  end

end

op_log = []
market_log = []

op_buy_log = []
op_buy = open_positions.select {|o| o[:log] == 'BUY'}
op_buy.each do |op|
  op_buy_log << {:date => op[:date], :desc => 'POS', :ticker => op[:ticker], :price => op[:price], :qty => op[:qty], :order => 2}
  op_log << {:date => op[:date], :ticker => op[:ticker], :price => op[:price], :qty => op[:qty]}
end

op_sell_log = []
op_sell = open_positions.select {|o| o[:log] == 'SELL'}
op_sell.each do |op|
  op_sell_log << {:date => op[:date], :desc => 'POS', :ticker => op[:ticker], :price => op[:price], :qty => op[:qty], :order => 4}
  op_log << {:date => op[:date], :ticker => op[:ticker], :price => op[:price], :qty => op[:qty]}
end

 ###############################################

op_log.each_with_index do |op, idx|
  if op[:qty] > 0
    start_date = op[:date]
    if op_log.any? {|o| o[:ticker] == op[:ticker] && o[:price] == op[:price] && Date.parse(o[:date]) >= Date.parse(op[:date]) && o[:qty] == 0 && o[:mark] != true}
      end_day = op_log.find {|o| o[:ticker] == op[:ticker] && o[:price] == op[:price] && Date.parse(o[:date]) >= Date.parse(op[:date]) && o[:qty] == 0 && o[:mark] != true}
      find_mrkt = eod_prices.select {|o| o[:ticker] == op[:ticker] && Date.parse(o[:date]) >= Date.parse(op[:date]) && Date.parse(o[:date]) < Date.parse(end_day[:date])}
      find_mrkt.each do |mkt|
        #puts "#{idx} :: #{mkt[:date]} | #{mkt[:ticker]} | Mrkt Price: #{mkt[:eod_price]} | Book: #{op[:price]} | Qty: #{op[:qty]}"
        market_log << {:date => mkt[:date], :desc => 'MRKT', :ticker => mkt[:ticker], :price => mkt[:eod_price], :qty => op[:qty], :book_price => op[:price]}
      end
      end_day[:mark] = true
    else
      find_mrkt = eod_prices.select {|o| o[:ticker] == op[:ticker] && Date.parse(o[:date]) >= Date.parse(op[:date])}
      find_mrkt.each do |mkt|
        #puts "#{idx} :: #{mkt[:date]} | #{mkt[:ticker]} | Mrkt Price: #{mkt[:eod_price]} | Book: #{op[:price]} | Qty: #{op[:qty]}"
        market_log << {:date => mkt[:date], :desc => 'MRKT', :ticker => mkt[:ticker], :price => mkt[:eod_price], :qty => op[:qty], :book_price => op[:price]}
      end
    end
  end
end

  ###############################################

trades_array += sells_log
trades_array += (market_log.uniq!)

trades_array.sort! { |x, y| Date.parse(x[:date]) <=> Date.parse(y[:date])}

negative_sells = trades_array.select {|t| t[:desc] == 'SELL'}
negative_sells.each do |trade|
  trade[:qty] *=-1
end

###### VARIABLES ###### 

nav_units = 1000.0
initial_cash_balance = 2100000.0
cash_balance = initial_cash_balance
stock_balance = 0.0
nav_per_unit = cash_balance / nav_units
market_stock_balance = 0.0

trades_count = trades_array.count
qty = 0.0
portfolio = []

puts '============================================================================='
puts "Starting: Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance}"
puts "Starting Net Asset Value Units: #{nav_units} ||  NAV per Unit: #{nav_per_unit}"
puts '============================================================================='

single_dash = '----------------------------------------------------------------------------------------------------'

trades_array.each_with_index do |trade, idx|
puts single_dash
  if trade[:desc] == 'BUY'
    book_value = trade[:qty] * trade[:price] * -1
    cash_balance += book_value
    stock_balance += (book_value * -1)
    total_value = cash_balance + stock_balance
    puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Book Price: #{trade[:price]} || Qty: #{trade[:qty]} || Book Value: #{book_value}"
    puts "     Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance} || Total Value: #{total_value}"

  elsif trade[:desc] == 'SELL'
    sell_value = trade[:qty] * trade[:sell_price] * -1
    cash_balance += sell_value
    stock_balance += (trade[:price] * -1)
    total_value = cash_balance + stock_balance
    puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Sell Price: #{trade[:sell_price]} || Qty: #{trade[:qty]} || Sell Value: #{sell_value}"
    book_value = trade[:price] * trade[:qty]
    puts "     Book Price: #{trade[:price]} || Book Value: #{book_value}"
    profit = sell_value - book_value
    profit_percent = ((profit) / book_value) * 100
    puts "     Profit: #{profit} || Profit %: #{profit_percent}%"
    puts "     Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance} || Total Value: #{total_value}"

  elsif trade[:desc] == 'MRKT'
    book_value = trade[:book_price] * trade[:qty]
    mrkt_value = trade[:qty] * trade[:price]
    mrkt_difference = mrkt_value - book_value
    stock_balance += mrkt_difference
    total_value = cash_balance + stock_balance
    puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Market Price: #{trade[:price]} || Qty: #{trade[:qty]}"
    puts "     Book Price: #{trade[:book_price]} || Book Value: #{book_value}"
    stock_change = mrkt_value - book_value
    stock_change_percent = ((stock_change) / book_value) * 100
    puts "     Stock Change: #{stock_change} || Stock Change %: #{stock_change_percent}"
    puts "     Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance} || Total Value: #{total_value}"
  end

  if idx == trades_count - 1
    portfolio = [total_value - initial_cash_balance, ((total_value - initial_cash_balance) / initial_cash_balance) * 100]
  end

end

puts single_dash

puts ''
puts 'PORTFOLIO STATUS:'
puts "Total Value Change: $#{portfolio[0]} || Return: #{portfolio[1]}%"
puts ''

puts '============================================================================='
puts 'Positions:'
op_log.sort! { |x, y| Date.parse(x[:date]) <=> Date.parse(y[:date])}.each do |op|
  if op[:qty] > 0
    puts "#{op[:date]} || [#{op[:ticker]}] || Book Price: #{op[:price]} || Qty: #{op[:qty]}"
  else
    puts "#{op[:date]} || [#{op[:ticker]}] || Book Price: #{op[:price]} || Qty: #{op[:qty]} - [CLOSED]" 
  end
end
