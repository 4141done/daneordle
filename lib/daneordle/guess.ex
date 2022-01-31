defmodule Daneordle.Guess do
  alias Daneordle.Syllable

  defstruct syllables: [],
            position: 0,
            max_position: 0,
            full?: false,
            # :unsubmitted_full, :submitted_wrong, :submitted_not_word, :submitted_win
            status: :unsubmitted

  def build(answer) do
    syllables =
      answer
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {syllable, idx}, acc ->
        Map.put(acc, idx, Syllable.provision(syllable))
      end)

    %__MODULE__{syllables: syllables, max_position: Enum.count(syllables) - 1}
  end

  def submit(%__MODULE__{status: status} = guess, _correct_answer)
      when status in [:unsubmitted, :submitted_wrong, :submitted_not_word, :submitted_win] do
    guess
  end

  def submit(%__MODULE__{status: :unsubmitted_full, syllables: syllables} = guess, correct_answer) do
    if in_dictionary?(guess) do
      element_lookup = word_to_element_lookup(correct_answer)

      checked_syllables =
        syllables
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {syllable, idx}, acc ->
          checked_syllable = Syllable.check(syllable, element_lookup)
          Map.put(acc, idx, checked_syllable)
        end)

      new_status =
        checked_syllables
        |> Enum.all?(fn syllable -> syllable.correct? end)
        |> if do
          :submitted_win
        else
          :submitted_wrong
        end

      struct(guess, syllables: checked_syllables, status: new_status)
    else
      struct(guess, status: :submitted_not_word)
    end
  end

  def add_element_guess(%__MODULE__{full?: true} = guess, _element) do
    guess
  end

  def add_element_guess(
        %__MODULE__{syllables: syllables, position: position, max_position: max_position} = guess,
        element
      ) do
    # TODO: we're not getting to the last element of the syllable
    IO.puts("GETTING syllable at position: #{position}")

    case Map.get(syllables, position) do
      %Syllable{full: false} = syllable ->
        IO.inspect(syllable, label: "add #{element} to syllable: #{inspect(syllable)}")
        %{full: syllable_full?} = new_syllable = Syllable.add_element_guess(syllable, element)
        IO.puts("syllable full?: #{syllable_full?} and current position: #{position}")

        new_position =
          if syllable_full? and position < max_position do
            position + 1
          else
            position
          end

        # TODO: need too either get rid of full? and use all status, or add a complementary item
        struct(guess,
          position: new_position,
          syllables: Map.put(syllables, position, new_syllable),
          full?: syllable_full? and position == max_position
        )
        |> IO.inspect(label: :struct_after_add_element)

      %Syllable{full: true} ->
        new_guess = struct(guess, position: position + 1)
        add_element_guess(new_guess, element)
    end
  end

  def remove_element_guess(%__MODULE__{syllables: syllables, position: position} = guess) do
    syllable = Map.get(syllables, position)
    new_syllable = Syllable.remove_element_guess(syllable)

    if syllable == new_syllable and position > 0 do
      remove_element_guess(struct(guess, position: position - 1))
    else
      struct(guess,
        syllables: Map.put(syllables, position, new_syllable),
        position: position,
        full?: false
      )
    end
  end

  def in_dictionary?(%__MODULE__{syllables: syllables}) do
    syllables
    |> Enum.map(&Syllable.to_string/1)
    |> Enum.join()
    |> MyDict.find()
    |> is_binary()
  end

  defp word_to_element_lookup(word) do
    {:ok, element_list} = KrDict.Util.Word.to_hangul_array(word)

    element_list
    |> MapSet.new()
  end
end
