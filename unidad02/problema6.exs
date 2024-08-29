
defmodule Problema5 do
  @dos_anios 10
  @seis_anios 14
  @mas_de_seis 17

  def main() do
   "Ingrese la antiguedad del cliente en años:"
    |> Util.ingresar(:entero)
    |> calcularDescuento()
    |> to_string()
    |> Util.ingresar(:output)
  end

#  def calcDisc(antiguedad, precio) when antiguedad<3, do: precio - precio*@dos_anios / 100
#  def calcDisc(antiguedad, precio) when antiguedad<7, do: precio - precio*@seis_anios / 100
#  def calcDisc(antiguedad, precio) when antiguedad>6, do: precio - precio*@mas_de_seis / 100


def calcularDescuento(antiguedad) do
  cond do
    antiguedad < 1 -> 0.0
    antiguedad <= 2 -> 0.10
    antiguedad <= 6 -> 0.14
    true -> 0.17
  end
end

end
