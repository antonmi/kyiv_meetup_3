defmodule GenStage.Recompose do
  use Experimental.GenStage

  def init(limit) do
    {:producer_consumer, %{buffer: nil, limit: limit}}
  end

  def handle_events([word], _from, %{buffer: buffer, limit: limit}) do
    string = if buffer, do: "#{buffer} #{word}", else: word
    # :timer.sleep(100)
    {lines, new_buffer} = if String.length(string) >= limit do
      {[buffer], word}
    else
      {[], string}
    end

    {:noreply, lines, %{buffer: new_buffer, limit: limit}}
  end
end
