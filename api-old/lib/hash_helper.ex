defmodule Mirror.HashHelper do

  @hashconfig Hashids.new([
    salt: "?d[]?a5$~<).hU%L}0k-krUz>^[xJ@Y(yAna%`-k4Hs{^=5T6@/k]PFqkJ;FlbV+",  # using a custom salt helps producing unique cipher text
    min_len: 6,   # minimum length of the cipher text (1 by default)
  ])

  def generate_unique_id(id, unique_key) do
    unique_chars = String.to_char_list(unique_key)
    Hashids.encode(@hashconfig, [id | unique_chars])
  end

end
