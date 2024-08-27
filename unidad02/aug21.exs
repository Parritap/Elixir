def module Main do


  def ingresar_texto(mensaje) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end


##Atomos -> Podemos utilizarlos como una manera de emular
# el polimorfismo en Elixir.

def fun(:f1) do
  IO.puts("This is function 1")
end

def fun(:f2) do
  IO.puts("This is function 2")
end




end
