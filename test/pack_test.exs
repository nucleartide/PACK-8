defmodule PackTest do
  use ExUnit.Case
  doctest Pack

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "parse_requires" do
    match = Pack.parse_requires(~s"""
      require(       








       './stuff'










      )require("hello")require('stuff")require("aaaa'")require'hello again'require       'hiiiii' 
    """)

    assert match == ["./stuff", "hello", "hello again", "hiiiii"]
  end
end
