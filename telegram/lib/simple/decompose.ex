defmodule Simple.Decompose do
  use GenServer
  @name :simple_decompose

  def start_link, do: GenServer.start_link(__MODULE__, nil, name: @name)

  def run(line), do: GenServer.cast(@name, {:run, line})

  def handle_cast({:run, :eof}, nil) do
    Simple.Recompose.run(:eof)
    {:noreply, nil}
  end

  def handle_cast({:run, line}, nil) do
    line
    |> String.split()
    |> Enum.each(&Simple.Recompose.run(&1))

    {:noreply, nil}
  end
end
