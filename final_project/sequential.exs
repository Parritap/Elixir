defmodule Sequential do
  # Regex que splitea por caracteres en blanco, cualquier número de estos
  @white_regex ~r/\s+/

  def main do
    file_path = System.argv() |> Enum.at(0)

    num_vars =
      get_first_line(file_path, &(&1 |> String.split(@white_regex) |> Enum.at(2)))
      |> String.to_integer()

    IO.puts(num_vars)

    num_tests =
      get_first_line(file_path, &(&1 |> String.split(@white_regex) |> Enum.at(3)))
      |> String.to_integer()

    IO.puts(num_tests)

    IO.puts("EXTRACTING TESTS---------------------------------")
    tests = extract_tests(file_path, num_vars, num_tests)
    IO.inspect(tests)
    IO.puts(length(tests))
    IO.puts("TEST EXTRACTED---------------------------------")

    # Generates a list of num_vars booleans where the variables will be stored.
    List.duplicate(false, num_vars)
    |> IO.inspect()

    # Max number of possible combinations
    max = :math.pow(2, num_vars) |> round()

    # Evaluates de test for every possible combination
    # The combination of values true and false will be given by the
    # binary representation of the number.
    # for num <- 0..max,
    #    do: eval_tests!(num, [["1", "0"], ["1", "0"]])
  end

  # @spec eval_tests!(integer(), [String.t()]) :: [boolean()]
  # def eval_tests!(num, lists_tests) do
  # end

  @spec extract_tests(String.t(), non_neg_integer(), non_neg_integer()) :: [String.t()]
  def extract_tests(file_path, num_vars, num_tests) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.filter(&(!String.starts_with?(&1, "c")))
    |> Enum.drop(1) # drops the first line, the one that says "p cnf ..."
    |> Enum.take_while(&(!String.contains?(&1, "%")))  # Stop at the line containing "%"
    |> Enum.map(&String.split(&1, @white_regex))
  end

  @spec get_first_line(String.t(), (String.t() -> any())) :: any()
  def get_first_line(file_path, function) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.find(&(!String.starts_with?(&1, "c")))
    |> function.()
  end

  @spec create_bools_list(non_neg_integer(), boolean()) :: [boolean()]
  def create_bools_list(n, boolean \\ true) when n > 0 do
    List.duplicate(boolean, n)
    List.duplicate(boolean, n)
  end
end

defmodule Binary do
  @spec integer_to_binary(integer()) :: String.t()
  def integer_to_binary(0), do: "0"
  def integer_to_binary(n), do: integer_to_binary(n, "")

  defp integer_to_binary(0, acc), do: acc

  defp integer_to_binary(n, acc) do
    integer_to_binary(div(n, 2), Integer.to_string(rem(n, 2)) <> acc)
  end

  def add_one(number) do
    number
    |> String.to_integer(2)
    |> Kernel.+(1)
  end
end

Sequential.main()
