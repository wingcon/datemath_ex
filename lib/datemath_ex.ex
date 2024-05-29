defmodule DatemathEx do
  use Combine

  alias Timex.Parse.DateTime.Parsers.ISO8601Extended

  import Timex.Parse.DateTime.Parsers, only: [iso_date: 1]

  @doc """
  Parses datemath syntax

  ## Options
  - `now`: `DateTime` struct that overwrites now
  """
  def parse(format_string, opts \\ []) do
    case Combine.parse(format_string, parser(opts)) do
      [%DateTime{} = dt] -> {:ok, dt}
      {:error, _reason} = err -> err
    end
  end

  defp parser(opts) do
    choice([
      relative(opts),
      absolute()
    ])
  end

  defp relative(opts) do
    sequence([
      string("now")|> map(fn _ -> Keyword.get(opts, :now, DateTime.utc_now())end),
      option(math_expression())
    ])
    |> map(& reduce_expressions/1)
    |> eof()
  end

  defp absolute do
    sequence([
      choice([iso_datetime(), iso_date()]),
      option(sequence([
        ignore(string("||")),
        math_expression()
      ]))
    ])
    |> map(fn
      [dt, nil] -> reduce_expressions([dt, []])
      [dt, [exprs]] -> reduce_expressions([dt, exprs])
    end)
    |> eof()
  end

  defp math_expression do
    either(
      arithmetic(),
      rounding()
    )
    |> many()
    |> map(fn expressions ->
      Enum.map(expressions, fn
        [op, amount, time_unit] -> %{operator: op, amount: amount, time_unit: time_unit}
        [time_unit] -> %{time_unit: time_unit}
      end)
    end)
  end

  defp iso_datetime do
    ISO8601Extended.parse()
    |> map(fn parsed ->
        year = Keyword.get(parsed, :year4)
        month = Keyword.get(parsed, :month)
        day = Keyword.get(parsed, :day)
        date = Date.new!(year, month, day)

        hour = Keyword.get(parsed, :hour24, 0)
        min = Keyword.get(parsed, :min, 0)
        sec = Keyword.get(parsed, :sec, 0)
        time = Time.new!(hour, min, sec)

        timezone = Keyword.get(parsed, :zname, "Etc/UTC")
        {fractional_sec, _} = Keyword.get(parsed, :sec_fractional, {0, nil})

        DateTime.new!(date, time, timezone)
        |> DateTime.shift_zone!("Etc/UTC")
        |> Timex.set(microsecond: {fractional_sec, 6})
    end)
  end

  defp iso_date do
    iso_date(nil)
    |> map(fn [[year4: year], [month: month], [day: day]] -> Date.new!(year, month, day) |> Timex.to_datetime() end)
  end

  defp arithmetic do
    sequence([
      choice([char("+"), char("-")]),
      integer(),
      time_unit()
    ])
  end

  defp rounding do
    sequence([
      ignore(char("/")),
      time_unit()
    ])
  end

  defp time_unit do
    choice([
      char("y"),
      char("M"),
      char("w"),
      char("d"),
      char("h"),
      char("H"),
      char("m"),
      char("s"),
    ])
  end

  defp reduce_expressions([dt, expressions]) when is_struct(dt, DateTime) or is_struct(dt, Date) do
    Enum.reduce(expressions, dt, fn
      %{operator: op, amount: amount, time_unit: time_unit}, acc ->
        amount = sign(amount, op)
        case time_unit do
          "y" -> Timex.shift(acc, years: amount)
          "M" -> Timex.shift(acc, months: amount)
          "w" -> Timex.shift(acc, days: amount * 7)
          "d" -> Timex.shift(acc, days: amount)
          u when u in ~w(h H) -> Timex.shift(acc, hours: amount)
          "m" -> Timex.shift(acc, minutes: amount)
          "s" -> Timex.shift(acc, seconds: amount)
        end
      %{time_unit: time_unit}, acc ->
        case time_unit do
          "y" -> DateTime.new!(Date.new!(acc.year, 1, 1), ~T/00:00:00/)
          "M" -> DateTime.new!(Date.beginning_of_month(acc), ~T/00:00:00/)
          "w" -> DateTime.new!(Date.beginning_of_week(acc), ~T/00:00:00/)
          "d" -> DateTime.new!(DateTime.to_date(acc), ~T/00:00:00/)
          u when u in ~w(h H) -> DateTime.new!(DateTime.to_date(acc), Time.new!(acc.hour, 0, 0))
          "m" -> DateTime.new!(DateTime.to_date(acc), Time.new!(acc.hour, acc.minute, 0))
          "s" -> DateTime.new!(DateTime.to_date(acc), DateTime.to_time(acc))
        end
    end)
  end

  defp sign(value, "+"), do: value
  defp sign(value, "-"), do: -value

end
