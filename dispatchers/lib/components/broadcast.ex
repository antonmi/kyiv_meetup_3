defmodule Components.Broadcast do
  use Experimental.GenStage

  def init(_state) do
    {
      :producer_consumer,
      nil,
      dispatcher: Experimental.GenStage.BroadcastDispatcher
    }
  end

  def handle_events([line], _from, nil) do
    {:noreply, [line], nil}
  end
end
