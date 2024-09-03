defmodule Problema7 do

  def main() do
      "Ingresar el tipo de bolsa del cliente"
      |>Util.ingresar(:input)
      |> enhanced_calcDisc()
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


  def enhanced_calcDisc (tipo_bolsa) do
    case tipo_bolsa do
      "plastica" -> 0.02
      "biodegradable" -> 0.12
      "reutilizable" -> 0.17
      _ -> 0.0
    end
  end
end

  #Usando mat
  def

Problema7.main()
