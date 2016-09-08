defmodule Simple.Telegram do
  def children do
    import Supervisor.Spec, warn: false
    [
      worker(Simple.ReadSeq, [Application.get_env(:telegram, :input_file)]),
      worker(Simple.Decompose, []),
      worker(Simple.Recompose, [Application.get_env(:telegram, :limit)]),
      worker(Simple.WriteSeq, [Application.get_env(:telegram, :output_file)])
    ]
  end

  def start do
    opts = [strategy: :one_for_one, name: Telegram.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def stop do
    Supervisor.stop(Telegram.Supervisor, :normal)
  end

  def restart do
    stop()
    start()
  end

  def run, do: do_run(Simple.ReadSeq.run)

  defp do_run(line) do
    if line == :eof do
      :eof
    else
      do_run(Simple.ReadSeq.run)
    end
  end
end
