defmodule Main do
  ## Ingresar el valor del producto
  ## ingresar el porcentaje de descuento
  ## determinar el valor final, luego informarlo.
  def main() do
    disc = Util.ingresar("Ingrese el porcentaje de descuento", :real)
    prod = Util.ingresar("Ingrese el valor del producto", :real)
    val = prod - prod * disc
    Util.ingresar("El valor del final del producto es #{val}", :output)
  end
end
Main.main()
