# SpeedUP = ganancia en tiempo de ejecución de un algoritmo sobre otro.

defmodule Benchmark do
  def main(f1, f2) do
    t1 = determinar_tiempo_ejecucion(f1)
    t2 = determinar_tiempo_ejecucion(f2)

    generar_mensaje(t1, t2)
  end

  def calcular_speedup(t1, t2), do: t2 / t1

  def determinar_tiempo_ejecucion({modulo, funcion, argumentos}) do
    tiempo_inicial = System.monotonic_time()
    apply(modulo, funcion, argumentos)
    tiempo_final = System.monotonic_time()

    duracion =
      System.convert_time_unit(
        tiempo_final - tiempo_inicial,
        :native,
        :microsecond
      )

    duracion
  end

  def generar_mensaje(t1, t2) do
    speedup = calcular_speedup(t1, t2) |> Float.round(2)

    "Tiempos: algoritmo 1 #{t1}, algoritmo 2: #{t2}
    El algoritmo 1 es #{speedup} veces más rapido que el algoritmo 2"
  end

  def generar_grafica_html(datos) do
    html_base =
      """
      <html>
      <head>
      <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
      <script type="text/javascript">
      google.charts.load('current'

      , {'packages':['bar']});

      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
      var data = google.visualization.arrayToDataTable([
      <TITULOS y DATOS>
      ]);
      var options = {
      chart: {
      title: 'Comparación de algoritmos'
      ,

      subtitle: 'Pruebas vs Tiempo de ejecución'
      ,

      }
      };
      var chart = new google.charts.Bar(document.getElementById('columnchart_material'));
      chart.draw(data, google.charts.Bar.convertOptions(options));
      }
      </script>


      </head>
      <body>
      <div id="columnchart_material" style="width: 800px; height: 500px;"></div>
      </body>
      </html>
      """

    html_final = String.replace(html_base, "<TITULOS y DATOS>", datos)

    html_final
  end
end
