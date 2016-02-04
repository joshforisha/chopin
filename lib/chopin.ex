defmodule Chopin do
  defp perform(source, destination, layout \\ nil) do
    if File.dir?(source) do
      if File.exists?(destination) && !File.dir?(destination) do
        exit("Destination #{destination} is already a regular file.")
      end

      unless File.dir?(destination) do
        File.mkdir(destination)
        IO.puts " #{IO.ANSI.green}+ #{destination}/#{IO.ANSI.reset}"
      end

      layout_path = "#{source}/layout.eex"
      if File.exists?(layout_path), do: layout = layout_path

      {:ok, files} = File.ls(source)
      Enum.map(files, fn(file) ->
        perform("#{source}/#{file}", "#{destination}/#{file}", layout)
      end)
    else
      cond do
        String.ends_with?(source, ".eex")
        && !String.ends_with?(source, "layout.eex") ->
          dest_file = String.replace_suffix(destination, ".eex", ".html")
          File.write!(dest_file, EEx.eval_file(source))
          IO.puts " #{IO.ANSI.blue}> #{dest_file}#{IO.ANSI.reset}"

        String.ends_with?(source, ".md") ->
          if is_nil(layout), do: exit("No layout available for #{source}.")
          File.write!(destination, Earmark.to_html(EEx.eval_file(layout,
            [yield: File.read!(source)]
          )))
          IO.puts " #{IO.ANSI.magenta}> (#{layout}) > #{destination}#{IO.ANSI.reset}"

        true ->
          File.cp(source, destination)
          IO.puts " #{IO.ANSI.green}> #{destination}#{IO.ANSI.reset}"
      end
    end
  end

  def main(args) do
    [source, destination] = args
    unless File.dir?(source), do: exit("Source #{source} is not a directory.")
    IO.puts "Source: #{source}/"
    perform(source, destination)
  end
end
