defmodule GenStage.Telegram do
  alias GenStage.ReadSeq
  alias GenStage.Decompose
  alias GenStage.Recompose
  alias GenStage.WriteSeq
  alias Experimental.GenStage

  @input_path Application.get_env(:telegram, :input_file)
  @output_path Application.get_env(:telegram, :output_file)
  @limit Application.get_env(:telegram, :limit)

  def start_components do
    {:ok, _read_seq} = GenStage.start_link(ReadSeq, @input_path, name: :read_seq)
    {:ok, _decompose} = GenStage.start_link(Decompose, nil, name: :decompose)
    {:ok, _recompose} = GenStage.start_link(Recompose, @limit, name: :recompose)
    {:ok, _write_seq} = GenStage.start_link(WriteSeq, @output_path, name: :write_seq)
  end

  def subscribe do
    GenStage.sync_subscribe(:decompose, to: :read_seq, max_demand: 1)
    GenStage.sync_subscribe(:recompose, to: :decompose, max_demand: 1)
    GenStage.sync_subscribe(:write_seq, to: :recompose, max_demand: 1)
  end

  def stop_components do
    GenStage.stop(:read_seq)
    GenStage.stop(:decompose)
    GenStage.stop(:recompose)
    GenStage.stop(:write_seq)
  end

  def run do
    start_components()
    subscribe()
    # Process.sleep(:infinity)
  end

  def stop do
    stop_components()
  end
end
