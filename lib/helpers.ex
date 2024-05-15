defmodule DatemathEx.Helpers do
  import NimbleParsec

  def delimiter(combinator) do
    combinator
    |> ignore(choice([
      string("-"),
      string("/"),
      string(".")
    ]))
  end

  def date do
    integer(4)
    |> delimiter()
    |> integer(2)
    |> delimiter()
    |> integer(2)
    |> wrap()
  end

  @spec ensure_time_unit(NimbleParsec.t()) :: NimbleParsec.t()
  def ensure_time_unit(combinator) do
    combinator
    |> choice([
      string("y"),
      string("M"),
      string("w"),
      string("d"),
      string("h"),
      string("H"),
      string("m"),
      string("s"),
    ])
  end

end
