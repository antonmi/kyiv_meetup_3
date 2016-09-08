defmodule Simple.ReadSeqSpec do
  use ESpec
  alias Simple.ReadSeq

  before do: Simple.ReadSeq.start_link(Application.get_env(:telegram, :input_file))
  finally do: GenServer.stop(:simple_read_seq, :normal)

  describe ".run" do
    it "reads line" do
      ReadSeq.run() |> should(start_with "Lorem ipsum dolor sit amet")
    end

    context "when reads all the file" do
      before do: Enum.each((1..100), fn(_i) -> ReadSeq.run() end)

      it "returns :eof" do
        ReadSeq.run() |> should(eq :eof)
      end
    end
  end
end
