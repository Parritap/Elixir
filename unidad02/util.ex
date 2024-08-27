defmodule Util do
  @moduledoc """
  # Módulo con funciones que se reutilizan
  - autor: Juan Esteban Parra Parra.
  - fecha: Junio del 2024.
  - licencia: GNU GPL v3.
  """

  @doc """
  Función que imprmite un mensaje dado por parametro
  """
  def mostrar_mensaje(m) do
    m
    |> IO.puts()
  end

  # Usando la GUI de Java.

  @doc """
  Función que hace uso de la librería JOptionPane de Java para imprimir
  un mensaje haciendo uso de la GUI.
  """
  def mostrar_mensaje_gui(m) do
    System.cmd("java", ["MFu nessage.java", m])
  end

  def ingresar_texto(mensaje) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ask(message) do
    IO.gets(message)
  end

  def ingresar(m, :input) do
    {entrada, 0} = System.cmd("java", ["Message.java", "input", m])

    entrada
    |> String.trim()
  end

  def ingresar(m, :output) do
    {entrada, 0} = System.cmd("java", ["Message.java", "output", m])

    entrada
    |> String.trim()
  end

  def ingresar_entero(m, :input) do
    m
    |> Util.ingresar(:input)
    |> String.to_integer()
  end

  def mostrar_error(m) do
    IO.puts(:standard_error, m)
  end

#  def ingresar(m, :entero) do
#    try do
#      m
#      |> ingresar(:input)
#      |> String.to_integer()
#    rescue
#      ArgumentError ->
#        "Error, se spera que ingrese un numero entero\n"
#        |> mostrar_error()
#
#        m
#        |> ingresar(:entero)
#    end
#  end
#
#  def ingresar(m, :real) do
#    try do
#      m
#      |> ingresar(:input)
#      |> String.to_float()
#    rescue
#      ArgumentError ->
#        "Error, se spera que ingrese un numero real\n"
#        |> mostrar_error()
#
#        m
#        |> ingresar(:entero)
#    end
#  end


  def ingresar(mensaje, func, tipo_dato) do
    try do
      mensaje
      |> ingresar(:input)
      |> func.()
    rescue
      ArgumentError ->
        "Error, se espera que ingrese un número #{tipo_dato}\n"
        |> mostrar_error()

        mensaje
        |> ingresar(func, tipo_dato)
    end
  end


  def ingresar(mensaje, :entero), do: ingresar(mensaje, &String.to_integer/1, :entero)
  def ingresar(mensaje, :real), do: ingresar(mensaje, &String.to_float/1, :real)




end
