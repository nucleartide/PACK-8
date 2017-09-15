
HTTPoison.start()

tasks =
  for i <- 1..6 do
    Task.async(fn ->
      # normal
      # HTTPoison.get("https://raw.githubusercontent.com/tj/make/master/neutrino.mk", [], hackney: [pool: :default])

      # 404
      # HTTPoison.get("https://raw.githubusercontent.com/tj/make/master/neutrin", [], hackney: [pool: :default])

      # error
      # HTTPoison.get("http://localhost:1", [], hackney: [pool: :default])

      # task death
      # exit(:normal)

      # timeout
      # Process.sleep(6 * 1000)
    end)
  end

Enum.reduce(results, nil, fn (result, _acc) ->
  # TODO: on error, return an error tuple
  # when the accumulator is an error tuple, return the acc

  case result do
    {:ok, {:ok, %HTTPoison.Response{status_code: 200, body: body}}} ->
      IO.puts body
    {:ok, {:ok, %HTTPoison.Response{status_code: status_code}}} ->
      IO.puts "request failed: status code #{status_code}"
    {:ok, {:error, %HTTPoison.Error{reason: reason}}} ->
      IO.puts "request failed: reason #{reason}"
    {:ok, {:error, posix_error}}
      IO.puts "request failed, couldn't open file for some reason"
    {:exit, reason} -> # task died
      IO.puts "request failed: task died"
    nil ->
      IO.puts "timed out"
  end
end)
