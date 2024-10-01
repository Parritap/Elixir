defmodule Estructuras do
  def main do
   # crear_lista_clientes()
   # |> Cliente.escribir_csv("clientes.csv")


   "clientes.csv"
   |> Cliente.leer_csv()
   |> filtrar_datos_interes()
   |> Cliente.generar_mensaje_clientes(&generar_mensaje/1)
   |> Util.mostrar_mensaje_gui()
  end





  defp crear_lista_clientes() do
    [
      Cliente.crear("Ana", "Gomez", 12_345_678),
      Cliente.crear("Juan", "Perez", 87_654_321),
      Cliente.crear("Maria", "Lopez", 45_678_912),
      Cliente.crear("Pedro", "Garcia", 78_912_345),
      Cliente.crear("Laura", "Rodriguez", 65_432_198)
    ]
  end
end

Estructuras.main()
