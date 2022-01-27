defmodule Daneordle.Guess do
  defstruct [
    guess: [],
    win?: false,
    submitted?: false
  ]

  def build(answer) do
    answer
    |> String.graphemes()
    |> Enum.map(&KrDict.Util.decompose/1)

  end

  def check(guess, answer) do
  end

  def add_letter(guess, letter) do
    
  end
end