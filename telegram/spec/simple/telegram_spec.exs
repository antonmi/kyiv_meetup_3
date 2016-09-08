defmodule Simple.TelegramSpec do
  use ESpec
  alias Simple.Telegram

  before do
    Telegram.start()
    Telegram.run()
    Process.sleep(100)
    Telegram.stop()
  end

  let_ok :output_content, do: File.read(Application.get_env(:telegram, :output_file))

  it "checks output" do
    output_content() |> should(start_with "Lorem ipsum")
    output_content() |> should(end_with "ac tortor.\n")
    line = output_content() |> String.split("\n") |> hd()
    String.length(line) |> should(be :<, Application.get_env(:telegram, :limit))
  end
end
