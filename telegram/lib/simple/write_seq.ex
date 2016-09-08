defmodule Simple.WriteSeq do
  use GenServer
  @name :simple_write_seq

  def start_link(path), do: GenServer.start_link(__MODULE__, path, name: @name)

  def init(path), do: File.open(path, [:write])

  def run(line), do: GenServer.cast(@name, {:run, line})

  def handle_cast({:run, line}, file) do
    IO.puts(file, line)
    {:noreply, file}
  end
end
