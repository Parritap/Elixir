defmodule Sequential do
  def main do
    num_vars =
    System.argv()
    # Gets the first arg which is the file path to text.
    |> Enum.at(0)
    |> extract_number_of_vars()

    num_test_cases = 

  end

  def extract_number_of_vars(file_path) do
    print_first_non_c_line(file_path)
    |> String.split(" ")
    |> Enum.at(2)
  end

  def print_first_non_c_line(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.find(&(!String.starts_with?(&1, "c")))
  end
end

Sequential.main()
