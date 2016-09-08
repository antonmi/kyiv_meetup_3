defmodule GenStage.ReadSeqSpec do
  use ESpec, async: true
  alias GenStage.ReadSeq
  alias Experimental.GenStage

  defmodule FakeDecompose do
    use Experimental.GenStage

    def init(spec_pid), do: {:consumer, spec_pid}

    def handle_events([line], _from, spec_pid) do
      send(spec_pid, line)
      {:noreply, [], spec_pid}
    end
  end

  let :input_path, do: Application.get_env(:telegram, :input_file)
  let_ok! :read_seq, do: GenStage.start_link(ReadSeq, input_path())
  let_ok! :decompose, do: GenStage.start_link(FakeDecompose, self())

  before do: GenStage.sync_subscribe(decompose(), to: read_seq(), max_demand: 1)

  finally do
    GenStage.stop(decompose())
    GenStage.stop(read_seq())
  end

  before do: Process.sleep(100)
  let :messages, do: Process.info(self())[:messages]

  it "reads file line by line" do
    Enum.at(messages(), 0) |> should(start_with "Lorem ipsum dolor sit amet")
    Enum.at(messages(), 1) |> should(start_with "Phasellus ullamcorper finibus dolor a iaculis")
  end
end
