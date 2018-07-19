#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Cipher

  def initialize(shuffled)
    normal = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + [' '] + [',','.','/',';',"\'",'[',']','<','>','?',"\:","\"",'{','}','-','=','_','+','`','!','@',"\#",'$','%','^',"\&",'*','(',')','_','+',"\\",'|']
    @map = normal.zip(shuffled).inject(:encrypt => {} , :decrypt => {}) do |hash,(a,b)|
      hash[:encrypt][a] = b
      hash[:decrypt][b] = a
      hash
    end
  end

  def encrypt(str)
    str.split(//).map { |char| @map[:encrypt][char] }.join
  end

  def decrypt(str)
    str.split(//).map { |char| @map[:decrypt][char] }.join
  end

end


#Copyright (C) 2014-2016 Dawid Pieper