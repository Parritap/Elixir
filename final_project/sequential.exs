defmodule Sequential do

  @vars

  def main do
    System.argv() #Gets args
    |> Enum.at(0) #Gets the first arg which is the file path to text.
    |> File.read!()
    |> String.split("\n")
    |> Enum.each(&IO.inspect(&1))
  end

  def extract_number_of_vars(file_path) do
    File.read!(file_path)
    |> String.split("\n")
    |> Enum.each(&IO.inspect(&1))
  end
end

Sequential.main()
