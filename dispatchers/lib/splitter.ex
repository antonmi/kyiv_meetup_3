defmodule Splitter do
  alias Components.Split
  alias Components.ReadSeq
  alias Components.WriteSeq
  alias Experimental.GenStage

  @input_path Application.get_env(:dispatchers, :input_file)
  @output_path_1 Application.get_env(:dispatchers, :splitter_output_file_1)
  @output_path_2 Application.get_env(:dispatchers, :splitter_output_file_2)

  def start_components do
    {:ok, _read_seq} = GenStage.start_link(ReadSeq, @input_path, name: :read_seq)
    {:ok, _broadcast} = GenStage.start_link(Split, nil, name: :split)
    {:ok, _write_seq_1} = GenStage.start_link(WriteSeq, @output_path_1, name: :write_seq_1)
    {:ok, _write_seq_2} = GenStage.start_link(WriteSeq, @output_path_2, name: :write_seq_2)
  end

  def subscribe do
    GenStage.sync_subscribe(:split, to: :read_seq, max_demand: 1)
    GenStage.sync_subscribe(:write_seq_1, to: :split, partition: 0, max_demand: 1)
    GenStage.sync_subscribe(:write_seq_2, to: :split, partition: 1, max_demand: 1)
  end

  def stop_components do
    GenStage.stop(:read_seq)
    GenStage.stop(:split)
    GenStage.stop(:write_seq_1)
    GenStage.stop(:write_seq_2)
  end

  def run do
    start_components()
    subscribe()
  end

  def stop do
    stop_components()
  end
end
