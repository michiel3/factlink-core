require File.expand_path('../../../app/classes/url_normalizer.rb', __FILE__)

describe UrlNormalizer do
  describe ".normalize" do
    def should_normalize_to(url, expected)
      UrlNormalizer.normalize(url).should == expected
    end

    it { should_normalize_to 'http://www.google.com/foo', 'http://www.google.com/foo' }
    it { should_normalize_to 'http://www.google.com/foo#bar', 'http://www.google.com/foo' }

    ['utm_source', 'utm_medium', 'utm_source', 'utm_content', 'utm_campaign'].each do |strip_param|
      it "should strip #{strip_param} if it is the only parameter" do 
        should_normalize_to "http://www.google.com/foo?#{strip_param}=bar",'http://www.google.com/foo'
      end
      it "should strip #{strip_param} if there are other parameters" do
        should_normalize_to "http://www.google.com/foo?#{strip_param}=bar&x=y",'http://www.google.com/foo?x=y'
      end
    end
    it { should_normalize_to 'http://www.google.com/?x=y|z', 'http://www.google.com/?x=y%7cz' }
  end

end