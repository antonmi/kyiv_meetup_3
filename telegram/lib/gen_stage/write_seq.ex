defmodule GenStage.WriteSeq do
  use Experimental.GenStage

  def init(path) do
    {:ok, file} = File.open(path, [:write])
    {:consumer, file}
  end

  def handle_events([line], _from, file) do
    # IO.inspect(line)
    # Process.sleep(100)
    IO.puts(file, line)
    {:noreply, [], file}
  end
end
