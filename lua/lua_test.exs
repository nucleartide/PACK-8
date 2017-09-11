defmodule Pack8Test do
  use ExUnit.Case
  # doctest Pack8

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
