defmodule LatencyTrackerTest do
  use ExUnit.Case, async: false
  doctest LatencyTracker

  test "does not start if invalid opts provided" do
    assert {:error, %NimbleOptions.ValidationError{}} = LatencyTracker.start_link(junk: :config)
  end

  test "updates ets value every time interval elapses" do
    opts = [hosts: [[hostname: "google.com", alias: :google]], interval: :timer.seconds(1)]
    start_supervised!({LatencyTracker, opts})
    avg = LatencyTracker.average_latency(:google)
    assert is_number(avg)
    Process.sleep(:timer.seconds(2))
    assert avg != LatencyTracker.average_latency(:google)
  end

  @tag capture_log: true
  test "logs a warning when latency tracking fails" do
    opts = [hosts: [[hostname: "invalid.domain", alias: :invalid]], interval: :timer.seconds(1)]
    start_supervised!({LatencyTracker, opts})
  end
end
