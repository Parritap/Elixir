defmodule Main do

  def main() do
    "Ingrese la cantidad de clientes"
    |> Util.ingresar(:entero)
    |> Util.calcular_permutaciones_circulares()
    |> generar_mensaje()
    |> Util.ingresar(:output)
  end

  def generar_mensaje(n) do
    "La cantidad de personas que pueden organizarse es: #{n}"
  end

end

Main.main()
