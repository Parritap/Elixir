defmodule NodoServidor1 do

  @white_regex ~r/\s+/
  @nombre_servicio_global :servicio_m1

  def main() do
    UtilidadesEntradaSalida.mostrar_mensaje("SERVIDOR 1 - Servidor de la primera mitad de combinaciones")
    registrar_servicio(@nombre_servicio_global)
    esperar_mensajes()
    deregistrar_servicio(@nombre_servicio_global)
  end

  defp registrar_servicio(nombre_servicio_global) do
    :global.register_name(nombre_servicio_global, self())
    :global.sync()
  end

  defp deregistrar_servicio(nombre_servicio_global) do
    :global.unregister_name(nombre_servicio_global)
  end

  defp esperar_mensajes() do
    receive do
      {productor, {servicio, combinaciones, archivo_cnf}} ->
        # Aquí estamos extrayendo el servicio, combinaciones y archivo_cnf
        IO.puts("Mensaje recibido del productor #{inspect(productor)}")

        # Procesar el mensaje (combinaciones y archivo CNF)
        IO.puts("Procesando combinaciones: #{inspect(combinaciones)}")
        IO.puts("Contenido del archivo CNF: #{archivo_cnf}")

        # Aquí puedes procesar las combinaciones y el archivo CNF de acuerdo a tus necesidades
        procesar_mensaje(combinaciones, archivo_cnf)
        |> send_respuesta(productor)

        esperar_mensajes()

      {_, :fin} ->
        UtilidadesEntradaSalida.mostrar_mensaje("Desconectando servicio...")
        :ok
    end
  end
  defp procesar_mensaje(combinaciones, archivo_cnf) do
    num_vars =
      get_first_line(archivo_cnf, &(&1 |> String.split(@white_regex) |> Enum.at(2)))
      |> String.to_integer()

    IO.puts("NUM_VARS: #{num_vars}")

    IO.puts("EXTRACTING TESTS---------------------------------")
    tests_lists = extract_tests(archivo_cnf)

    for test <- tests_lists do
      IO.inspect(test)
    end

    IO.puts(length(tests_lists))
    IO.puts("TESTS EXTRACTED---------------------------------")

    max = length(combinaciones)
    max_num_bits = (max - 1) |> Integer.to_string(2) |> String.length()
    IO.puts("MAX: #{max} and MAX_NUM_BITS: #{max_num_bits}")

    # Lista para almacenar las combinaciones que satisfacen las pruebas
    satisfying_combinations =
      combinaciones
      |> Enum.filter(fn combination ->
        result = eval_tests!(combination, tests_lists, max_num_bits)

        if result do
          variables_solution =
            combination
            |> Integer.to_string(2)
            |> check_variales(max_num_bits)

          IO.puts("SATISFIABLE with #{combination} in binary form: #{variables_solution}")
        end

        result
      end)

    # Flag variable: indica si hay combinaciones válidas
    flag = Enum.any?(satisfying_combinations, & &1)
# Convertir las combinaciones que satisfacen a string
  # Convertir las combinaciones que satisfacen a string y separarlas con comas
satisfying_combinations_strings =
  satisfying_combinations
  |> Enum.map(fn combination ->
    Integer.to_string(combination, 2)
    |> String.pad_leading(num_vars, "0")
  end)
  |> Enum.join(", ")

    # Final output
    if flag do
      IO.puts("SOME COMBINATIONS ARE SATISFIABLE")
      send_respuesta(satisfying_combinations_strings, self())
    else
      IO.puts("PROBLEM UNSATISFIABLE")
      send_respuesta([], self())
    end
  end

  defp send_respuesta(respuesta, productor) do
    send(productor, respuesta)
  end




     @doc """
  Adds zeros to the start of the string to adjust properly binary string into a specific number of variables.

  ## Parameters
    - binary_str_number: String represents the number of solution variables in binary format
    - max_num_bits: Integer describes number of digits that the solution binary must have

  ## Returns
    - binary_str_number: Binary string number with appropriate amount digits according max_num_bits
  """

  @spec check_variales(String.t(), pos_integer()) :: String.t()
  def check_variales(binary_str_number, max_num_bits) do
    if String.length(binary_str_number) < max_num_bits do
      check_variales("0" <> binary_str_number, max_num_bits)
    else
      binary_str_number
    end
  end

  @doc """
  Evaluates a specific combination of boolean values against all test clauses.

  ## Parameters
    - num: Integer representing the current combination being tested
    - lists_tests: List of clauses from the CNF file
    - max_num_bits: Maximum number of bits needed to represent all combinations

  ## Returns
    - boolean: true if the combination satisfies all clauses, false otherwise
  """
 @spec eval_tests!(integer(), [String.t()], pos_integer()) :: boolean()
 def eval_tests!(num, lists_tests, max_num_bits) do
   # Obtener la lista de bits con la longitud correcta
   bools_list = Binary.int_to_bool_list(num, max_num_bits)

   # Si el tamaño no es 20, añade un bit extra (por ejemplo, 0 o false)
   if length(bools_list) != 20 do
     bools_list = bools_list ++ [false]  # O true, según sea necesario
   end

   # Ahora que la lista tiene 20 elementos, se sigue el proceso
   lists_tests
   |> Enum.reduce_while([], fn test, acc ->
     case eval_single_test!(bools_list, test) do
       true -> {:cont, [true | acc]}
       false -> {:halt, [false | acc]}
     end
   end)
   |> Enum.at(0)
 end

  @doc """
  Evaluates a single clause against a list of boolean values.
  Returns true if any variable in the clause is satisfied by the current assignment.

  The function implements a short-circuit evaluation strategy: if any variable in the clause
  evaluates to true, it immediately returns true without evaluating the rest of the variables,
  since one true value is sufficient to satisfy the entire clause.

  ## Parameters
    - bools_list: List of boolean values representing the current variable assignment
    - test: A single clause from the CNF file

  ## Returns
    - boolean: true if the clause is satisfied, false otherwise
  """
  @spec eval_single_test!(list(boolean()), [String.t()]) :: boolean()
  def eval_single_test!(bools_list, test) do
    # Converts the list of strings to a list of pairs (directives)

    # IO.puts("TEST: #{inspect(test)}")

    test
    |> Enum.map(&Directive.create_pair/1)
    |> Enum.reduce_while(
      [],
      fn directive, acc ->
        aux =
          Enum.at(bools_list, Directive.get_number(directive) - 1) ==
            Directive.get_boolean(directive)

        case aux do
          false -> {:cont, [false | acc]}
          # We no longer need to evaluate the rest of the directives if any of them return true.
          true -> {:halt, [true | acc]}
        end
      end
    )
    |> Enum.at(0)
  end


