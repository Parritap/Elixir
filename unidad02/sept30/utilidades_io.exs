defmodule UtilidadesEntradaSalida do
  def mostrar_mensajee(mensaje) do
    IO.puts(mensaje)
  end

  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end
end
