require File.expand_path('../../../app/classes/blacklist.rb', __FILE__)

describe Blacklist do
  subject { 
    Blacklist.new([
      /^http(s)?:\/\/(www\.)?facebook\.com/,
      /^http(s)?:\/\/(www\.)?factlink\.com/,
      /^http(s)?:\/\/(www\.)?twitter\.com/,
    ]) 
  }
  
  describe "#should_return_true_on_match" do
    it {subject.matches?('http://facebook.com').should == true}
  end
  
  describe "#should_return_false_when_no_match" do
    it {subject.matches?('http://google.com').should == false}
  end
  
  describe "#should_also_match_non-first_blacklist_item" do
    it {subject.matches?('http://twitter.com').should == true}
    it {subject.matches?('http://factlink.com').should == true}
  end
  
end