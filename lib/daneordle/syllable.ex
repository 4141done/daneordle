defmodule Daneordle.Syllable do
  import KrDict.Util.Hangul, only: [is_valid_hangul: 1]
  @states [:unguessed, :wrong_location, :correct, :absent]

  # There's a known dializer bug that causes a warning when you add a MapSet as a module attribute
  @dialyzer {:no_opaque, provision: 1}
  @horizontal_vowels MapSet.new(["ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅘ", "ㅙ", "ㅚ", "ㅝ", "ㅞ", "ㅟ", "ㅢ"])

  # TODO: consider just storing a KrDict.Util.Hanguel struct here and pulling the orientation and status elsewhere
  # We may not need to store the correct value?  No it's easier since we can check the answer for "corect"s
  # Then with the correct answer, just flag them as "present but elsewhere"
  defstruct elements: 2,
            coda: %{
              guess_value: nil,
              correct_value: nil,
              orientation: :horizontal,
              state: nil
            },
            onset: %{guess_value: nil, correct_value: nil, orientation: :vertical, state: nil},
            vowel: %{guess_value: nil, correct_value: nil, orientation: :vertical, state: nil},
            full?: false,
            correct?: false,
            next: :onset

  def provision(binary_syllable) when is_valid_hangul(binary_syllable) do
    case KrDict.Util.Hangul.decompose(binary_syllable) do
      {:ok, %{coda: nil, onset: onset, vowel: vowel}} ->
        general_orientation =
          if MapSet.member?(@horizontal_vowels, vowel), do: :horizontal, else: :vertical

        %__MODULE__{
          elements: 2,
          onset: %{guess_value: nil, correct_value: onset, orientation: general_orientation},
          vowel: %{guess_value: nil, correct_value: vowel, orientation: general_orientation},
          coda: nil
        }

      {:ok, %{coda: coda, onset: onset, vowel: vowel}} ->
        general_orientation =
          if MapSet.member?(@horizontal_vowels, vowel), do: :horizontal, else: :vertical

        %__MODULE__{
          elements: 3,
          onset: %{guess_value: nil, correct_value: onset, orientation: general_orientation},
          vowel: %{guess_value: nil, correct_value: vowel, orientation: general_orientation},
          coda: %{guess_value: nil, correct_value: coda, orientation: :horizontal}
        }

      _ ->
        raise "invalid input for syllable"
    end
  end

  def check(%__MODULE__{} = syllable, lookup) do
    syllable
    |> IO.inspect(label: :da_syl)
    |> check_onset(lookup)
        |> IO.inspect(label: :after_onset_set)
    |> check_vowel(lookup)
    |> IO.inspect(label: :after_vowel_set)
    |> check_coda(lookup)
    |> IO.inspect(label: :after_coda_set)
    |> set_correctness()
    |> IO.inspect(label: :after_set_correctness)
  end

  def to_string(%__MODULE__{
        onset: %{guess_value: onset},
        vowel: %{guess_value: vowel},
        coda: nil}) do
    %KrDict.Util.Hangul{onset: onset, vowel: vowel, coda: nil}
    |> KrDict.Util.Hangul.compose()
  end

  def to_string(%__MODULE__{
        onset: %{guess_value: onset},
        vowel: %{guess_value: vowel},
        coda: %{guess_value: coda}
      }) do
    %KrDict.Util.Hangul{onset: onset, vowel: vowel, coda: coda}
    |> KrDict.Util.Hangul.compose()
  end

  # TODO: add guards to make sure we're adding the correct type (vowels in vowel, consonants in coda or onset position)
  def add_element_guess(%__MODULE__{full?: true} = existing, _guess) do
    existing
  end

  def add_element_guess(%__MODULE__{next: :onset, onset: onset} = existing, guess) do
    new_onset = Map.put(onset, :guess_value, guess)
    struct(existing, next: :vowel, onset: new_onset)
  end

  def add_element_guess(%__MODULE__{next: :vowel, elements: 2, vowel: vowel} = existing, guess) do
    new_vowel = Map.put(vowel, :guess_value, guess)
    struct(existing, next: nil, vowel: new_vowel, full?: true)
  end

  def add_element_guess(%__MODULE__{next: :vowel, elements: 3, vowel: vowel} = existing, guess) do
    new_vowel = Map.put(vowel, :guess_value, guess)
    struct(existing, next: :coda, vowel: new_vowel)
  end

  def add_element_guess(%__MODULE__{next: :coda, elements: 3, coda: coda} = existing, guess) do
    new_coda = Map.put(coda, :guess_value, guess)
    struct(existing, next: nil, coda: new_coda, full?: true)
  end

  def remove_element_guess(%__MODULE__{next: :onset} = existing) do
    existing
  end

  def remove_element_guess(%__MODULE__{full?: true, elements: 2, vowel: vowel} = existing) do
    new_vowel = Map.put(vowel, :guess_value, nil)
    struct(existing, next: :vowel, vowel: new_vowel, full?: false)
  end

  def remove_element_guess(%__MODULE__{next: :vowel, onset: onset} = existing) do
    new_onset = Map.put(onset, :guess_value, nil)
    struct(existing, next: :onset, onset: new_onset)
  end

  def remove_element_guess(%__MODULE__{full?: true, elements: 3, coda: coda} = existing) do
    new_coda = Map.put(coda, :guess_value, nil)
    struct(existing, next: :coda, coda: new_coda, full?: false)
  end

  def remove_element_guess(%__MODULE__{next: :coda, elements: 3, vowel: vowel} = existing) do
    new_vowel = Map.put(vowel, :guess_value, nil)
    struct(existing, next: :vowel, vowel: new_vowel, full?: false)
  end

  defp check_onset(%__MODULE__{onset: %{guess_value: onset_val, correct_value: onset_val}} = syllable, _lookup) do
    set_status(syllable, :onset, :correct)
  end

  defp check_onset(%__MODULE__{onset: %{guess_value: onset_val}} = syllable, lookup) do
    status =
      if MapSet.member?(lookup, onset_val) do
        :wrong_location
      else
        :absent
      end

    set_status(syllable, :onset, status)
  end

  defp check_vowel(%__MODULE__{vowel: %{guess_value: vowel_val, correct_value: vowel_val}} = syllable, _lookup) do
    set_status(syllable, :vowel, :correct)
  end

  defp check_vowel(%__MODULE__{vowel: %{guess_value: vowel_val}} = syllable, lookup) do
    status =
      if MapSet.member?(lookup, vowel_val) do
        :wrong_location
      else
        :absent
      end

    set_status(syllable, :vowel, status)
  end

  defp check_coda(%__MODULE__{coda: nil} = syllable, _lookup) do
    syllable
  end

  defp check_coda(%__MODULE__{coda: %{guess_value: coda_val, correct_value: coda_val}} = syllable, _lookup) do
    set_status(syllable, :coda, :correct)
  end

  defp check_coda(%__MODULE__{coda: %{correct_value: nil}} = syllable, _lookup) do
    syllable
  end

  defp check_coda(%__MODULE__{coda: %{guess_value: coda_val}} = syllable, lookup) do
    status =
      if MapSet.member?(lookup, coda_val) do
        :wrong_location
      else
        :absent
      end

    set_status(syllable, :coda, status)
  end

  defp set_status(%__MODULE__{onset: onset} = syllable, :onset, status) do
    struct(syllable, onset: Map.put(onset, :status, status))
  end

  defp set_status(%__MODULE__{vowel: vowel} = syllable, :vowel, status) do
    struct(syllable, vowel: Map.put(vowel, :status, status))
  end

  defp set_status(%__MODULE__{coda: coda} = syllable, :coda, status) do
    struct(syllable, coda: Map.put(coda, :status, status))
  end

  def set_correctness(
        %{
          onset: %{status: :correct},
          vowel: %{status: :correct},
          coda: %{status: :correct},
          full?: true
        } = syllable
      ) do
    IO.puts "setting correctness true"
    struct(syllable, correct?: true)
  end

  def set_correctness(syllable) do
    IO.puts "setting correctness false"
    struct(syllable, correct?: false)
  end
end
