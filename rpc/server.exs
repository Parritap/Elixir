defmodule Calculadora do
  def main() do
    IO.puts("INICIÓ EL SERVIDOR")
    esperar()
  end

  defp esperar() do
    receive do
      _ -> :ok
    end
  end

  def sumar(a, b) do
    a + b
  end
end

Calculadora.main()
