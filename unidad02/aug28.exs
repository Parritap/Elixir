defmodule DatosLogicos do
  @anio_fundacion 1991

  #generarMensaje podría dentro de su código contener el año de fundación  pero
  #no es buena praxis hacer eso dado que eso haría que el codigo esté muy
  #acoplado
  def main do
    "Ingrese número de cédula"
    |> Util.ingresar(:entero)
    |> Util.generar_mensaje(@anio_fundacion)
    |> Util.mostrar_mensaje()
  end
end
