defmodule Simple.RecomposeSpec do
  use ESpec
  alias Simple.Recompose

  before do: Simple.Recompose.start_link(10)
  finally do: GenServer.stop(:simple_recompose, :normal)

  describe ".run" do
    before do: allow(Simple.WriteSeq).to accept(:run)

    context "when line is short" do
      before do
        Recompose.run("aaa")
        Recompose.run("bbb")
      end

      it "does not call Simple.WriteSeq.run" do
        Simple.WriteSeq
        |> should_not(accepted :run)
      end

      context "when add one more" do
        before do: Recompose.run("ccccc")
        before do: :timer.sleep(100)

        it "calls Simple.WriteSeq.run" do
          Simple.WriteSeq |> should(accepted(:run, ["aaa bbb"]))
        end
      end
    end


    context "with :eof" do
      before do: Recompose.run("aaa")
      before do: Recompose.run(:eof)
      before do: Process.sleep(100)

      it "calls Simple.WriteSeq.run" do
        Simple.WriteSeq |> should(accepted(:run, ["aaa"]))
      end
    end
  end
end
