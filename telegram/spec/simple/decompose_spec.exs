defmodule Simple.DecomposeSpec do
  use ESpec
  alias Simple.Decompose

  before do: Simple.Decompose.start_link
  finally do: GenServer.stop(:simple_decompose)

  describe ".run" do
    before do: allow(Simple.Recompose).to accept(:run)

    context  "with line" do
      before do: Decompose.run("qqq www")
      before do: :timer.sleep(100)

      it "calls Recompose for each word" do
        Simple.Recompose |> should(accepted(:run, :any, count: 2))
        Simple.Recompose |> should(accepted(:run, ["qqq"]))
        Simple.Recompose |> should(accepted(:run, ["www"]))
      end
    end

    context "with Leof" do
      before do: Decompose.run(:eof)
      before do: :timer.sleep(100)

      it "calls Recompose with :eof" do
        Simple.Recompose |> should(accepted(:run, [:eof]))
      end
    end
  end
end
