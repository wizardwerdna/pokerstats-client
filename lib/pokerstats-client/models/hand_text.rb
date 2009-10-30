module PokerstatsClient
  class RationalPoker
    class HandText < ActiveResource::Base
      RationalPoker::RESOURCES << self
      def self.login(user, password, rational_poker_url)
        self.site = rational_poker_url + "/poker_sessions/:ps_id/"
        self.user = user
        self.password = password
      end
      def self.find_games(session_or_id)
        session_id = session_or_id.id unless session_id.kind_of?(Integer)
        find(:all, :params => {:ps_id => session_id, :selecting => "game"})
      end
      def self.games(session_or_id)
        gamelist = find_games(session_or_id)
        raise "could not load games for session #{session.inspect}" if gamelist.nil?
        gamelist.collect{|each| each.game}
      end
    end
  end
end
