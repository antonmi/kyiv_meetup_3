defmodule Components.Split do
  use Experimental.GenStage

  def init(_state) do
    {
      :producer_consumer,
      nil,
      dispatcher: { Experimental.GenStage.PartitionDispatcher,
                    partitions: 2,
                    hash: &split/2 }
    }
  end

  def split(line, _number_of_partitions) do
    {line, rem(String.length(line), 2)}
  end

  def handle_events([line], _from, nil) do
    {:noreply, [line], nil}
  end
end
