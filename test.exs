a = {{3, 4}, 5}

case a do
  {{q, w} = t, e} = r ->
    IO.inspect(t)
end
