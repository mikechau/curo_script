# Full Nav Calc V.0.0.4
require 'date'

transactions = [
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 5.00, :acc_for => 'no'},
                {:date => '2011-04-17', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 5.00, :acc_for => 'no'},
                {:date => '2011-04-19', :action => "SELL", :ticker => "AAPL", :price => 10.00, :qty => 20.00, :acc_for => 'no'},
                {:date => '2011-04-22', :action => "SELL", :ticker => "AAPL", :price => 15.00, :qty => 5.00, :acc_for => 'no'},
                {:date => '2011-05-01', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 55.00, :acc_for => 'no'},
                {:date => '2011-05-02', :action => "BUY", :ticker => "AAPL", :price => 13.00, :qty => 55.00, :acc_for => 'no'},
                {:date => '2011-05-04', :action => "SELL", :ticker => "AAPL", :price => 13.00, :qty => 100.00, :acc_for => 'no'},
                {:date => '2011-05-04', :action => "SELL", :ticker => "AAPL", :price => 13.00, :qty => 10.00, :acc_for => 'no'},
                {:date => '2011-05-19', :action => "BUY", :ticker => "AAPL", :price => 100.00, :qty => 5000.00, :acc_for => 'no'},
                {:date => '2011-05-20', :action => "BUY", :ticker => "AAPL", :price => 101.00, :qty => 500.00, :acc_for => 'no'},
                {:date => '2011-05-25', :action => "SELL", :ticker => "AAPL", :price => 100.00, :qty => 500.00, :acc_for => 'no'},
                {:date => '2011-06-09', :action => "BUY", :ticker => "GOOG", :price => 100.00, :qty => 500.00, :acc_for => 'no'},
                {:date => '2011-06-12', :action => "SELL", :ticker => "GOOG", :price => 55.00, :qty => 100.00, :acc_for => 'no'}
               ]

eod_prices = [
              {:date => '2011-04-15', :ticker => 'AAPL', :eod_price => 9.00},
              {:date => '2011-04-16', :ticker => 'AAPL', :eod_price => 10.00},
              {:date => '2011-04-17', :ticker => 'AAPL', :eod_price => 11.00},
              {:date =>'2011-04-18', :ticker => 'AAPL', :eod_price => 12.00},
              {:date => '2011-04-19', :ticker => 'AAPL', :eod_price => 11.00},
              {:date => '2011-04-20', :ticker => 'AAPL', :eod_price => 13.00},
              {:date => '2011-04-21', :ticker => 'AAPL', :eod_price => 12.00},
              {:date => '2011-04-22', :ticker => 'AAPL', :eod_price => 14.00},
              {:date => '2011-05-01', :ticker => 'AAPL', :eod_price => 17.00},
              {:date => '2011-05-02', :ticker => 'AAPL', :eod_price => 19.00},
              {:date => '2011-05-03', :ticker => 'AAPL', :eod_price => 22.00},
              {:date => '2011-05-21', :ticker => 'AAPL', :eod_price => 31.00},
              {:date => '2011-06-04', :ticker => 'AAPL', :eod_price => 10.00},
              {:date => '2011-06-09', :ticker => 'AAPL', :eod_price => 10.00},
              {:date => '2011-06-09', :ticker => 'GOOG', :eod_price => 55.00},
              {:date => '2011-06-10', :ticker => 'GOOG', :eod_price => 100.00},
              {:date => '2011-06-11', :ticker => 'GOOG', :eod_price => 99.00},
              {:date => '2011-06-20', :ticker => 'GOOG', :eod_price => 604.00}
             ]

###### EMPTY ARRAYS ###### 

open_positions = []

market_status_array = []
trades_array = []
sells_log = []

###### Taking arrays to create a main array to work with ###### 

#loop through the transactions array
transactions.each_with_index do |trade,idx|

