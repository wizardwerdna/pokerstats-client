require 'rubygems'
require 'activeresource'
require 'activesupport'
require 'pokerstats/pokerstars_file'

class MyLogger
  def info string
    puts string
  end
end
ActiveResource::Base.logger=MyLogger.new
require '../../lib/pokerstats-client/rational_poker'
rational_poker = PokerstatsClient::RationalPoker.new("wizardwerdna", "123123")
# puts `whoami`
# session = rational_poker.sessions.first
# puts rational_poker.hands(session).size
puts "/Users/#{`whoami`.chomp}/Library/Application Support/PokerStars/HandHistory/**/*.txt"
Dir["/Users/#{`whoami`.chomp}/Library/Application Support/PokerStars/HandHistory/**/*.txt"].each do |file|
  session = PokerstatsClient::RationalPoker::PokerSession.find_or_create_by_name(file, :description => "upload from computer")
  games = PokerstatsClient::RationalPoker::HandText.games(session).inspect
  Pokerstats::PokerstarsFile.open(file) do |pokerstarsfile|
    pokerstarsfile.each do |hand_record|
      if games.include? hand_record.game
        printf "."
      else
        printf "!"
        rational_poker.create_hand_text(session, hand_record.lines.join("\n"))
      end
    end
  end
  puts
end