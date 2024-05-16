defmodule DatemathExTest do
  use ExUnit.Case
  doctest DatemathEx

  @basic_math [
    %{
      in:  "2014-11-18||+1y",
      out: ~U"2015-11-18T00:00:00.000Z",
    },
		%{
			in:  "2014-11-18||-2y",
			out: ~U"2012-11-18T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||+3M",
			out: ~U"2015-02-18T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||-1M",
			out: ~U"2014-10-18T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||+1w",
			out: ~U"2014-11-25T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||-3w",
			out: ~U"2014-10-28T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||+22d",
			out: ~U"2014-12-10T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||-423d",
			out: ~U"2013-09-21T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18T13:00:00||+13h",
			out: ~U"2014-11-19T02:00:00.000Z",
		},
		%{
			in:  "2014-11-18T13:00:00||-1h",
			out: ~U"2014-11-18T12:00:00.000Z",
		},
		%{
			in:  "2014-11-18T14:27:32||+60s",
			out: ~U"2014-11-18T14:28:32.000Z",
		},
		%{
			in:  "2014-11-18T14:27:32||-3600s",
			out: ~U"2014-11-18T13:27:32.000Z",
		},
		%{
			in:  "2014-11-19T14:27:32||/w",
			out: ~U"2014-11-17T00:00:00.000Z",
		},
		%{
			in:  "2014-11-01T14:27:32||/w",
			out: ~U"2014-10-27T00:00:00.000Z",
		},
		%{
			in:  "2014-11-15T14:27:32||/d",
			out: ~U"2014-11-15T00:00:00.000Z",
		},
  ]

  @multiple_adjustments [
    %{
			in:  "2014-11-18||+1M-1M",
			out: ~U"2014-11-18T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||+1M-1m",
			out: ~U"2014-12-17T23:59:00.000Z",
		},
		%{
			in:  "2014-11-18||-1m+1M",
			out: ~U"2014-12-17T23:59:00.000Z",
		},
		%{
			in:  "2014-11-18||+1M/M",
			out: ~U"2014-12-01T00:00:00.000Z",
		},
		%{
			in:  "2014-11-18||+1M/M+1h",
			out: ~U"2014-12-01T01:00:00.000Z",
		}
  ]

  @now [
    %{
			now: ~U"2014-11-18T14:27:32.000Z",
			in:  "now",
			out: ~U"2014-11-18T14:27:32.000Z",
		},
		%{
			now: ~U"2014-11-18T14:27:32.000Z",
			in:  "now+1M",
			out: ~U"2014-12-18T14:27:32.000Z",
		},
		%{
			now: ~U"2014-11-18T14:27:32.000Z",
			in:  "now/m",
			out: ~U"2014-11-18T14:27:00.000Z",
		},
  ]

  test "basic math" do
    for %{in: input, out: out} <- @basic_math do
      {:ok, dt}  = DatemathEx.parse input
      assert DateTime.compare(out, dt) == :eq
    end
  end

  test "multiple adjustments" do
    for %{in: input, out: out} <- @multiple_adjustments do
			{:ok, dt}  = DatemathEx.parse input
      assert DateTime.compare(out, dt) == :eq
    end
  end

  test "now" do
    for %{now: now, in: input, out: out} <- @now do
			{:ok, dt}  = DatemathEx.parse(input, now: now)
      assert DateTime.compare(out, dt) == :eq
    end
  end

  test "weekday" do
    {:ok, dt}  = DatemathEx.parse "2020-03-12||/w"
    assert DateTime.compare(~U"2020-03-09T00:00:00Z", dt) == :eq
  end
end
