defmodule Simple.ReadSeq do
  use GenServer
  @name :simple_read_seq

  def start_link(path), do: GenServer.start_link(__MODULE__, path, name: @name)

  def init(path), do: File.open(path)

  def run, do: GenServer.call(@name, :run)

  def handle_call(:run, _from, file) do
    line = case IO.gets(file, false) do
      :eof -> :eof
      line -> String.trim_trailing(line)
    end
    Simple.Decompose.run(line)
    {:reply, line, file}
  end
end
