require_relative '../blackjack.rb'

def hand_builder *cards
  hand = []
  cards.each { | rank | hand << [rank, SUITS[Random.rand(4)]] }
  hand
end

describe "strategy" do

  before do

  end

  context "a dealer" do
    it "should :hit when hand is less than 17" do
      hand = hand_builder 5, 5, 5
      expect(dealer_strategy hand).to eq :hit
    end

    it "should :stand when hand is  17 or better" do
      hand = hand_builder 5, 5, 5, 5
      expect(dealer_strategy hand).to eq :stand
    end
  end

  context "a player" do
    it "should :hit 11 or less (can't bust)" do
      hand = hand_builder 5, 6
      expect(player_strategy hand, [2, 'Clubs']).to eq :hit
      expect(player_strategy hand, [3, 'Clubs']).to eq :hit
      expect(player_strategy hand, [6, 'Clubs']).to eq :hit
      expect(player_strategy hand, [7, 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :hit
    end

    it "should :hit on 12 when dealer has 2 or 3" do
      hand = hand_builder 5, 5, 2
      expect(player_strategy hand, [2, 'Clubs']).to eq :hit
      expect(player_strategy hand, [3, 'Clubs']).to eq :hit
    end

    it "should :stand when dealer has a :bust card (3..6)" do
      hand = hand_builder 5, 5, 2
      expect(player_strategy hand, [4, 'Clubs']).to eq :stand
      expect(player_strategy hand, [6, 'Clubs']).to eq :stand
    end

    it "should :hit on 16 or less when dealer has 7 or better" do
      hand = hand_builder 5, 5, 2
      expect(player_strategy hand, [7, 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :hit
      hand = hand_builder 5, 5, 6
      expect(player_strategy hand, [7, 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :hit
    end

    it "should :stand on 17 or better" do
      hand = hand_builder 5, 5, 7
      expect(player_strategy hand, [2, 'Clubs']).to eq :stand
      expect(player_strategy hand, [3, 'Clubs']).to eq :stand
      expect(player_strategy hand, [6, 'Clubs']).to eq :stand
      expect(player_strategy hand, [7, 'Clubs']).to eq :stand
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :stand
      hand = hand_builder 5, 5, 10
      expect(player_strategy hand, [2, 'Clubs']).to eq :stand
      expect(player_strategy hand, [3, 'Clubs']).to eq :stand
      expect(player_strategy hand, [6, 'Clubs']).to eq :stand
      expect(player_strategy hand, [7, 'Clubs']).to eq :stand
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :stand
    end
  end

  context "a player with an 'Ace'" do
    it "should :stand on 19 or better" do
      hand = hand_builder 8, 'Ace'
      expect(player_strategy hand, [2, 'Clubs']).to eq :stand
      expect(player_strategy hand, [6, 'Clubs']).to eq :stand
      expect(player_strategy hand, [7, 'Clubs']).to eq :stand
      expect(player_strategy hand, [9, 'Clubs']).to eq :stand
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :stand
    end

    it "should :stand on 18 when dealer has 2, 7 or 8" do
      hand = hand_builder 7, 'Ace'
      expect(player_strategy hand, [2, 'Clubs']).to eq :stand
      expect(player_strategy hand, [7, 'Clubs']).to eq :stand
      expect(player_strategy hand, [8, 'Clubs']).to eq :stand
    end

    it "should :hit on 18 when dealer dealer does not have 2, 7 or 8" do
      hand = hand_builder 7, 'Ace'
      expect(player_strategy hand, [3, 'Clubs']).to eq :hit
      expect(player_strategy hand, [6, 'Clubs']).to eq :hit
      expect(player_strategy hand, [9, 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :hit
    end

    it "should :hit on 17 or less" do
      hand = hand_builder 2, 'Ace'
      expect(player_strategy hand, [2, 'Clubs']).to eq :hit
      expect(player_strategy hand, [3, 'Clubs']).to eq :hit
      expect(player_strategy hand, [6, 'Clubs']).to eq :hit
      expect(player_strategy hand, [7, 'Clubs']).to eq :hit
      expect(player_strategy hand, [8, 'Clubs']).to eq :hit
      expect(player_strategy hand, [10, 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Jack', 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :hit
      hand = hand_builder 6, 'Ace'
      expect(player_strategy hand, [2, 'Clubs']).to eq :hit
      expect(player_strategy hand, [3, 'Clubs']).to eq :hit
      expect(player_strategy hand, [6, 'Clubs']).to eq :hit
      expect(player_strategy hand, [7, 'Clubs']).to eq :hit
      expect(player_strategy hand, [8, 'Clubs']).to eq :hit
      expect(player_strategy hand, [10, 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Jack', 'Clubs']).to eq :hit
      expect(player_strategy hand, ['Ace', 'Clubs']).to eq :hit
    end
  end

end

describe "simulation" do

  it "should run successfully" do
    total_games = 0
    total_wins = 0
    total_non_losses = 0
    for i in 1..10000 do
      losses, wins, pushes = game_simulation
#    puts "Player Wins: #{wins}, Pushes: #{pushes}, Dealer Wins: #{losses}"
      total_games += (losses + wins + pushes)
      total_wins += wins
      total_non_losses += (wins + pushes)
    end
#   puts "Player Wins: #{total_wins}, Non-losses: #{total_non_losses}, Dealer Wins: #{losses}"

    percent = total_wins / total_games.to_f * 100
    puts "\n  In #{total_games} games, Player wins #{"%0.2f" % percent}%"
    percent = total_non_losses / total_games.to_f * 100
    puts "     Player doesn't loose #{"%0.2f" %percent}%"
  end

end
