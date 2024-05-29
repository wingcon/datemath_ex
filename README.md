# DatemathEx

A parsers for [datemath syntax](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/common-options.html#date-math).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `datemath_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:datemath_ex, "~> 0.2.0"}
  ]
end
```

## Usage
```elixir
iex(1)> DatemathEx.parse "2020-01-01||+1d"
{:ok, ~U[2020-01-02 00:00:00.000Z]}

iex(2)> DatemathEx.parse "2020-01-01T12:00:00||+31d+2h"
{:ok, ~U[2020-02-01 14:00:00.000000Z]}

iex(3)> DatemathEx.parse "now-1000s/h"                 
{:ok, ~U[2024-05-16 08:00:00Z]}

iex(4)> DatemathEx.parse "2020-01-01T12:00:00+02:00"                 
{:ok, ~U[2020-01-01 10:00:00.000000Z]}

iex(5)> DatemathEx.parse "now*1h"     
 {:error, "Expected at least one parser to succeed at line 1, column 0."}
```