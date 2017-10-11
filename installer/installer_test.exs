defmodule InstallerTest do
  use ExUnit.Case
  doctest Installer

  #
  # test cases:
  #
  #   Installer.fetch(["project/test", "project/main2", "github.com/clowerweb/Lib-Pico8/distance"])
  #   Installer.fetch(["project/test", "project/main2", "github.com/nucleartide/pico8/shooter"])
  #   Installer.fetch(["project/test", "project/main2"])
  #
end