############# BUY CHECK
  if trade[:action] == 'BUY'

  # shovel the transactions hash without :acc_for hash into trades_array
  trades_array << {:date => trade[:date], :desc => trade[:action], :ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty], :order => 1}


  ###############################################
    #check if Buy exists in open_positions array, if not add to array
    if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:qty] > 0 && o[:date] == trade[:date] && o[:mark] == nil} 
      matching_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:mark] == nil}
      last_index = (matching_positions.count) - 1
      matching_positions[last_index][:qty] += trade[:qty]
      trade[:acc_for] = 'yes'
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
            pos[:mark] = 'yes'
          end
        end
      end
    end
  ###############################################

 ###############################################
    #check if the ticker exists in the market data table
    if eod_prices.any? {|t| t[:ticker] == trade[:ticker]}

      #finds the first sell date that has not been marked
      if transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}
        stop_date = transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}

        #set end_day to the SELL transaction that has not been marked by :acc_for
        end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date]) && Date.parse(t[:date]) < Date.parse(stop_date[:date])}

        #runs through the array pulled from .select and shovels into the market_status_array
        end_day.each do |history|
          market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price], :book_price => trade[:price], :qty => trade[:qty]}
        end

        # marks the SELL transaction :acc_for to 'yes'
        transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}[:acc_for] = 'yes'

      elsif transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == 'BUY'} && trade[:acc_for] == 'no'
        end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date])}
        
        end_day.each do |history|
          market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price], :book_price => trade[:price], :qty => trade[:qty]}
        end

      else
        puts "[EOD] - ERROR: #{trade}"
      end

    end
  ###############################################

############# SELL CHECK    
  elsif trade[:action] == 'SELL'

  ###############################################

    # if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:mark] != 'yes'}
    #   ops = open_positions.find {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:mark] != 'yes'}
    #   difference = ops[:qty] - trade[:qty]
    #   open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => ops[:price], :qty => difference, :sold => trade[:qty]}
    
    if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0 && o[:mark] != 'yes'}
      ops = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0 && o[:mark] != 'yes'}
      qty_sold = trade[:qty]
      ops.each do |op|
        if qty_sold > 0 && qty_sold >= op[:qty]
          remainder = qty_sold - op[:qty]
          op_decrease = qty_sold - remainder
          qty_subtracted = op[:qty] - op_decrease
          open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted, :sold => op_decrease, :log => 'SELL'}
          sells_log << {:date => trade[:date], :desc => 'SELL', :ticker => trade[:ticker], :price => op[:price], :qty => op_decrease, :sell_price => trade[:price]}
          qty_sold = remainder
        # elsif qty_sold > 0 && qty_sold < op[:qty]
        else
          qty_subtracted = op[:qty] - qty_sold
          open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted, :sold => qty_sold, :log => 'SELL'}
          sells_log << {:date => trade[:date], :desc => 'SELL', :ticker => trade[:ticker], :price => op[:price], :qty => qty_sold, :sell_price => trade[:price]}
          qty_sold = 0.0
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
            pos[:mark] = 'yes'
          end
        end
      end
    end     

  ###############################################

  else
    puts '[BUY/SELL] - ERROR: Action not BUY or SELL!'
  end

end

# puts '----OPEN POSITIONS---------'
# puts open_positions
# puts '----TRANSACTIONS---------'
# puts transactions
# puts '----MARKET STATUS--------'

# capture_tickers = transactions.uniq {|t| t[:ticker]}
market_log = market_status_array
# capture_tickers.each do |ticker|
#   symbol = ticker[:ticker]
#   clean_market_status = market_status_array.select {|m| m[:ticker] == symbol}
#   revised_market_array = clean_market_status.uniq {|c| c[:date]}

#   revised_market_array.each do |market|
#     market_log << market
#   end
# end

