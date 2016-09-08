defmodule GenStage.ReadSeq do
  use Experimental.GenStage

  def init(path) do
    {:ok, file} = File.open(path)
    {:producer, file}
  end

  def handle_demand(_demand, file) do
    lines = case IO.gets(file, false) do
      :eof -> []
      line -> [String.trim_trailing(line)]
    end
    {:noreply, lines, file}
  end
end
