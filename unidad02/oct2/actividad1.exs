defmodule Docente do
  # PERIODO,FACULTAD,PROGRAMA,GENERO,FORMACION,VINCULACION,DEDICACION,CARGO,CATEGORIA
  defstruct [
    :periodo,
    :facultad,
    :programa,
    :genero,
    :formacion,
    :vinculacion,
    :dedicacion,
    :cargo,
    :categoria
  ]
end

defmodule Activity1 do
  def main do
    convert_csv_to_list("/home/esteban/Documents/programming/Elixir/unidad02/oct2/docentes.csv")
    |> Enum.map(&convert_list_to_docente/1)
    |> filter_by_docentes_field(:formacion, "MAESTRIA")
    |> filter_by_docentes_field(:vinculacion, "PLANTA")
    |> Enum.each(&IO.inspect(&1))
  end

  # Returns a list of strings.
  def get_fields_ignoring_quotes(string) do
    regex = ~r/,(?=(?:[^"]*"[^"]*")*[^"]*$)/
    Regex.split(regex, string)
  end

  # Returns a list of lists of strings.
  def convert_csv_to_list(csv_path) do
    File.read!(csv_path)
    |> String.split("\n")
    |> Enum.map(&get_fields_ignoring_quotes/1)
  end

  # Convierte una lista con la informacion de un solo docente en un struct. Es decir, se obtiene un docente con base a una lista.
  def convert_list_to_docente(list) do
    %Docente{
      periodo: Enum.at(list, 0),
      facultad: Enum.at(list, 1),
      programa: Enum.at(list, 2),
      genero: Enum.at(list, 3),
      formacion: Enum.at(list, 4),
      vinculacion: Enum.at(list, 5),
      dedicacion: Enum.at(list, 6),
      cargo: Enum.at(list, 7),
      categoria: Enum.at(list, 8)
    }
  end

  def filter_by_docentes_field(docentes, field, value) do
    Enum.filter(docentes, fn docente -> Map.get(docente, field) == value end)
  end
end

Activity1.main()
