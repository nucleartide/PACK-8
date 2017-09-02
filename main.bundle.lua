__modules__ = {
  ["/Users/jason/Repositories/pack/main.lua"] = function()
  require '/Users/jason/Repositories/pack/test_module.lua'
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
