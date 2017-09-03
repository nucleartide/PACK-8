__modules__ = {
  ["/Users/jason/Repositories/pack/main.lua"] = function()
  local t = require '/Users/jason/Repositories/pack/test_module.lua'
--local fsm = 'github.com/nucleartide/pico8/fsm'
--local fsm = 'github.com/pico8/fsm'
-- https://raw.githubusercontent.com/tj/make/master/golang.mk

print("hi")

end,

["/Users/jason/Repositories/pack/test_module.lua"] = function()
  print("test module")

end,

}

__cache__ = {}

function require(idx)
  local cache = __cache__[idx]
  if cache then return cache end
  local module = __modules__[idx]()
  __cache__[idx] = module
  return module
end

require '/Users/jason/Repositories/pack/main.lua'
