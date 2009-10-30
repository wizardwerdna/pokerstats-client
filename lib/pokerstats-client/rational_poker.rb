require 'rubygems'
require 'activeresource'
require 'activesupport'
require 'pokerstats'
module PokerstatsClient
  class RationalPoker
    # Establish Resources and authentication criteria
    RESOURCES = []
    Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|filename| require File.expand_path(filename)}
    SITENAME = "http://rationalpoker.local"
    def initialize user, password
      login(user, password)
    end  
    def login(user, password)
      RESOURCES.each {|resource| resource.login(SITENAME, user, password) }
    end
    def resources
      RESOURCES
    end

    # simplified api to resources
    def sessions
      PokerSession.find(:all)
    end
    def session(poker_session_id)
      PokerSession.find(poker_session_id)
    end
    def session_by_name(name)
      PokerSession.find(:first, :params => {:q => name})
    end
    def create_session(name, description)
      PokerSession.create(:name => name, :description => description)
    end
    def find_or_create_session(name, description)
      session = create_session(name, description)
      session = session_by_name(name) unless session.saved?
    end
    def hands(poker_session_or_id)
      HandText.find(:all, :params => {:ps_id => idfrom(poker_session_or_id)})
    end
    def hand_games(poker_session_or_id)
      HandText.find(:all, :params => {:selecting => "game", :ps_id => idfrom(poker_session_or_id)})
    end
    def session_game_list(poker_session_or_id)
      HandText.find(:all, :params => {:selecting => "game", :ps_id => idfrom(poker_session_or_id)}).collect{|each| each.game}
    end
    def hand(poker_session_or_id, hand_text_id)
      HandText.find(hand_text_id, :params => {:ps_id  => idfrom(poker_session_or_id)})
    end
    def create_hand_text(poker_session_or_id, text)
      hand_text = HandText.create(:text => text, :poker_session_id => idfrom(poker_session_or_id), :ps_id => idfrom(poker_session_or_id))
    end 
    
    private
    
    def idfrom(class_or_id)
      case class_or_id
      when Integer
        class_or_id
      else
        class_or_id.id
      end
    end
  end
end