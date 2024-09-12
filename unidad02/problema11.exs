defmodule ParImpar do
  def main() do
    valores = [10_000, 100_000, 1_000_000, 10_000_000, 100_000_000]

    Enum.each( valores, fn valor ->
      "----------------VALOR #{valor} ----------------------" |> IO.puts()
      Enum.each(1..5, fn i ->
        "Iteración #{i}: \n" |> IO.puts()
        probar_algoritmos(valor)
        IO.puts("")
        IO.puts("")
      end)
    end)
  end


  # Método para saber si un número es par o
  # impar mediante el uso de recursividad tradicional
  def isEven1(0), do: true
  def isEven1(1), do: false
  def isEven1(n), do: isEven1(n - 2)

  #Método 2
  def isEven2(n), do: isEven2(0, n)
  def isEven2(m, n) when m * 2 == n, do: true
  def isEven2(m, n) when m * 2 > n, do: false
  def isEven2(m, n), do: isEven2(m+1, n)

  # Método 3. -> usando recursividad indirecta.
  def isEven3(0), do: true
  def isEven3(n), do: isOdd3(n - 1)

  def isOdd3(0), do: false
  def isOdd3(n), do: isEven3(n - 1)

  # Usando remainder
  def isEven4(n) when rem(n, 2) == 0, do: true
  def isEven4(_), do: false

  #Ejecuta secuencialmente los 4 algoritmos con un valor dado.
  def probar_algoritmos(valor) do

    a1 = {ParImpar, :isEven1, [valor]}
    a2 = {ParImpar, :isEven2, [valor]}
    a3 = {ParImpar, :isEven3, [valor]}
    a4 = {ParImpar, :isEven4, [valor]}

    Benchmark.determinar_tiempo_ejecucion(a1) |> IO.puts()
    Benchmark.determinar_tiempo_ejecucion(a2) |> IO.puts()
    Benchmark.determinar_tiempo_ejecucion(a3) |> IO.puts()
    Benchmark.determinar_tiempo_ejecucion(a4) |> IO.puts()
  end

end


ParImpar.main()
