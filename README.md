# LatencyTracker

A GenServer that will periodically ping a list of hosts and write the average latency to an ETS table.

## Example:

```
iex(1)> LatencyTracker.start_link([hosts: [[hostname: "google.com", alias: :google]]])
{:ok, #PID<0.234.0>}
iex(2)> LatencyTracker.average_latency(:google)
42.7
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `latency_tracker` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:latency_tracker, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/latency_tracker>.
