defmodule Proceso do
  @cant_procesos_internos 5

  def main do
    Benchmark.determinar_tiempo_ejecucion({Proceso, :simulacion, [@cant_procesos_internos]})
  end

  def simulacion(cantidad_procesos_internos) do
    datos_prueba = [{"A, 2500"}, {"\tB, 1500"}, {"\t\tC, 500"}, {"\t\t\tD, 3500"}]

    Enum.each(datos_prueba, fn valor ->
      simulando_proceso(valor, cantidad_procesos_internos)
    end)
  end


  def simulando_proceso ({mensaje, demora}, cantidad_procesos_internos) do
    IO.puts("#{mensaj} -> #{demora}")
    Enum.each(1..cantidad_procesos_internos, fn i ->
      :timer.sleep(demora)
      IO.puts("\t#{mensaje} - #{i}")
    end)

    IO.puts({"#{mensaje} -> FINALIZADA"})
  end
end
