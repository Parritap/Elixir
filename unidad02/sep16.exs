# Problema 10 ->
# Abstracción: se necesita una lista numerada para firmar de un numero x a un número y.

# descomposición:
# obtener la cantidad de valores desde x a y
# crear la lista de tuplas
# numerar la lista.

defmodule Problema10 do
  def main() do
    lista = generar_lista_tuplas(3, 5)
    imprimir_lista(lista)
  end

  def generar_lista_tuplas(x, y) do
    n = y - x
    lista_tuplas = Enum.map(x..y, fn i -> {i, "________________"} end)
    Enum.join()
  end

  def imprimir_lista(lista) do
    Enum.each(lista, fn {numero, firma} ->
      IO.puts("#{numero}. #{firma}")
    end)
  end
end

#Problema10.main()

defmodule Problema11 do
  # Abstracción: Determinar la cantidad de parejas de conejos que se tendrá en la semana "n".
  # Descomposición:
  #   -> obtener n
  #   -> calcular parejas usando Fibbnoacci
  #   -> Retornar parejas
  #   -> informar sobre las cantidad de parejas en la semana n.

  def main() do
    semanas=6
    parejas = fib(semanas)
    Util.ingresar("La cantidad de conejos para la semana #{semanas} es #{parejas}", :output)
  end

  def fib(1), do: 1
  def fib(2), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)
end


Problema11.main()
