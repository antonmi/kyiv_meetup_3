defmodule GenStage.WriteSeqSpec do
  use ESpec, async: true
  alias GenStage.WriteSeq
  alias Experimental.GenStage

  defmodule FakeRecompose do
    use Experimental.GenStage

    def init(line), do: {:producer, line}

    def handle_demand(_demand, line), do: {:noreply, [line], line}
  end

  let :line, do: "Phasellus ullamcorper finibus dolor a iaculis"
  let :output_path, do: Application.get_env(:telegram, :output_file)
  let_ok! :recompose, do: GenStage.start_link(FakeRecompose, line())
  let_ok! :write_seq, do: GenStage.start_link(WriteSeq, output_path())

  before do: GenStage.sync_subscribe(write_seq(), to: recompose(), max_demand: 1)
  
  finally do
    GenStage.stop(write_seq())
    GenStage.stop(recompose())
  end

  before do: Process.sleep(100)
  let_ok! :file, do: File.open(output_path())
  let :first_line, do: IO.gets(file(), false)

  it "reads file line by line" do
    first_line() |> should(eq "Phasellus ullamcorper finibus dolor a iaculis\n")
  end
end
