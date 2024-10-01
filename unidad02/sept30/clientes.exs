defmodule Cliente do
  defstruct nombre: "", edad: 0, altura: 0.0

  def crear(nombre, edad, altura) do
    %Cliente{nombre: nombre, edad: edad, altura: altura}
  end

  def ingresar(mensaje) do
    UtilidadesEntradaSalida.mostrar_mensajee(mensaje)

    nombre =
      "Ingrese nombre: "
      |> UtilidadesEntradaSalida.ingresar(:texto)

    edad =
      "Ingresar edad: "
      |> UtilidadesEntradaSalida.ingresar3(:entero2)

    altura =
      "Ingrese la altura: "
      |> UtilidadesEntradaSalida.ingresar3(:real)

    crear(nombre, edad, altura)
  end

  def ingresar(mensaje, :clientes) do
    mensaje
    |> ingresar([], :clientes)
  end

  defp ingresar(mensaje, lista, :clientes) do
    cliente =
      mensaje |> ingresar()

    nueva_lista = lista ++ [cliente]

    mas_clientes =
      "\nIngresar mas clientes (s/n): "
      |> UtilidadesEntradaSalida.ingresar3(:boolean)

    case mas_clientes do
      true ->
        mensaje
        |> ingresar(nueva_lista, :clientes)

      false ->
        nueva_lista
    end
  end

  def generar_mensaje_clientes(lista_clientes, parser) do
    lista_clientes
    |> Enum.map(parser)
    |> Enum.join()
  end

  def escribir_csv(clientes, nombre) do
    clientes
    |> generar_mensaje_clientes(&convertir_cliente_linea_csv/1)
    |> (&("nombre,edad,altura\n" <> &1)).()
    |> (&File.write(nombre, &1)).()
  end

  def convertir_cliente_linea_csv(cliente) do
    "#{cliente.nombre},#{cliente.edad},#{cliente.altura}\n"
  end

  def filtrar_datos_interes(datos) do
    datos
    # |> Enum.filter(&(&1.edad < 21)) Forma anonima reducida
    |> Enum.filter(fn cliente -> cliente.edad < 21 end)
  end

  def generar_mensaje(cliente) do
    altura = cliente.altura |> Float.round(2)
    "Nombre: #{cliente.nombre}, tu edad es: #{cliente.edad} y tienes una altura: #{altura}\n"
  end

  def leer_csv(nombre) do
    nombre
    |> File.stream!()
    # Esta linea ignora la primera linea del csv que en teoria deberia ser los titulos.
    |> Stream.drop(1)
    |> Enum.map(&convertir_cadena_cliente/1)
  end

  def convertir_cadena_cliente(cadena) do
    [nombre, edad, altura] =
      cadena
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      # Cuando colocamos el ampersant al principio, en vez de ejecutar la funcion,
      # lo que pasa es que estamos enviando la direccion de la funcion para que map sepa que funcion ejecutar.

    edad = edad |> String
    altura = altura |> String.to_float()

    Cliente.crear(nombre, edad, altura)
  end
end
