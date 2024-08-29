defmodule Problema7 do

  def main() do
      "Ingresar el tipo de bolsa del cliente"
      |>Util.ingresar(:input)
      |> calcularDescuento()
      |> to_string()
      |> Util.ingresar(:output)
  end

  def calcularDescuento(tipo_bolsa) do
    cond do
      tipo_bolsa == "plastica" -> 2
      tipo_bolsa == "biodegradable" -> 12
      tipo_bolsa == "reutilizable" -> 17
      true -> 0
    end
  end

end

Problema7.main()
