require 'rubygems'
require 'sinatra'
# require "sinatra/reloader"

set :sessions, true

BLACKJACK = 21

helpers do
  def calculate_total cards
    arr = cards.map {|element| element[1]}

    total = 0
    arr.each do |rank|
      if rank == 'Ace'
        total += 11
      else
        total += rank.to_i == 0 ? 10 : rank.to_i
      end
    end

    arr.select { |element| element == 'Ace' }.count.times do
      break if total <= BLACKJACK
      total -= 10
    end

    total
  end

  def card_image card
    "<img src='/images/cards/#{card[0].downcase}_#{card[1].downcase}.jpg' class='card_image'>"
  end

  def winner! msg
    @play_again = true
    @show_hit_or_stay_button = false
    @success = "<strong>#{session[:player_name]} won!</strong> #{msg}"
  end

  def loser! msg
    @play_again = true
    @show_hit_or_stay_button = false
    @error = "<strong>#{session[:player_name]} loses</strong> #{msg}"
  end

  def tie! msg
    @play_again = true
    @show_hit_or_stay_button = false
    @success = "<strong>It's a tie!</strong> #{msg}"
  end
end

before do
  @show_hit_or_stay_button = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  elsif
    redirect :new_player
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:turn] = session[:player_name]

  suits = ['Clubs', 'Diamonds', 'Hearts', 'Spades']
  ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
  session[:deck] = suits.product(ranks).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK
    winner!("You hit Blackjack!")
  elsif calculate_total(session[:player_cards]) > BLACKJACK
    loser!("You busted!")
  end

  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."

  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = 'dealer'

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK
    loser!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK
    winner!("Dealer busted!")
  elsif dealer_total >=17
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true

  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_button = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total > dealer_total
    winner!("You stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
  elsif player_total < dealer_total
    loser!("You stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
  else
    tie!("You and the dealer stayed at #{player_total}.")
  end

  erb :game
end

get '/game_over' do
  session.clear
  erb :game_over
end