@doc """
  Extracts test clauses from the CNF file.
  Skips comment lines (starting with 'c'), the problem definition line,
  and stops when reaching the '%' character.

  ## Parameters
    - file_path: Path to the CNF file

  ## Returns
    - List of lists, where each inner list represents a clause
  """
 @spec extract_tests(String.t()) :: [String.t()]
 def extract_tests(file_content) do
   file_content
   |> String.split("\n")
   |> Enum.filter(&(!String.starts_with?(&1, "c")))  # Filtra las líneas que no empiezan con "c"
   |> Enum.drop(1)  # Elimina la primera línea
   |> Enum.take_while(&(!String.contains?(&1, "%")))  # Toma las líneas hasta encontrar una que contenga "%"
   |> Enum.map(&(String.split(&1, @white_regex) |> Enum.drop(-1)))  # Divide las líneas por el regex y elimina el último elemento
 end

  @doc """
  Retrieves and processes the first non-comment line from the CNF file.

  ## Parameters
    - file_path: Path to the CNF file
    - function: Function to process the first non-comment line

  ## Returns
    - The result of applying the given function to the first non-comment line
  """
  @spec get_first_line(String.t(), (String.t() -> any())) :: any()
  def get_first_line(file_content, function) do
    file_content
    |> String.split("\n")
    |> Enum.find(&(!String.starts_with?(&1, "c")))
    |> function.()
  end
  end




  # @spec create_bools_list(non_neg_integer(), boolean()) :: [boolean()]
  # def create_bools_list(n, boolean \\ true) when n > 0 do
  #  List.duplicate(boolean, n)
  # end

defmodule Binary do
  @moduledoc """
  Provides utility functions for converting between integers and their binary/boolean
  representations. This module is used by the SAT solver to generate all possible
  combinations of boolean values for the variables.
  """

  @doc """
  Converts an integer to its binary string representation.

  ## Parameters
    - n: Non-negative integer

  ## Returns
    - String representing the binary form of the input
  """
  @spec integer_to_binary(integer()) :: String.t()
  def integer_to_binary(0), do: "0"
  def integer_to_binary(n), do: integer_to_binary(n, "")

  defp integer_to_binary(0, acc), do: acc

  defp integer_to_binary(n, acc) do
    integer_to_binary(div(n, 2), Integer.to_string(rem(n, 2)) <> acc)
  end

  @doc """
  Converts a positive integer to binary and then maps
  every bit to a boolean, storing said booleans into a list
  """
  @spec int_to_bool_list(pos_integer()) :: list(boolean())
  def int_to_bool_list(num), do: num |> integer_to_binary() |> binary_str_to_bool_list()

  @spec int_to_bool_list(pos_integer(), non_neg_integer()) :: list(boolean())
  def int_to_bool_list(num, num_of_bits) do
    list = num |> int_to_bool_list()

    result =
      case length(list) < num_of_bits do
        false -> list
        true -> for(_ <- length(list)..(num_of_bits - 1), do: false) ++ list
      end

    result
  end

  @spec binary_str_to_bool_list(String.t()) :: list(boolean())
  def binary_str_to_bool_list(str) do
    str
    |> String.graphemes()
    |> Enum.map(fn
      "1" -> true
      "0" -> false
    end)
  end
end

defmodule Directive do
  @moduledoc """
  Represents and manipulates individual clauses from the CNF formula.
  Each directive is a tuple {boolean, integer} where:
  - boolean indicates if the variable is positive (true) or negative (false)
  - integer is the variable number

  For example, in a CNF clause "4 -18 19":
  - "4" becomes {true, 4}
  - "-18" becomes {false, 18}
  - "19" becomes {true, 19}
  """

  @type pair :: {boolean(), pos_integer()}

  @spec create_pair(String.t()) :: pair
  def create_pair(str) do
    num = str |> String.to_integer()
    {num > 0, abs(num)}
  end

  @spec get_boolean(pair) :: boolean()
  def get_boolean({bool, _num}), do: bool

  @spec get_number(pair) :: pos_integer()
  def get_number({_bool, num}), do: num

end




NodoServidor1.main()
