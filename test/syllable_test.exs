defmodule Daneordle.SyllableTest do
  use ExUnit.Case
  alias Daneordle.Syllable

  describe "provision/1" do
    test "handles a vertically oriented two element syllable" do
      assert %Syllable{
               elements: 2,
               onset: %{guess_value: nil, correct_value: "ㄱ", orientation: :vertical},
               vowel: %{guess_value: nil, correct_value: "ㅏ", orientation: :vertical},
               coda: nil
             } = Syllable.provision("가")
    end

    test "handles a horizontally oriented two element syllable" do
      assert %Syllable{
               elements: 2,
               onset: %{guess_value: nil, correct_value: "ㄱ", orientation: :horizontal},
               vowel: %{guess_value: nil, correct_value: "ㅜ", orientation: :horizontal},
               coda: nil
             } = Syllable.provision("구")
    end

    test "handles a vertically oriented three element syllable" do
      assert %Syllable{
               elements: 3,
               onset: %{guess_value: nil, correct_value: "ㄱ", orientation: :vertical},
               vowel: %{guess_value: nil, correct_value: "ㅏ", orientation: :vertical},
               coda: %{guess_value: nil, correct_value: "ㅇ", orientation: :horizontal}
             } = Syllable.provision("강")
    end

    test "handles a horizontally oriented three element syllable" do
      assert %Syllable{
               elements: 3,
               onset: %{guess_value: nil, correct_value: "ㄱ", orientation: :horizontal},
               vowel: %{guess_value: nil, correct_value: "ㅡ", orientation: :horizontal},
               coda: %{guess_value: nil, correct_value: "ㄻ", orientation: :horizontal}
             } = Syllable.provision("긂")
    end
  end
end
