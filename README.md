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

```elixir
def deps do
  [
    {:latency_tracker, github: "AppMonet/latency_tracker"}
  ]
end
```

Unfortunately we cannot publish this library to Hex as it depends on `hauleth/gen_icmp` which is not published on hex and that name is already taken.

The icmp libraries that are on hex require more complex configuration/settings in order to use, for example `:icmp` requires: `sudo setcap cap_net_raw=+ep /path/to/beam.smp`
