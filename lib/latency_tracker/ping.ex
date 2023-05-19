defmodule LatencyTracker.Ping do
  def average_latency(socket, hostname, n \\ 10) do
    with {:ok, total} <- run_pings(socket, hostname, n) do
      {:ok, total / n}
    end
  end

  defp run_pings(socket, hostname, n) do
    with {:ok, addr} <- get_addr(hostname) do
      Enum.reduce_while(1..n, {:ok, 0}, fn _, {:ok, acc} ->
        do_ping = fn -> ping(socket, addr) end

        case :timer.tc(do_ping) do
          {time, :ok} ->
            ms = System.convert_time_unit(time, :microsecond, :millisecond)
            {:cont, {:ok, acc + ms}}

          {_, {:error, :timeout}} ->
            {:halt, {:error, :unreachable}}
        end
      end)
    else
      _ -> {:error, :unresolvable}
    end
  end

  defp get_addr(hostname) do
    with {:ok, {:hostent, _, _, _, _, addrs}} <-
           :inet.gethostbyname(to_charlist(hostname)) do
      {:ok, Enum.random(addrs)}
    end
  end

  defp ping(socket, addr, retries \\ 3)
  defp ping(_, _, 0), do: {:error, :timeout}

  defp ping(socket, addr, retries) do
    :ok = :gen_icmp.echoreq(socket, addr, <<0>>)

    receive do
      {:icmp, _, ^addr, {:echorep, %{data: <<0>>}}} -> :ok
    after
      10_000 -> ping(socket, addr, retries - 1)
    end
  end
end
