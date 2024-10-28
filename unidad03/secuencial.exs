defmodule Proceso do
  @cant_procesos_internos 5

  def main do
    Benchmark.determinar_tiempo_ejecucion({Proceso, :simulacion_task_async, [@cant_procesos_internos]})
    |> generar_mensaje()
    |> Util.mostrar_mensaje()
  end

  def simulacion(cantidad_procesos_internos) do
    datos_prueba = [{"A", 2500}, {"\tB", 1500}, {"\t\tC", 500}, {"\t\t\tD", 3500}]

    Enum.each(datos_prueba, fn valor ->
      simulando_proceso(valor, cantidad_procesos_internos)
    end)
  end

  def simulando_proceso({mensaje, demora}, cantidad_procesos_internos) do
    IO.puts("#{mensaje} -> #{demora}")

    Enum.each(1..cantidad_procesos_internos, fn i ->
      :timer.sleep(demora)
      IO.puts("\t#{mensaje} - #{i}")
    end)

    IO.puts("#{mensaje} -> FINALIZADA")
  end

  def generar_mensaje(tiempo), do: "\nEl tiempo de ejecución fue de #{tiempo} microsegundos"

  #############################################
  # Versión final con Spawn
  ###########################################

  def simulacion_spawn(cantidad_procesos_internos) do
    datos_prueba = [{"A", 2500}, {"\tB", 1500}, {"\t\tC", 500}, {"\t\t\tD", 3500}]

    Enum.each(datos_prueba, fn valor ->
      spawn(fn -> simulando_proceso(valor, cantidad_procesos_internos) end)
    end)
  end

  def simulacion_task_async(cantidad_procesos_internos) do
    datos_prueba = [{"A", 2500}, {"\tB", 1500}, {"\t\tC", 500}, {"\t\t\tD", 3500}]

    tarea =
      Enum.map(datos_prueba, fn valor ->
        Task.async(fn -> simulando_proceso(valor, cantidad_procesos_internos) end)
      end)


      #Si se omite el ultimo valor, por defefcto es 5000 milisegundos
      Enum.each(tarea, &Task.await(&1, 100_000) )
  end
end

Proceso.main()
