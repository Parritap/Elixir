defmodule SimulacionParImpar do
  @valores_prueba [10_000, 100_000, 1_000_000, 10_000_000, 100_000_000]
  @repetaciones 5

  # def main do
  #   mensaje_simulaciones =
  #     hacer_simulaciones(@valores_prueba, @repetaciones)
  #     |> convertir_resultados_simulaciones_mensaje()
  #     |> agregar_titulos()

  #   mensaje_simulaciones
  #   |> escribir_archivo("par_impar.csv")

  #   mensaje_simulaciones
  #   |> Util.mostrat_mensajes()
  # end


  #Funcion main 2 usando el codigo del profe
  def main do
    hacer_simulaciones(@valores_prueba, @repeticiones)
    |> convertir_resultados_simulaciones_mensaje()
    |> agregar_titulos()
    |> Benchmark.generar_grafica_html()
    |> escribir_archivo("index.html")
    end


  # VERSION 1
  defp hacer_simulaciones(valores, repeticiones) do
    Enum.map(valores, fn valor ->
      ejecutar_simulacion(valor, repeticiones)
    end)
  end

  # TODO Terminar
  defp hacer_simulaciones2(valores, repeticiones) do
  end

  # Nota, una tupla es inmutable.
  defp ejecutar_simulacion(valor, repeticiones) do
    algoritmos = [
      {ParImpar, :isEven1, [valor]},
      {ParImpar, :isEven2, [valor]},
      {ParImpar, :isEven3, [valor]},
      {ParImpar, :isEven4, [valor]}
    ]

    tiempo_promedio =
      Enum.map(algoritmos, fn algoritmo ->
        obtener_tiempo_promedio_ejecucion(algoritmo, repeticiones)
      end)

    {valor, tiempo_promedio}
  end

  defp obtener_tiempo_promedio_ejecucion(algoritmo, repeticiones) do
    suma =
      Enum.map(1..repeticiones, fn _ ->
        Benchmark.determinar_tiempo_ejecucion(algoritmo)
      end)
      |> Enum.sum()

    (suma / repeticiones)
  end

  defp convertir_resultados_simulaciones_mensaje(resultado_simulaciones) do
    resultado_simulaciones
    |> Enum.map(fn simulacion -> generar_mensaje(simulacion) end)
    |> Enum.join("\n")
  end

  defp generar_mensaje(simulacion) do
    {valor, [promedio1, promedio2, promedio3, promedio4]} = simulacion
    "#{valor}, #{promedio1}, #{promedio2}, #{promedio3}, #{promedio4}"
  end

  defp agregar_titulos(mensaje_simulacion) do
    agregar_titulos = fn contenido ->
      "Prueba, Algoritmo 1, Algoritmo 2, Algoritmo 3, Algoritmo 4\n" <> contenido
    end

    mensaje_simulacion
    |> agregar_titulos.()
  end




  defp  escribir_archivo(contenido, nombre) do
    File.write(nombre, contenido)
  end
end

SimulacionParImpar.main()
