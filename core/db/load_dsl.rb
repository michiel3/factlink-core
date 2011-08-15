class LoadDslState
  @@user = nil
  @@fact = nil

  def self.graph_user
    u = @@user || User.all.first || load_user("GenericUser")
    
    u.graph_user
  end

  def self.user=(value)
    @@user = value
  end

  def self.fact=(value)
    @@fact = value
  end

  def self.fact
    @@fact
  end

  def self.channel
    @@channel || Channel.all.first || load_channel(self.graph_user,"Main channel")
  end

  def self.channel=(value)
    @@channel = value
  end
end

def load_fact(fact_string,url="http://example.org/")
  f = Fact.by_display_string(fact_string)
  if not f
    f = Fact.new
    f.displaystring = fact_string
    f.site = Site.find_or_create_by(url)
    f.created_by = LoadDslState.graph_user
    f.save
  end
  f
end

def fact(fact_string,url="http://example.org/")
  f = load_fact(fact_string,url)
  LoadDslState.fact = f
end

def export_fact(fact)
  rv = "fact \"#{quote_string(fact.displaystring)}\""
  rv += ", \"#{fact.site.url}\"\n" if fact.site
  rv
end

def fact_relation(fact1,relation,fact2)
  f1 = fact(fact1)
  f2 = fact(fact2)
  
  puts "LDS: #{LoadDslState.graph_user}"
  fr = f2.add_evidence(relation,f1,LoadDslState.graph_user)
  LoadDslState.fact = fr
end

def export_fact_relation(fact_relation)
  "fact_relation \"#{quote_string(fact_relation.get_from_fact.displaystring)}\", :#{fact_relation.type.to_sym}, \"#{quote_string(fact_relation.get_to_fact.displaystring)}\"\n"
end


def load_user(username,email=nil, password=nil)
  u = User.where(:username => username).first
  if not u
    email ||= "#{username}@example.org"
    password ||= "123hoi"
    u = User.new(:username => username,
    :email => email,
    :confirmed_at => DateTime.now,
    :password => password,
    :password_confirmation => password)
    u.save
    
    u.graph_user
  end
  u
end

def user(username,email=nil, password=nil)
  LoadDslState.user = load_user(username,email,password)
end

def export_user(graph_user)
  "user \"#{quote_string(graph_user.username)}\", \"#{quote_string(graph_user.user.email)}\"\n"
end

def export_activate_user(graph_user)
  "user \"#{quote_string(graph_user.username)}\"\n"
end


def believers(*l)
  set_opinion(:beliefs,*l)
end
def disbelievers(*l)
  set_opinion(:disbeliefs,*l)
end
def doubters(*l)
  set_opinion(:doubts,*l)
end


def export_userlist(l)
  l.map {|graph_user| "\"#{quote_string(graph_user.user.username)}\""}.join(',')
end
def export_believers(l)
  rv = "believers " + export_userlist(l) + "\n"
end
def export_disbelievers(l)
  rv = "disbelievers " + export_userlist(l) + "\n"
end
def export_doubters(l)
  rv = "doubters " + export_userlist(l) + "\n"
end

def set_opinion(opinion_type,*users)
  f = LoadDslState.fact
  users.each do |username|
    gu = load_user(username).graph_user
    f.add_opinion(opinion_type,gu)
  end
end

def create_channel(graph_user,title)
    ch = Channel.create(:created_by => graph_user, :title => title)
end


def load_channel(graph_user, title)
  graph_user.channels.find(:title => title).first || create_channel(graph_user,title)
end

def channel(title)
  ch = create_channel(LoadDslState.graph_user, title)
  LoadDslState.channel = ch
end

def export_channel(channel)
  "channel \"#{quote_string(channel.title)}\"\n"
end

def sub_channel(username,title)
  ch = load_channel(load_user(username).graph_user, title)
  LoadDslState.channel.add_channel(ch)
end

def export_sub_channel(channel)
  "sub_channel \"#{quote_string(channel.created_by.username)}\", \"#{quote_string(channel.title)}\"\n"
end

def add_fact(fact_string)
  f = load_fact(fact_string)
  LoadDslState.channel.add_fact(f)
end

def export_add_fact(fact)
  "add_fact \"#{quote_string(fact.displaystring)}\"\n"
end

def del_fact(fact_string)
  f = load_fact(fact_string)
  LoadDslState.channel.remove_fact(f)
end

def export_del_fact(fact)
  "del_fact \"#{quote_string(fact.displaystring)}\"\n"
end


def quote_string(v)
  v.to_s.gsub(/\\/, '\&\&').gsub(/"/, "\\\"")
end

