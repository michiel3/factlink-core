require 'ohm/contrib'

class OurOhm < Ohm::Model
   include Ohm::Contrib
   include Ohm::Callbacks
   extend ActiveModel::Naming
   
   # needed for Ohm polymorphism:
   self.base = self

  include Canivete::Deprecate

  def save!
    save
  end

  deprecate
  alias :new_record? :new?

  #TODO : use callbacks instead
  def save
    pre_save
    x = super
    post_save
    return x
  end

  def pre_save
  end

  def post_save
  end

  deprecate
  def self.create!(*args)
    x = self.new(*args)
    x.save
    x
  end

  def assert_url(att, error = [ att , :not_url ] )
   assert send(att).to_s =~ /^http/, error
  end

  
end

class Ohm::Model::Set < Ohm::Model::Collection
  alias :count :size
  
  def &(other)
    apply(:sinterstore,key,other.key,key+"*INTERSECT*"+other.key)
  end

  def |(other)
    apply(:sunionstore,key,other.key,key+"*UNION*"+other.key)
  end

  def -(other)
    apply(:sdiffstore,key,other.key,key+"*DIFF*"+other.key)
  end
  
end

class Ohm::Model::List < Ohm::Model::Collection
  alias :count :size
end