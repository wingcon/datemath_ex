defmodule DatemathEx do
 import NimbleParsec

 alias __MODULE__

 import DatemathEx.Helpers

  @doc """
  Parses datemath syntax

  ## Options
  - `now`: `DateTime` struct that overwrites now
  """
  @spec parse(input :: String.t(), opts :: keyword()) :: output :: {:ok, DateTime.t()}
  def parse(input, opts \\ []) do
    with {:ok, [dt], _rest, _meta, _pos, _size} <- parse_input(input, context: Map.new(opts)) do
      {:ok, dt}
    else
      {:error, reason, _input, _meta, _pos, _size} ->
        {:error, reason}
    end
  end

 defparsecp :parse_input,
  choice([
    string("now")
    |> map({:now, []})
    |> post_traverse({:overwrite_now, []})
    |> ignore_whitespace
    |> parsec(:math_expressions)
    |> eos()
    |> reduce({:reduce_expressions, []}),
    choice([
      datetime(),
      date()
    ])
    |> map({:to_datetime, []})
    |> ignore_whitespace
    |> ignore(string("||"))
    |> ignore_whitespace
    |> parsec(:math_expressions)
    |> eos()
    |> reduce({:reduce_expressions, []})
   ])


  defcombinatorp :math_expressions,
  choice([
    choice([string("+"), string("-")])
    |> ignore_whitespace
    |> integer(min: 1, max: 10)
    |> ignore_whitespace
    |> ensure_time_unit()
    |> ignore_whitespace
    |> tag(:expression),

    ignore(string("/"))
    |> ignore_whitespace
    |> ensure_time_unit()
    |> wrap()
    |> map({Enum, :join, []})
    |> tag(:round)
  ])
  |> repeat
  |> optional

    def now(_args) do
      DateTime.utc_now()
    end

    def overwrite_now(rest, [_old_now], context, _line, _offset)
      when is_map_key(context, :now) and is_struct(context.now, DateTime) do
      {rest, [context.now], context}
    end

    def overwrite_now(rest, args, context, _line, _offset) do
      {rest, args, context}
    end

    defp to_datetime([y, m, d]) do
      DateTime.new!(Date.new!(y, m, d), ~T/00:00:00.000/)
    end

    defp to_datetime([y, m, d, h, min, s]) do
      DateTime.new!(Date.new!(y, m, d), Time.new!(h, min, s, {0,3}))
    end

    defp reduce_expressions([dt|rest]) when is_struct(dt, DateTime) do
      Enum.reduce(rest, dt, fn
        {:expression, [op, amount, unit]}, acc ->
          amount = sign_value(amount, op)
          case unit do
            "y" -> Timex.shift(acc, years: amount)
            "M" -> Timex.shift(acc, months: amount)
            "w" -> Timex.shift(acc, days: amount * 7)
            "d" -> Timex.shift(acc, days: amount)
            u when u in ~w(h H) -> Timex.shift(acc, hours: amount)
            "m" -> Timex.shift(acc, minutes: amount)
            "s" -> Timex.shift(acc, seconds: amount)
          end
        {:round, [""]}, acc -> acc
        {:round, [unit]}, acc ->
          case unit do
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

    defp sign_value(value, "-"), do: -value
    defp sign_value(value, "+"), do: value

end
