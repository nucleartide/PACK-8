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
  #   Installer.install("require('github.com/nucleartide/PACK-8/project/main2') require('project/testdir/bar')")
  #
end
