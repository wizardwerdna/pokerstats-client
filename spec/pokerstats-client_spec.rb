require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'active_resource'
class MyLogger
  def info string
    puts string
  end
end
ActiveResource::Base.logger=MyLogger.new
require 'active_resource/http_mock'

Spec::Matchers.define :correspond_to do |hash|
  match do |resource|
    resource.attributes.symbolize_keys.should == hash
  end
end

describe PokerstatsClient::RationalPoker do
  before(:each) do 
    @poker_session_id = 16
    @session = { :id => @poker_session_id, :name => 'test', :description => 'test_description'}
    @sessions = [@session]
    @session_xml = @session.to_xml(:root => 'poker_session')
    @sessions_xml = @sessions.to_xml(:root => 'poker_sessions')
    @hand_text_id = 4
    @hand_text = {:id => @hand_text_id, :poker_session_id => 16, :text => 'this is a text'}
    @hand_texts = [@hand_text]
    @hand_text_xml = @hand_text.to_xml(:root => 'hand_text')
    @hand_texts_xml = @hand_texts.to_xml(:root => 'hand_texts')
    @authorization_request_header = { 'Authorization' => 'Basic d2l6YXJkd2VyZG5hOjEyMzEyMw==' }
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get    "/poker_sessions/16.xml",             @authorization_request_header, @session_xml
      mock.get    "/poker_sessions/16.xml",             @authorization_request_header, @session_xml
      mock.put    "/poker_sessions/16.xml",             @authorization_request_header, nil, 204
      mock.delete "/poker_sessions/16.xml",             @authorization_request_header, nil, 200
      mock.get    "/poker_sessions/99.xml",             @authorization_request_header, nil, 404
      mock.get    "/poker_sessions.xml",                @authorization_request_header, @sessions_xml
      mock.get    "/poker_sessions.xml?q=not_present",  @authorization_request_header, nil, 404
      mock.get    "/poker_sessions.xml?q=#{@session[:name]}",@authorization_request_header, @sessions_xml
      mock.post   "/poker_sessions.xml",                @authorization_request_header, nil, 204
      mock.get    "/poker_sessions/16/hand_texts/4.xml",@authorization_request_header, @hand_text_xml
      mock.put    "/poker_sessions/16/hand_texts/4.xml",@authorization_request_header, nil, 204
      mock.delete "/poker_sessions/16/hand_texts/4.xml",@authorization_request_header, nil, 200
      mock.delete "/poker_sessions/16/hand_texts/99.xml",@authorization_request_header, nil, 404
      mock.get    "/poker_sessions/16/hand_texts.xml",  @authorization_request_header, @hand_texts_xml
      mock.post   "/poker_sessions/16/hand_texts.xml",  @authorization_request_header, nil, 204
    end
    @rational_poker = PokerstatsClient::RationalPoker.new("wizardwerdna", "123123", "http://notrationalpokerjusttesting.com")
  end
  it "should get list of all sessions" do
    sessions = @rational_poker.sessions
    sessions.should have(1).element
    sessions.first.should correspond_to(@session)
  end
  it "should get a particular session" do
    session = @rational_poker.session(@poker_session_id)
    session.should correspond_to(@session)
  end
  it 'should create and save a valid session' do
    lambda {result = @rational_poker.create_session(@session[:name], @session[:description])}.should_not raise_error
  end
  it 'should find a session by name' do
    PokerstatsClient::RationalPoker::PokerSession.find_by_name("not_present").should be_nil
    PokerstatsClient::RationalPoker::PokerSession.find_by_name(@session[:name]).should correspond_to(@session)
  end
  it 'should find or create a session by name' do
    @not_present_session = @session.clone.update(:name => "not_present")
    PokerstatsClient::RationalPoker::PokerSession.find_or_create_by_name("not_present", @not_present_session).should correspond_to(@not_present_session)
    PokerstatsClient::RationalPoker::PokerSession.find_or_create_by_name("test", @session).should correspond_to(@session)
  end
  it "should get list of all hands for a session" do
    hand_texts = @rational_poker.hands(@rational_poker.sessions.first)
    hand_texts.should have(1).element
    hand_texts.first.should correspond_to(@hand_text)
  end
  it "should get a particular hand for a session" do
    hand_text = @rational_poker.hand(@poker_session_id, @hand_text_id)
    hand_text.should correspond_to(@hand_text)
  end
  it 'should create and save a valid hand for a session' do
    lambda {result = @rational_poker.create_hand_text(@poker_session_id, @hand_text[:text])}.should_not raise_error
  end
end