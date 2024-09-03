defmodule Main do
  def main() do
    calcular_permutaciones_circulares(7)
    |> IO.puts()
  end

  # método que calcula la permutación circular de un número n.
  #Método imperativo
  def calc_permutaciones_circulares(n) do
    res = n

    if n >= 1 do
      res * calc_permutaciones_circulares(res - 1)
    else
      1
    end
  end

  #Método funcional
  def calcular_permutaciones_circulares(n) do
    (n - 1) |> calcular_factorial
  end

  #Usando sobrecarga.
  def calcular_factorial(0), do: 1
  def calcular_factorial(n), do: n * calcular_factorial(n - 1)
end

Main.main()
