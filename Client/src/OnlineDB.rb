#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class OnlineDB
  def self.create(desc)
    s=srvproc("apps_db", {"ac"=>"dbcreate", "description"=>desc})
    if s[0].to_i<0
      return nil
    else
      return s[1].to_i
      end
    end
    def self.list
      s=srvproc("apps_db", {"ac"=>"dblist"})
      if s[0].to_i<0
        return nil
      else
        db={}
        k=nil
        for i in 1...s.size
          if i%2==1
            k=s[i].to_i
          else
            db[k]=s[i].delete("\r\n")
            end
          end
          return db
        end
      end
      def self.rename(appid,desc)
        s=srvproc("apps_db", {"ac"=>"dbrename", "appid"=>appid, "description"=>desc})
        return s[0].to_i==0
      end
      def self.delete(appid,password)
        s=srvproc("apps_db", {"ac"=>"dbdelete", "appid"=>appid, "password"=>password})
        return s[0].to_i==0
      end
      def self.flush(appid,password)
        s=srvproc("apps_db", {"ac"=>"dbflush", "appid"=>appid, "password"=>password})
        return s[0].to_i==0
        end
  def initialize(appid, db, table)
    syms={:public=>1, :shared=>2, :private=>3, :public_readonly=>-1, :private_readonly=>-3}
    db=syms[db] if syms[db]!=nil
    fail(ArgumentError, "appid must be an integer") if !appid.is_a?(Integer)
    fail(ArgumentError, "db must be an integer") if !db.is_a?(Integer)
    fail(ArgumentError, "table must be a string") if !table.is_a?(String)
    @appid,@db,@table=appid,db,table
    refresh
  end
  def get(i)
    if i.is_a?(Range)
      return [] if i.begin<0
      if i.end<0
        if i.exclude_end?
      i=i.begin..(size-i.end)
    else
      i=i.begin...(size-i.end)
    end
    end
    return [] if i.begin>i.end
    i=i.begin...size if i.end>size
          return i.map{|j| get(j)}
          end
    @vals[i]=unformat(@unformatted[i]) if @vals[i]==nil and @unformatted[i]!=nil
@vals[i]
    end
def refresh
  s=srvproc("apps_db", {'ac'=>'get', 'appid'=>@appid, 'db'=>@db, 'table'=>@table},1).split("\r\n")
  if s[0].to_i==0
    c=s[1].to_i
    @keys=Array.new(c)
    @unformatted=Array.new(c)
    @vals=Array.new(c)
    @creators=Array.new(c)
    for i in 0...c
      @keys[i]=s[2+i*3].to_i
      @creators[i]=s[2+i*3+1]
val=s[2+i*3+2]
@unformatted[i]=val
end
elsif s[0].to_i==-3
  fail(IOError, "appid not exists")
else
  fail(IOError, "Cannot open database")
    end
    return c
  end
  def size
    @keys.size
  end
  def length
    size
    end
  def count(t)
    c=0
    for i in 0...size
      c+=1 if get(i)==t
    end
    return c
  end
  def include?(o)
  return count[o]>0
  end
  def first
    self[0]
  end
  def last
    self[-1]
  end
  def [](i)
    fail(IndexError, "Maximum index in DB is 131071") if i.is_a?(Integer)&&i>131071&&i>=size
    return get(i).deep_dup
  end
  def each(&block)
    for i in 0...size
      block.call(get(i))
      end
    end
  def []=(i,v)
    fail(IOError, "Cannot modify entries of readonly database") if @db<0
    i=size+i while i<0
    fail(IndexError, "Maximum index in DB is 131071") if i>131071
    if i>=size  
      c=i-size
      if c>0
      s=srvproc("apps_db", {"ac"=>"addfields", "appid"=>@appid, "db"=>@db, "table"=>@table, "count"=>c})
      return nil if s[0].to_i<0
      s[1..-1].each{|l| @keys.push(l.to_i);@vals.push(nil) }
      end
      push(v)
    else
          val=format(v)
    s=srvproc("apps_db", {"ac"=>"set", "appid"=>@appid, "db"=>@db, "table"=>@table, "entry"=>@keys[i], "buf"=>buffer(val)})
    return nil if s[0].to_i<0
    @vals[i]=v
  end
  return v.deep_dup
end
  def push(v)
    val=format(v)
    s=srvproc("apps_db", {"ac"=>"push", "appid"=>@appid, "db"=>@db, "table"=>@table, "buf"=>buffer(val)})
    return nil if s[0].to_i<0
    id=s[1].to_i
    @vals.push(v)
    @creators.push($name)
    @keys.push(id)
    return self
  end
  def delete_at(index)
    fail(IOError, "Cannot delete entries from readonly database") if @db<0
    s=srvproc("apps_db", {"ac"=>"delete", "appid"=>@appid, "db"=>@db, "table"=>@table, "entry"=>@keys[index]})
    if s[0].to_i==0
            v=get(index)
            @unformatted.delete_at(index)
            @vals.delete_at(index)
            @keys.delete_at(index)
            @creators.delete_at(index)
      return v
    else
      return nil
      end
    end
    def delete(v)
      r=nil
      i=0
      while i<size
        if get(i)==v
          r=v
          delete_at(i)
        else
          i+=1
          end
        end
        return r
      end
      def share(index, user)
    fail(IOError, "Cannot share entries in not-shared database") if @db!=2
    s=srvproc("apps_db", {"ac"=>"share", "user"=>user, "appid"=>@appid, "db"=>@db, "table"=>@table, "entry"=>@keys[index]})
    if s[0].to_i==0
      return true
    else
      return false
      end
    end
  private
    def unformat(val)
      return nil if val==""||val=="null"
      return val.to_i if val.to_i.to_s==val
      return JSON.load(val)
      end
      def format(v)
        if v==nil||v.is_a?(Integer)||v.is_a?(String)||v==false||v==true||v.is_a?(Array)||v.is_a?(Hash)
        return JSON.generate(v)
    else
      fail(ArgumentError, "OnlineDB accepts only JSON-convertable structures")
      end
    end
end