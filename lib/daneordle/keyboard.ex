defmodule Daneordle.Keyboard do
  @states [:unguessed, :wrong_location, :correct, :absent]

  @consonants [
    ㄱ: :unguessed, ㄴ: :unguessed, ㄷ: :unguessed, ㄹ: :unguessed, ㅁ: :unguessed, ㅂ: :unguessed, ㅅ: :unguessed, ㅇ: :unguessed, ㅈ: :unguessed, ㅊ: :unguessed,
    ㅋ: :unguessed, ㅌ: :unguessed, ㅍ: :unguessed, ㅎ: :unguessed, ㄲ: :unguessed, ㄸ: :unguessed, ㅃ: :unguessed, ㅆ: :unguessed, ㅉ: :unguessed
  ]

  @vowels [
    ㅏ: :unguessed, ㅑ: :unguessed, ㅓ: :unguessed, ㅕ: :unguessed, ㅗ: :unguessed, ㅛ: :unguessed, ㅜ: :unguessed,
    ㅠ: :unguessed, ㅡ: :unguessed, ㅣ: :unguessed, ㅐ: :unguessed, ㅒ: :unguessed, ㅔ: :unguessed, ㅖ: :unguessed,
    ㅘ: :unguessed, ㅙ: :unguessed, ㅚ: :unguessed, ㅝ: :unguessed, ㅞ: :unguessed, ㅟ: :unguessed, ㅢ: :unguessed
  ]

  @complex_codas [ㅀ: :unguessed, ㄻ: :unguessed]

  # TODO, What about compound 받짐

  defstruct [
    consonants: @consonants,
    vowels: @vowels,
    complex_codas: @complex_codas,
    functions: %{"⏎" => :unguessed, "⌫" => :unguessed}
  ]
end