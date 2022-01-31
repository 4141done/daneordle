defmodule Daneordle.Board do
  alias Daneordle.Guess

  # Zero indexed
  @max_guesses 4
  # status can be :playing, :win, :lose
  defstruct status: :playing, guesses: %{}, guess_number: 0, answer: nil

  def build(answer) do
    guesses =
      Daneordle.Guess.build(answer)
      |> List.duplicate(5)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {guess, idx}, acc ->
        Map.put(acc, idx, guess)
      end)

    %__MODULE__{
      guesses: guesses,
      answer: answer
    }
  end

  def input(%__MODULE__{guesses: guesses, guess_number: guess_number} = board, element) do
    new_guess =
      Map.get(guesses, guess_number)
      |> Guess.add_element_guess(element)

    struct(board, guesses: Map.put(guesses, guess_number, new_guess))
  end

  def backspace(%__MODULE__{guesses: guesses, guess_number: guess_number} = board) do
    new_guess =
      Map.get(guesses, guess_number)
      |> Guess.remove_element_guess()

    struct(board, guesses: Map.put(guesses, guess_number, new_guess))
  end

  def submit_guess(
        %__MODULE__{guesses: guesses, guess_number: guess_number, answer: answer} = board
      ) do
    guesses
    |> Map.get(guesses, guess_number)
    |> Guess.submit(answer)
    |> case do
      %{status: :submitted_win} = guess ->
        struct(board, status: :win, guesses: Map.put(guesses, guess_number, guess))

      %{status: :submitted_wrong} = guess ->
        if guess_number == @max_guesses do
          struct(board, status: :lose, guesses: Map.put(guesses, guess_number, guess))
        else
          struct(board,
            guesses: Map.put(guesses, guess_number, guess),
            guess_number: guess_number + 1
          )
        end

      %{status: :submitted_not_word} = guess ->
        struct(board, guesses: Map.put(guesses, guess_number, guess))
    end
  end
end
