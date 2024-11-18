defmodule NodoCliente do
  @servicio_m1 :servicio_m1
  @servicio_m2 :servicio_m2
  @cluster [:nodoservidor1@localhost, :nodoservidor2@localhost]

  def main() do
    UtilidadesEntradaSalida.mostrar_mensaje("PROCESO PRINCIPAL - Cliente")
    conectar_nodos(@cluster)
    enviar_mensajes()
    esperar_respuestas(0)
  end

  defp conectar_nodos(cluster) do
    Enum.each(cluster, &Node.connect/1)
    :global.sync()
  end

  defp obtener_servicio(nombre_servicio) do
    :global.whereis_name(nombre_servicio)
  end

  defp enviar_mensajes() do
    combinaciones = generar_combinaciones(20)  # Supongamos que hay 20 variables
    mitad = div(length(combinaciones), 2)

    # Lee el archivo CNF
    archivo_cnf = leer_archivo_cnf("uf20-01.cnf")

    mensajes = [
    # Primera mitad: desde el inicio hasta el índice mitad (incluyendo el extra si impar)
  {{:servicio_m1, Enum.slice(combinaciones, 0, mitad + 1), archivo_cnf}, @servicio_m1},

  # Segunda mitad: desde mitad + 1 hasta el final
  {{:servicio_m2, Enum.slice(combinaciones, mitad + 1, length(combinaciones) - (mitad + 1)), archivo_cnf}, @servicio_m2}
]

    Enum.each(mensajes, fn {mensaje, servicio} ->
      enviar_mensaje(mensaje, servicio)
    end)

    finalizar_servicios()
  end
  def generar_combinaciones(num_vars) do
    max_combinations = :math.pow(2, num_vars) |> round()

    # Generar las combinaciones como enteros binarios
    for num <- 0..(max_combinations - 1) do
      num
      |> Integer.to_string(2)            # Convertir el número a binario
      |> String.pad_leading(num_vars, "0")  # Asegurarse de que tiene la longitud correcta
      |> String.to_integer(2)            # Convertir la cadena binaria a un número entero
    end
  end

  # Función para leer el archivo CNF
  defp leer_archivo_cnf(ruta) do
    case File.read(ruta) do
      {:ok, contenido} -> contenido
      {:error, reason} ->
        IO.puts("Error al leer el archivo CNF: #{reason}")
        ""
    end
  end



  defp enviar_mensaje(mensaje, servicio) do
    case obtener_servicio(servicio) do
    :undefined ->
    IO.puts("No se encontró el servicio #{servicio}.")
    pid ->
    send(pid, {self(), mensaje})
    end
    end

  defp finalizar_servicios() do
    [:fin, :fin]
    |> Enum.zip([@servicio_m1,
    @servicio_m2])

    |> Enum.each(fn {fin, servicio} -> enviar_mensaje(fin, servicio) end)
    end




  defp esperar_respuestas(3),
    do: :ok

  defp esperar_respuestas(i) do
    receive do
    :fin ->
    esperar_respuestas(i + 1)
    respuesta ->
    UtilidadesEntradaSalida.mostrar_mensaje("\t -> \"#{respuesta}\"")
    esperar_respuestas(i)
    end
end
end
NodoCliente.main()
