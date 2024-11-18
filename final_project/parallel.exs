defmodule Sequential do
  # Regex que splitea por caracteres en blanco, cualquier número de estos
  @white_regex ~r/\s+/
  #@clause_regex ~r/\s*(-?\d+(?:\s+-?\d+)*)\s*0\s*/

  @moduledoc """
  A brute-force SAT solver implementation in Elixir that evaluates all possible combinations
  of boolean variables to find a satisfying assignment for a given CNF formula.

  The solver reads CNF formulas from files in DIMACS-like format, where:
  - Lines starting with 'c' are comments
  - The first non-comment line 'p cnf vars clauses' specifies the number of variables and clauses
  - Each subsequent line represents a clause with space-separated integers and ending with 0
  - Positive integers represent variables, negative integers represent their negation
  - The file ends when a '%' character is found

  Example of a CNF file format:
  ```
  c Example CNF file
  p cnf 3 2
  1 -2 3 0
  -1 2 -3 0
  %
  ```
  """

  # Solutions to uf20-01.cnf
  #   0 1 1 1 0 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 = 466543
  #   1 0 0 0 0 1 0 0 0 0 0 0 1 1 1 0 1 0 0 1 = 540905
  #   1 0 0 0 0 1 0 0 1 0 0 0 0 1 1 0 1 0 0 1 = 542825
  #   1 0 0 0 0 1 0 0 1 0 0 0 1 1 1 0 1 0 0 1 = 542953
  #   1 0 0 1 0 0 0 0 0 1 0 0 1 1 1 0 1 0 0 1 = 591081
  #   1 0 0 1 0 0 0 1 0 1 0 0 1 1 1 0 1 0 0 1 = 595177
  #   1 0 0 1 0 1 0 0 0 0 0 0 1 1 1 0 1 0 0 1 = 606441
  #   1 0 0 1 0 1 0 0 0 1 0 0 1 1 1 0 1 0 0 1 = 607465
  #

  def main do
    # IMPORTANTE -> DEBE ESPECIFICARSE EL ARCHIVO .CNF COMO PRIMER ARGUMENTO DEL PROGRAMA POR LA LINEA DE COMANDOS
    file_path = System.argv() |> Enum.at(0)

    num_vars =
      get_first_line(file_path, &(&1 |> String.split(@white_regex) |> Enum.at(2)))
      |> String.to_integer()

    IO.puts("NUM_VARS: #{num_vars}")

    IO.puts("EXTRACTING TESTS---------------------------------")
    tests_lists = extract_tests(file_path)

    for test <- tests_lists do
      IO.inspect(test)
    end

    IO.puts(length(tests_lists))
    IO.puts("TESTS EXTRACTED---------------------------------")

    # Max number of possible combinations
    max = :math.pow(2, num_vars) |> round()
    max_num_bits = (max - 1) |> Binary.integer_to_binary() |> String.length()
    IO.puts("MAX: #{max} and MAX_NUM_BITS: #{max_num_bits}")

    num_tasks = 4  # Dividimos en 4 hilos para este ejemplo, puedes cambiarlo
    chunk_size = div(max, num_tasks)

    results = evaluate_in_parallel(0, chunk_size, num_tasks, tests_lists, max_num_bits)

    # Flag variable evaluates de test for every possible combination
    # The combination of values true and false will be given by the
    # binary representation of the number.

    # A for loop returns a list. If any of the results is truthty, then the flag will be true.
    flag = Enum.any?(results, & &1)

    # Final output
    if !flag do
      IO.puts("PROBLEM UNSATISFIABLE")
    end
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
  Evalúa combinaciones en paralelo usando `Task`.
  retorna una lista de valores booleanos de acuerdo a la cantidad de hilos que hicieron la tarea,
  es decir que si la tarea se dividio en 4 hilos, se retorna una lista de 4 valores booleanos
  """
  defp evaluate_in_parallel(start, chunk_size, num_tasks, tests_lists, max_num_bits) do
    0..(num_tasks - 1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        from = start + i * chunk_size
        to = from + chunk_size - 1
        evaluate_range(from, to, tests_lists, max_num_bits)
      end)
    end)
    |> Enum.map(&Task.await(&1, 100000))
  end

  @doc """
  Evalúa un rango de combinaciones y retorna true si encuentra una solución.
  """
  defp evaluate_range(from, too, tests_lists, max_num_bits) do
    results =
      for num <- from..too do
        result = eval_tests!(num, tests_lists, max_num_bits)

        if result do
          variables_solution =
            Integer.to_string(num, 2)
            |> check_variales(max_num_bits)

          IO.puts("SATISFIABLE with #{num} in binary form: #{variables_solution}")
        end

        result
      end

    Enum.any?(results)
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
    bools_list = Binary.int_to_bool_list(num, max_num_bits)
    # representation of num based on list of bools
    # IO.puts("NUMBER IS #{num}--------------------------------------")
    # IO.puts("BOOLS_LIST: #{inspect(bools_list)}")

    if length(bools_list) != 20,
      do: raise("Length of bools_list is not 20, current size is #{length(bools_list)}
      with number #{num}")

    lists_tests
    |> Enum.reduce_while([], fn test, acc ->
      case eval_single_test!(bools_list, test) do
        true -> {:cont, [true | acc]}
        false -> {:halt, [false | acc]}
      end
    end)
    # Returns the last element to be appended to the list, i.e. the halt value.
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
  @spec extract_tests(String.t()) :: [[String.t()]]
  def extract_tests(file_path) do
    file_path
    |> File.read!()
    |> String.split(~r/\s+0(?=\s|-)|(?<=\s)0(?=\d)/)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(Regex.match?(~r/^-?\d+(\s+-?\d+)*$/, &1)))
    |> Enum.map(&String.split(&1, @white_regex))
  end


  # @spec extract_tests(String.t()) :: [String.t()]
  # def extract_tests(file_path) do
  #   file_path
  #   |> File.read!()
  #   |> String.split("\n")
  #   |> Enum.filter(&(!String.starts_with?(&1, "c")))
  #   |> Enum.drop(1)
  #   |> Enum.take_while(&(!String.contains?(&1, "%")))
  #   |> Enum.map(&(String.split(&1, @white_regex) |> Enum.drop(-1)))
  # end

  @doc """
  Retrieves and processes the first non-comment line from the CNF file.

  ## Parameters
    - file_path: Path to the CNF file
    - function: Function to process the first non-comment line

  ## Returns
    - The result of applying the given function to the first non-comment line
  """
  @spec get_first_line(String.t(), (String.t() -> any())) :: any()
  def get_first_line(file_path, function) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.find(&(!String.starts_with?(&1, "c")))
    |> function.()
  end

  # @spec create_bools_list(non_neg_integer(), boolean()) :: [boolean()]
  # def create_bools_list(n, boolean \\ true) when n > 0 do
  #  List.duplicate(boolean, n)
  # end
end

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

Sequential.main()
