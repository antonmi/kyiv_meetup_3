defmodule Simple.WriteSeqSpec do
  use ESpec
  alias Simple.WriteSeq

  let :path, do: Application.get_env(:telegram, :output_file)

  before do: Simple.WriteSeq.start_link(path())
  finally do: GenServer.stop(:simple_write_seq, :normal)

  describe ".run" do
    before do
      WriteSeq.run("aaaaaaaa")
      WriteSeq.run("bbbbbbb")
      :timer.sleep(100)
    end

    let_ok :content, do: File.read(path())

    it "check content" do
      content() |> should(eq"aaaaaaaa\nbbbbbbb\n")
    end
  end
end
