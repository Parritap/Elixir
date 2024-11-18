defmodule Calculadora do
  @servicio_remoto :calculadora_servidor@localhost

  def main() do
    # obtiene los argumentos del programa
    [a, b] = obtener_entradas(System.argv())
    suma = sumar(a, b)
    mensaje = generar_mensaje(a, b, suma)
    IO.puts(mensaje)
  end

  defp obtener_entradas([a, b | _]) do
    case Enum.map([a, b], &String.to_integer/1) do
      [a, b] -> [a, b]
      _ -> IO.puts("Error: Debe ingresar dos números enteros")
    end
  end

  def generar_mensaje(_, _, {:badrpc, _}) do
    IO.puts("Hubo un error al invocar el procedimiento remoto")
  end

  def generar_mensaje(a, b, suma) do
    "La suma de #{a} y #{b} es #{suma}"
  end

  def sumar(a, b) do
    :rpc.call(@servicio_remoto, __MODULE__, :sumar, [a, b])
  end
end

Calculadora.main()
