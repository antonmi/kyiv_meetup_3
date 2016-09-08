defmodule GenStage.Decompose do
  use Experimental.GenStage

  def init(_state) do
    {:producer_consumer, nil}
  end

  def handle_events([line], _from, nil) do
    words = String.split(line)
    {:noreply, words, nil}
  end
end
