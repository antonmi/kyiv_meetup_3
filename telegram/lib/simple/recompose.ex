defmodule Simple.Recompose do
  use GenServer
  @name :simple_recompose

  def start_link(limit), do: GenServer.start_link(__MODULE__, %{limit: limit}, name: @name)

  def init(state), do:  {:ok, Map.put(state, :buffer, nil)}

  def run(word), do: GenServer.cast(@name, {:run, word})

  def handle_cast({:run, :eof}, %{buffer: buffer, limit: limit}) do
    Simple.WriteSeq.run(buffer)

    {:noreply, %{buffer: nil, limit: limit}}
  end

  def handle_cast({:run, word}, %{buffer: buffer, limit: limit}) do
    string = if buffer, do: "#{buffer} #{word}", else: word
    # Process.sleep(100)

    buffer = if String.length(string) >= limit do
      Simple.WriteSeq.run(buffer)
      word
    else
      string
    end

    {:noreply, %{buffer: buffer, limit: limit}}
  end
end
