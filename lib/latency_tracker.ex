defmodule LatencyTracker do
  @moduledoc """
  A GenServer that periodcally pings a list of hosts and stores
  avg latency in an ETS table.
  """
  use GenServer
  alias LatencyTracker.Ping
  require Logger

  @host_schema [
    hostname: [
      type: :string,
      required: true,
      doc: "The hostname of the server you would like to ping."
    ],
    alias: [
      type: :atom,
      required: true,
      doc: "An alias for this host, this will be used as the key for the stored latency data."
    ]
  ]

  @options_schema [
    hosts: [
      type: {:list, {:non_empty_keyword_list, @host_schema}},
      required: true,
      doc: "A list of hosts you want to monitor latency for."
    ],
    interval: [
      type: :pos_integer,
      required: false,
      default: :timer.seconds(60),
      doc: "How often you want to update the latency for all hosts. Milliseconds."
    ],
    max_concurrency: [
      type: :pos_integer,
      required: false,
      default: 10,
      doc: "How many checks can run concurrently."
    ],
    ping_count: [
      type: :pos_integer,
      required: false,
      default: 10,
      doc: "How many pings should we perform each run before we calculate the average latency?"
    ],
    name: [
      type: :atom,
      required: false,
      default: __MODULE__
    ]
  ]

  defstruct [:hosts, :interval, :max_concurrency, :ping_count]

  @doc """
  Start a LatencyTracker GenServer.

  ### Configuration Options

  #{NimbleOptions.docs(@options_schema)}
  """
  @spec start_link(Keyword.t()) ::
          GenServer.on_start() | {:error, NimbleOptions.ValidationError.t()}
  def start_link(opts) do
    with {:ok, valid_opts} <- NimbleOptions.validate(opts, @options_schema) do
      GenServer.start_link(__MODULE__, valid_opts, name: valid_opts[:name])
    end
  end

  @impl GenServer
  def init(opts) do
    state = %__MODULE__{
      hosts: opts[:hosts],
      interval: opts[:interval],
      max_concurrency: opts[:max_concurrency],
      ping_count: opts[:ping_count]
    }

    :ets.new(__MODULE__, [:public, :named_table, :set, read_concurrency: true])
    run(state)
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:run, state) do
    run(state)
    {:noreply, state}
  end

  @doc "Query the stored average latency for a host alias"
  def average_latency(alias), do: :ets.lookup_element(__MODULE__, alias, 2)

  defp run(state) do
    Task.async_stream(
      state.hosts,
      fn host ->
        with {:ok, socket} <- :gen_icmp.open() do
          Process.link(socket)

          case Ping.average_latency(socket, host[:hostname], state.ping_count) do
            {:ok, avg} ->
              Process.exit(socket, :normal)
              :ets.insert(__MODULE__, {host[:alias], avg})

            {:error, reason} ->
              Logger.warn("Latency tracking of #{host[:hostname]} failed, reason: #{reason}")
          end
        end
      end,
      max_concurrency: state.max_concurrency
    )
    |> Stream.run()

    Process.send_after(self(), :run, state.interval)
  end
end
