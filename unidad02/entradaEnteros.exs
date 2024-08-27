defmodule Main do
  def main() do
    Util.ingresar("Ingrese un numero", :entero)
    |> IO.puts()
  end
end

Main.main()
