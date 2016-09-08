defmodule GenStage.DecomposeSpec do
  use ESpec, async: true
  alias GenStage.Decompose
  alias Experimental.GenStage

  defmodule FakeReadSeq do
    use Experimental.GenStage

    def init(line), do: {:producer, line}

    def handle_demand(_demand, line), do: {:noreply, [line], line}
  end

  defmodule FakeRecompose do
    use Experimental.GenStage

    def init(spec_pid), do: {:consumer, spec_pid}

    def handle_events([word], _from, spec_pid) do
      send(spec_pid, word)
      {:noreply, [], spec_pid}
    end
  end

  let :line, do: "Lorem ipsum dolor sit amet"
  let_ok! :read_seq, do: GenStage.start_link(FakeReadSeq, line())
  let_ok! :decompose, do: GenStage.start_link(Decompose, nil)
  let_ok! :recompose, do: GenStage.start_link(FakeRecompose, self())

  before do
    GenStage.sync_subscribe(decompose(), to: read_seq(), max_demand: 1)
    GenStage.sync_subscribe(recompose(), to: decompose(), max_demand: 1)
  end

  finally do
    GenStage.stop(recompose())
    GenStage.stop(decompose())
    GenStage.stop(read_seq())
  end

  before do: Process.sleep(100)
  let :messages, do: Process.info(self())[:messages]

  it "reads file line by line" do
    Enum.at(messages(), 0) |> should(start_with "Lorem")
    Enum.at(messages(), 1) |> should(start_with "ipsum")
  end
end
