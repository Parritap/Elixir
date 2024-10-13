defmodule Sequential do
  # Regex que splitea por caracteres en blanco, cualquier número de estos
  @white_regex ~r/\s+/

  def main do
    file_path = System.argv() |> Enum.at(0)

    num_vars = get_first_line(file_path, &(&1 |> String.split(@white_regex) |> Enum.at(2)))
    IO.puts(vars)

    num_tests = get_first_line(file_path, &(&1 |> String.split(@white_regex) |> Enum.at(3)))
    IO.puts(num_tests)
  end

  @spec get_first_line(String.t(), (String.t() -> any())) :: any()
  def get_first_line(file_path, function) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.find(&(!String.starts_with?(&1, "c")))
    |> function.()
  end
end

Sequential.main()
