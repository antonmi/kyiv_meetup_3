defmodule GenStage.RecomposeSpec do
  use ESpec, async: true
  alias GenStage.Recompose
  alias Experimental.GenStage

  defmodule FakeDecompose do
    use Experimental.GenStage

    def init(word), do: {:producer, word}

    def handle_demand(_demand, word), do: {:noreply, [word], word}
  end

  defmodule FakeWriteSeq do
    use Experimental.GenStage

    def init(spec_pid), do: {:consumer, spec_pid}

    def handle_events([line], _from, spec_pid) do
      send(spec_pid, line)
      {:noreply, [], spec_pid}
    end
  end

  let :word, do: "Lorem"
  let :limit, do: 20

  let_ok! :decompose, do: GenStage.start_link(FakeDecompose, word())
  let_ok! :recompose, do: GenStage.start_link(Recompose, limit())
  let_ok! :write_seq, do: GenStage.start_link(FakeWriteSeq, self())

  before do
    GenStage.sync_subscribe(recompose(), to: decompose(), max_demand: 1)
    GenStage.sync_subscribe(write_seq(), to: recompose(), max_demand: 1)
  end

  finally do
    GenStage.stop(write_seq())
    GenStage.stop(recompose())
    GenStage.stop(decompose())
  end

  before do: Process.sleep(100)
  let! :messages, do: Process.info(self())[:messages]

  it "sends three words " do
    hd(messages()) |> should(eq "Lorem Lorem Lorem")
  end
end
