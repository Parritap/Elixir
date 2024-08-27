# 4.5
IO.puts(String.ends_with?(String.upcase("Hola mundo"), "UNDO"))

# 4.6
"Hola Mundo"
|> String.upcase()
|> String.ends_with?("UNDO")
|> IO.puts