op_log = []

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
        if op_log.any? {|o| o[:ticker] == op[:ticker] && o[:price] == op[:price] && Date.parse(o[:date]) >= Date.parse(op[:date]) && o[:qty] == 0 && o[:mark] != 'yes'}
          end_day = op_log.find {|o| o[:ticker] == op[:ticker] && o[:price] == op[:price] && Date.parse(o[:date]) >= Date.parse(op[:date]) && o[:qty] == 0 && o[:mark] != 'yes'}
          find_mrkt = eod_prices.select {|o| o[:ticker] == op[:ticker] && Date.parse(o[:date]) >= Date.parse(op[:date]) && Date.parse(o[:date]) < Date.parse(end_day[:date])}
          find_mrkt.each_with_index do |mkt, idx2|
            puts "#{idx} || #{idx2} :: #{mkt[:date]} | #{mkt[:ticker]} | Mrkt Price: #{mkt[:eod_price]} | Book: #{op[:price]} | Qty: #{op[:qty]}"
          end
          end_day[:mark] = 'yes'
        else
          find_mrkt = eod_prices.select {|o| o[:ticker] == op[:ticker] && Date.parse(o[:date]) >= Date.parse(op[:date])}
          find_mrkt.each do |mkt, idx2|
            puts "#{idx} || #{idx2} :: #{mkt[:date]} | #{mkt[:ticker]} | Mrkt Price: #{mkt[:eod_price]} | Book: #{op[:price]} | Qty: #{op[:qty]}"
          end
        end
      end

        # stop_date = transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}

        # #set end_day to the SELL transaction that has not been marked by :acc_for
        # end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date]) && Date.parse(t[:date]) < Date.parse(stop_date[:date])}

        # #runs through the array pulled from .select and shovels into the market_status_array
        # end_day.each do |history|
        #   market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price], :book_price => trade[:price], :qty => trade[:qty]}

        #start_date = op[:date]
        #find_zero = op_log.find {|o| o[:ticker] == op[:ticker] && o[:book_price] == op[:book_price] && o[:qty] = 0}
      #   if market_status_array.any? {|m| m[:ticker] == op[:ticker] && m[:book_price] == op[:price]}
      #     market_data = market_status_array.select {|m| m[:ticker] == op[:ticker] && m[:book_price] == op[:price]  && Date.parse(m[:date]) >= Date.parse(op[:date])}
      #     puts "#{idx} :: #{op} :: [OP] - MARKET DATA"
      #     puts market_data
      #     # puts " #{idx} :: market: #{market_data[:date]} || #{op[:ticker]} || Market: #{market_data[:price]} || Book: #{market_data[:book_price]} || Qty: #{op[:qty]}"
      #     # market_data[:check] = 'yes'
      #       if idx == 10
      #         puts '-----------------------------------------WTF?'
      #         puts op
      #         puts market_status_array.select {|m| m[:ticker] == op[:ticker] && m[:book_price] == op[:price]  && Date.parse(m[:date]) >= Date.parse(op[:date])} == true
      #       end
      #   else
      #     puts "Not exactly working: #{op} - not working bro"
      #   end
      # else
      #   puts "#{idx}:: #{op}, ------------------------------------------------------------------------"
      # end
    end

    # puts '---signal test'
    # puts op_log
    # puts '---market test'
    # puts market_status_array

 ###############################################
    #check if the ticker exists in the market data table
    # if eod_prices.any? {|t| t[:ticker] == trade[:ticker]}

    #   #finds the first sell date that has not been marked
    #   if transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}
    #     stop_date = transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}

    #     #set end_day to the SELL transaction that has not been marked by :acc_for
    #     end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date]) && Date.parse(t[:date]) < Date.parse(stop_date[:date])}

    #     #runs through the array pulled from .select and shovels into the market_status_array
    #     end_day.each do |history|
    #       market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price], :book_price => trade[:price], :qty => trade[:qty]}
    #     end

    #     # marks the SELL transaction :acc_for to 'yes'
    #     transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}[:acc_for] = 'yes'

    #   elsif transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == 'BUY'} && trade[:acc_for] == 'no'
    #     end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date])}
        
    #     end_day.each do |history|
    #       market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price], :book_price => trade[:price], :qty => trade[:qty]}
    #     end

    #   else
    #     puts "[EOD] - ERROR: #{trade}"
    #   end

    # end
  ###############################################

  ###############################################


