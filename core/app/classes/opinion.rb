class Opinion
  
  #naming conventions as in the document describing the calculations
  # b = belief
  # d = disbeliefs
  # u = is uncertain
  #
  # a = authority
  
  attr_accessor :b, :d, :u, :a
  
  def initialize(b,d,u,a=1)
    self.b=b
    self.d=d
    self.u=u
    self.a=a
  end

  def Opinion.for_type(type, authority=0)
    case type
    when :beliefs
      Opinion.new(1,0,0,authority)
    when :disbeliefs
      Opinion.new(0,1,0,authority)
    when :doubts
      Opinion.new(0,0,1,authority)
    end
  end
  
  #inefficient, but allows for quickly changing the + def
  def Opinion.combine(list)
    if list.length > 0
      Opinion.new(0,0,0)
    else
      a = list.inject(Opinion.new(0,0,0,0)) { |result, element |  result + element }
    end
  end

  #CHANGE ALONG WITH + !!!!
  def weight
    return (self.b + self.d + self.u)*self.a
  end

  #CHANGE weight ALONG WITH + !!!
  def +(second)
    
    a = self.a + second.a
    
    if a == 0
      # No authority
      return Opinion.new(0.1,0.1,0.1)
    end
    
    b = (self.b*self.a + second.b*second.a)/a
    d = (self.d*self.a + second.d*second.a)/a
    u = (self.u*self.a + second.u*second.a)/a
    return Opinion.new(b,d,u,a)
  end
  
  
  
  #TODO : better name
  def dfa(fr,fl)
    result = self.discount_by(fr).discount_by(fl)

    # TODO: min does not exist.
    # result.a = min(fr.a,fl.a)
    #
    # Need the lowest value?
    result.a = [fr.a, fl.a].min
    return result
  end

  protected
  def discount_by(fl)
    pu = self
        
    b = pu.b * fl.b
    d = pu.d * fl.b
    u = fl.d + fl.u + pu.u * fl.b
    return Opinion.new(b,d,u,a)
  end
        
end
