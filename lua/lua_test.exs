defmodule Resolver.LuaTest do
  use ExUnit.Case
  doctest Resolver.Lua

#  test "parse_requires" do
#    match = Pack8.parse_requires("""
#      require(       
#       './stuff'
#      )require("hello")require('stuff")require("aaaa'")require'hello again'require       'hiiiii' 
#    """)
#
#    assert match == ["./stuff", "hello", "hello again", "hiiiii"]
#  end
end
