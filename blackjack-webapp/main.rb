require 'rubygems'
require 'sinatra'
require "sinatra/reloader"

set :sessions, true

helpers do
  def calculate_total cards
    arr = cards.map {|element| element[1]}

    total = 0
    arr.each do |rank|
      if rank == 'A'
        total += 11
      else
        total += rank.to_i == 0 ? 10 : rank.to_i
      end
    end

    arr.select { |element| element == 'A' }.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def card_image card
    suit = case card[0]
      when 'C' then 'clubs'
      when 'D' then 'diamonds'
      when 'H' then 'hearts'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'"
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
  suits = ['C', 'D', 'H', 'S']
  ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
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
  if player_total == 21
    @success = "#{session[:player_name]} hit Blackjack!"
    @show_hit_or_stay_button = false
  elsif calculate_total(session[:player_cards]) > 21
    @error = "Sorry, session[:player_name] busted!"
    @show_hit_or_stay_button = false
  end

  erb :game
end

post '/game/player/stay' do
  @success = "session[:player_name] has chosen to stay."

  erb :game
end