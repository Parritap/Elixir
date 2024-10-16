defmodule Sequential do
  # Regex que splitea por caracteres en blanco, cualquier número de estos
  @white_regex ~r/\s+/

  def main do
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

    # Generates a list of num_vars booleans where the variables will be stored.
    List.duplicate(false, num_vars)
    |> IO.inspect()

    # Max number of possible combinations
    max = :math.pow(2, num_vars) |> round()
    max_num_bits = max |> Binary.integer_to_binary() |> String.length()
    IO.puts("MAX: #{max}")

    # Evaluates de test for every possible combination
    # The combination of values true and false will be given by the
    # binary representation of the number.
    flag = false

    results =
      for num <- 0..(max-1) do
        result = eval_tests!(num, tests_lists, max_num_bits)

        if result do
          IO.puts("SATISFIABLE with #{num} in binary form: #{Binary.integer_to_binary(num)}")
        end

        result
      end

    # A for loop returns a list. If any of the results is truthty, then the flag will be true.
    flag = Enum.any?(results, & &1)

    # Final output
    if flag do
      IO.puts("SATISFIABLE")
    else
      IO.puts("UNSATISFIABLE")
    end
  end

  @spec eval_tests!(integer(), [String.t()], pos_integer()) :: boolean()
  def eval_tests!(num, lists_tests, max_num_bits) do

    # representation of num based on list of bools
    bools_list = Binary.int_to_bool_list(num, max_num_bits)
    #IO.puts("NUMBER IS #{num}--------------------------------------")
    #IO.puts("BOOLS_LIST: #{inspect(bools_list)}")


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

  # FOCUS
  @spec eval_single_test!(list(boolean()), [String.t()]) :: boolean()
  def eval_single_test!(bools_list, test) do
    # Converts the list of strings to a list of pairs (directives)

    #IO.puts("TEST: #{inspect(test)}")

    test
    |> Enum.map(&Directive.create_pair/1)
    |> Enum.reduce_while(
      [],
      fn directive, acc ->
        aux =
          Enum.at(bools_list, Directive.get_number(directive) - 1) == Directive.get_boolean(directive)

        case aux do
          false -> {:cont, [false | acc]}
          # We no longer need to evaluate the rest of the directives if any of them return true.
          true -> {:halt, [true | acc]}
        end
      end
    )
    |> Enum.at(0)
  end

  @spec extract_tests(String.t()) :: [String.t()]
  def extract_tests(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.filter(&(!String.starts_with?(&1, "c")))
    |> Enum.drop(1)
    |> Enum.take_while(&(!String.contains?(&1, "%")))
    |> Enum.map(&String.split(&1, @white_regex) |> Enum.drop(-1))
  end

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
    padding = for _ <- length(list)..(num_of_bits - 1), do: false
    padding ++ list
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
  This is nothing more than my own data structure to store a single directive of the SAT problem
  Given a test case like this: 4 -18 19 0, a directive would be [4] or [-18], where the sign and
  the number is store in a tuple like this: {true, 4} for "4" and {false, 18} for "-18".
  """

  @type pair :: {boolean(), pos_integer()}

  @spec create_pair(boolean(), pos_integer()) :: pair
  def create_pair(bool, num) when is_boolean(bool) and is_integer(num) and num > 0 do
    {bool, num}
  end

  @spec create_pair(String.t()) :: pair
  def create_pair(str) do
    num = str |> String.to_integer()
    {num > 0, abs(num)}
  end

  @spec get_boolean(pair) :: boolean()
  def get_boolean({bool, _num}), do: bool

  @spec get_number(pair) :: pos_integer()
  def get_number({_bool, num}), do: num

  @spec increment_number(pair) :: pair
  def increment_number({bool, num}), do: {bool, num + 1}

  @spec flip_boolean(pair) :: pair
  def flip_boolean({bool, num}), do: {!bool, num}

  @spec process_pair(pair) :: String.t()
  def process_pair({true, num}) when num > 10 do
    "High true value: #{num}"
  end

  def process_pair({false, num}) when num <= 10 do
    "Low false value: #{num}"
  end

  def process_pair(pair) do
    "Other case: #{inspect(pair)}"
  end

  @spec pair_to_list(pair) :: [boolean() | pos_integer()]
  def pair_to_list(pair), do: Tuple.to_list(pair)
end

Sequential.main()
