#!/usr/bin/env ruby
#require 'rubygems'
#require 'breakpoint'
require 'test/unit'
require '../lib/svn'


$system_args = []

def Kernel.system args
  #puts args   
  $system_args << args
end


class TestSubversion < Test::Unit::TestCase



  def setup
    @svn = Subversion.new
  end
  
  def test_system_rewrite
    Kernel.system "uptime"
    #puts $system_args
    assert $system_args.include? 'uptime'
    
    system 'ls'
    assert $system_args.include? 'ls'
  end
  
  def test_ignore
    @svn.ignore 'test.rb', '../fixtures'
    puts $system_args
    assert $system_args.include? 'svn'
    
  end
    
    
end