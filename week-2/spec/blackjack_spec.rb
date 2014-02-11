require_relative '../blackjack.rb'

describe "Card" do
  before do
    @card1 = Card.new(2, :Hearts)
    @card2 = Card.new(:Ace, :Spades)
  end

  it "should create a valid card" do
    expect(@card1).to be_a_kind_of Card
    expect(@card2).to be_a_kind_of Card
  end

  it "should raise ArgumentError for invalid cards" do
    expect{ Card.new(1, :Hearts) }.to raise_error ArgumentError
    expect{ Card.new(:Ace, :fred) }.to raise_error ArgumentError
  end

  it "should return the card's rank" do
    expect(@card1.rank).to eq 2
    expect(@card2.rank).to eq :Ace
  end

  it "should return the card's suit" do
    expect(@card1.suit).to eq :Hearts
    expect(@card2.suit).to eq :Spades
  end
end

describe "Deck" do
  NUMBER_OF_DECKS = 2
  before do
    @deck = Deck.new(NUMBER_OF_DECKS)
  end

  it "should create a valid deck" do
    expect(@deck).to be_a_kind_of Deck
  end

  it "should count the number of cards" do
    expect(@deck.count).to eq (52 * NUMBER_OF_DECKS)
  end

  it "should shuffle a deck" do
    deck = @deck
    expect(@deck.shuffle).to_not eq  deck
  end

  it "should cut a deck" do
    deck = @deck
    expect(@deck.shuffle).to_not eq  deck
  end

  it "should draw a card" do
    card = @deck.draw
    expect(card).to be_a_kind_of Card
  end

  it "should report when deck is in reserve" do
    count = @deck.count
    while !@deck.in_reserve? do
      card = @deck.draw
    end
    expect(@deck.count).to be > 0
  end
end

describe "Hand" do
  before do
    @hand = Hand.new
  end

  it "should create a valid hand" do
    expect(@hand).to be_a_kind_of Hand
  end

  it "should count the number of cards" do
    expect(@hand.count).to eq (0)
  end

  it "should add cards to hand" do
    @hand.add_card Card.new(2, :Clubs)
    @hand.add_card Card.new(:Ace, :Clubs)
    expect(@hand.count).to eq (2)
  end

  it "should get a card" do
    @hand.add_card Card.new(2, :Clubs)
    @hand.add_card Card.new(:Ace, :Clubs)
    expect(@hand.card(1)).to eq (Card.new(:Ace, :Clubs))
  end

  it "should get a card's value" do
    @hand.add_card Card.new(2, :Clubs)
    @hand.add_card Card.new(:Ace, :Clubs)
    expect(@hand.card_value(0)).to eq 2
    expect(@hand.card_value(1)).to eq 11
  end

  it "should get a hand's value" do
    @hand.add_card Card.new(2, :Clubs)
    @hand.add_card Card.new(:Ace, :Clubs)
    expect(@hand.value).to eq (13)
  end

  it "should get an error" do
    @hand.add_card Card.new(2, :Clubs)
    expect{@hand.result}.to raise_error
  end

  it "should get a hand's result" do
    @hand.add_card Card.new(:Jack, :Clubs)
    @hand.add_card Card.new(:Ace, :Clubs)
    expect(@hand.result).to eq (:blackjack)
    @hand.add_card Card.new(10, :Clubs)
    expect(@hand.result).to eq (21)
    @hand.add_card Card.new(:Ace, :Clubs)
    expect(@hand.result).to eq (:bust)
  end

  it "should return true if hand contains a card" do
    @hand.add_card Card.new(2, :Clubs)
    @hand.add_card Card.new(:Ace, :Clubs)
    @hand.add_card Card.new(2, :Clubs)
    expect(@hand.contains? :Ace).to eq (true)
  end
end

describe "Dealer" do

  before do
    @dealer = Dealer.new
  end

  context "dealer strategy" do
    it "should :hit when hand is less than 17" do
      @dealer.hand_builder 5, 5, 5
      expect(@dealer.strategy).to eq :hit
    end

    it "should :stand when hand is  17 or better" do
      @dealer.hand_builder 5, 5, 5, 5
      expect(@dealer.strategy).to eq :stand
    end
  end
end

describe "Player" do

  before do
    @player = Player.new
    @dealer = Dealer.new
  end

  context "player strategy" do
    it "should :hit 11 or less (can't bust)" do
      @player.hand_builder 5, 6
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 6)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :hit
    end

    it "should :hit on 12 when dealer has 2 or 3" do
      @player.hand_builder 5, 5, 2
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :hit
    end

    it "should :stand when dealer has a :bust card (3..6)" do
      @player.hand_builder 5, 5, 2
      expect(@player.strategy @dealer.hand_builder(10, 4)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 6)).to eq :stand
      @player.hand_builder 5, 5, 3
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :stand
    end

    it "should :hit on 16 or less when dealer has 7 or better" do
      @player.hand_builder 5, 5, 2
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :hit
      @player.hand_builder 5, 5, 6
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :hit
    end

    it "should :stand on 17 or better" do
      @player.hand_builder 5, 5, 7
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 6)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :stand
      @player.hand_builder 5, 5, 10
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 6)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :stand
    end
  end

  context "player strategy with an :Ace" do
    it "should :stand on 19 or better" do
      @player.hand_builder 8, :Ace
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 6)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 9)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :stand
    end

    it "should :stand on 18 when dealer has 2, 7 or 8" do
      @player.hand_builder 7, :Ace
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :stand
      expect(@player.strategy @dealer.hand_builder(10, 8)).to eq :stand
    end

    it "should :hit on 18 when dealer dealer does not have 2, 7 or 8" do
      @player.hand_builder 7, :Ace
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 6)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 9)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :hit
    end

    it "should :hit on 17 or less" do
      @player.hand_builder 2, :Ace
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 4)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 8)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 10)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Jack)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :hit
      @player.hand_builder 6, :Ace
      expect(@player.strategy @dealer.hand_builder(10, 2)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 3)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 4)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 7)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 8)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, 10)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Jack)).to eq :hit
      expect(@player.strategy @dealer.hand_builder(10, :Ace)).to eq :hit
    end
  end

end

describe "Blackjack" do
NUMBER_OF_RUNS = 10000

  before do
    @game = Blackjack.new
  end

  context "game simulation" do
    it "should run successfully" do

      wins = 0
      pushes = 0
      total = 0

      (1..NUMBER_OF_RUNS).each do
        game = Blackjack.new
        game.simulation
        wins += game.wins
        pushes += game.pushes
        total += game.total
      end

      percent = wins / total.to_f * 100
      puts "\n    In #{total} games, Player wins #{"%0.2f" % percent}%"
      percent = (wins + pushes) / total.to_f * 100
      puts "       Player doesn't loose #{"%0.2f" %percent}%"
    end
  end

end
