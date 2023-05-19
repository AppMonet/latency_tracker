defmodule LatencyTracker.PingTest do
  use ExUnit.Case, async: true
  alias LatencyTracker.Ping

  test "can ping google.com" do
    {:ok, socket} = :gen_icmp.open()
    assert {:ok, avg} = Ping.average_latency(socket, "google.com")
    assert is_number(avg)
  end

  test "returns error for unresolvabled host" do
    {:ok, socket} = :gen_icmp.open()
    assert {:error, :unresolvable} = Ping.average_latency(socket, "this.is.invalid")
  end
end
