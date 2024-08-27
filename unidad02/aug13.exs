defmodule Mensaje do
  def main do
    "Bienvenidos a la empresa Once Ltda"
    |> IO.puts()
  end
end

Mensaje.main()

###########################################

# Version4.

defmodule Mensaje2 do
  def main do
    "Bienvenidos a la empresa Once Ltda"
    |> mostrar_mensaje()
  end

  defp mostrar_mensaje(mensaje) do
    mensaje
    |> IO.puts()
  end
end

Mensaje2.main()

###################################
# version 5

defmodule Mensaje3 do
  def main do
    "Bienvenido"
    |> Util.mostrar_mensaje()
  end
end

Mensaje3.main()

####################################

Util.mostrar_mensaje_gui("Gato veloz")
