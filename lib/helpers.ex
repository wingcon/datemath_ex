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
    |> map({:to_datetime, []})
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
    |> map({:to_datetime, []})
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

  def to_datetime([y, m, d]) do
    with {:ok, date} <- Date.new(y, m, d),
      {:ok, datetime} <- DateTime.new(date, ~T/00:00:00.000/) do
        datetime
    else
      error -> error
    end
  end

  def to_datetime([y, m, d, h, min, s]) do
    with {:ok, date} <- Date.new(y, m, d),
      {:ok, time} <- Time.new(h, min, s, {0,3}),
    {:ok, datetime} <- DateTime.new(date, time) do
      datetime
    else
      error -> error
    end
  end

end