# op_market = []
# op_log.each do |op|
#   if market_log.any? {|m| m[:date] == op[:date]}
#     market_price = market_log.find {|m| m[:date] == op[:date]}
#     op_market << {:date => op[:date], :desc => 'MRKT', :ticker => op[:ticker], :price => market_price[:price], :qty => op[:qty]}
#     previous_mrkt_price = market_price[:price]
#     previous_op_qty = op[:qty]
#   else
#     op_market << {:date => op[:date], :desc => 'MRKT', :ticker => op[:ticker], :price => previous_mrkt_price, :qty => previous_op_qty}
#   end
# end

# puts 'begin'
# puts op_market
# puts 'end'

sells_log.each do |s|
  s[:order] = 3
end

market_log.each do |m|
  m[:order] = 5
end

trades_array += op_buy_log
trades_array += sells_log
trades_array += op_sell_log
trades_array += market_log

trades_array.sort! { |x, y| x[:date] == y[:date]? x[:order] <=> y[:order] : x[:date] <=> y[:date] }

#puts trades_array

negative_sells = trades_array.select {|t| t[:desc] == 'SELL'}
negative_sells.each do |trade|
  trade[:qty] *=-1
end

###### VARIABLES ###### 

nav_units = 1000.0
cash_balance = 2100000.0
stock_balance = 0.0
nav_per_unit = cash_balance / nav_units
market_stock_balance = 0.0

qty = 0.0

puts '============================================================================='
puts "Starting Cash Balance: #{cash_balance}"
puts "Starting Stock Balance: #{stock_balance}"
puts "Starting Net Asset Value Units: #{nav_units}"
puts "Starting NAV per Unit: #{nav_per_unit}"
puts '============================================================================='

trades_array.each_with_index do |trade, idx|
  # this is a buy or sell
  if trade[:qty] != nil && trade[:desc] == 'BUY'
    book_value = trade[:qty] * trade[:price] * -1
    cash_balance += book_value
    stock_balance += (book_value * -1)
    total_value = cash_balance + stock_balance
    puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Price: #{trade[:price]} || Qty: #{trade[:qty]} || Book Value: #{book_value} || Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance} || Total Value: #{total_value}"
  elsif trade[:qty] != nil && trade[:desc] == 'SELL'
    sell_value = trade[:qty] * trade[:sell_price] * -1
    cash_balance += sell_value
    stock_balance += (trade[:price] * -1)
    total_value = cash_balance + stock_balance
    puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Sell Price: #{trade[:sell_price]} || Qty: #{trade[:qty]} || Sell Value: #{sell_value} || Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance} || Total Value: #{total_value}"
  #this is market
  elsif trade[:qty] != nil && trade[:desc] == 'POS'
    pos_value = trade[:qty] * trade[:price] * -1
    total_value = cash_balance + stock_balance
    puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Price: #{trade[:price]} || Qty: #{trade[:qty]} || Value: #{pos_value} || Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance} || Total Value: #{total_value}"
  elsif trade[:desc] == 'MRKT'
    puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Price: #{trade[:price]}"
    puts "trade qty: #{trade[:qty]} || book val: #{trade[:book_price]}"
  end
end

puts '============================================================================='
puts 'Positions:'
op_log.each do |op|
  if op[:qty] > 0
    puts "#{op[:date]} || [#{op[:ticker]}] || Book Price: #{op[:price]} || Qty: #{op[:qty]}"
  else
    puts "#{op[:date]} || [#{op[:ticker]}] || Book Price: #{op[:price]} || Qty: #{op[:qty]} - [CLOSED]" 
  end
end