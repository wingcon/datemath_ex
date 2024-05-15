defmodule DatemathEx.Helpers do
  import NimbleParsec

  def ignore_whitespace(combinator) do
    combinator
    |> concat(
      ascii_string([?\s], min: 1)
      |> repeat()
      |> ignore
      |> optional()
    )
  end

  def date do
    integer(4)
    |> ignore(choice([string("-"), string(".")]))
    |> integer(2)
    |> ignore(choice([string("-"), string(".")]))
    |> integer(2)
    |> wrap()
  end

  def datetime do
    integer(4)
    |> ignore(choice([string("-"), string(".")]))
    |> integer(2)
    |> ignore(choice([string("-"), string(".")]))
    |> integer(2)
    |> ignore(string("T"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
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
