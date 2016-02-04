defmodule Chopin do
  defp perform(source, destination, layout \\ nil) do
    if File.dir?(source) do
      if File.exists?(destination) && !File.dir?(destination) do
        exit("#{destination} is already a regular file.")
      end

      unless File.dir?(destination) do
        File.mkdir(destination)
        IO.puts " #{IO.ANSI.green}create#{IO.ANSI.reset} #{destination}/"
      end

      layout_path = "#{source}/layout.eex"
      if File.exists?(layout_path), do: layout = layout_path

      {:ok, files} = File.ls(source)
      Enum.map(files, fn(file) ->
        perform("#{source}/#{file}", "#{destination}/#{file}", layout)
      end)
    else
      cond do
        String.ends_with?(source, ".eex") ->
          unless String.ends_with?(source, "layout.eex") do
            if is_nil(layout), do: exit("No layout available for #{source}.")
            dest_file = String.replace_suffix(destination, ".eex", ".html")
            File.write!(dest_file, EEx.eval_file(layout,
              [yield: EEx.eval_file(source)]
            ))
            IO.puts " #{IO.ANSI.magenta}parse#{IO.ANSI.reset} (using #{layout}) -> #{dest_file}"
          end

        String.ends_with?(source, ".md") ->
          if is_nil(layout), do: exit("No layout available for #{source}.")
          dest_file = String.replace_suffix(destination, ".md", ".html")
          File.write!(dest_file, EEx.eval_file(
            layout,
            [yield: Earmark.to_html(File.read!(source))]
          ))
          IO.puts " #{IO.ANSI.magenta}parse#{IO.ANSI.reset} (using #{layout}) -> #{dest_file}"

        String.starts_with?(source, ".") ->
          IO.puts " #{IO.ANSI.red}ignore#{IO.ANSI.reset} #{source}"

        true ->
          File.cp(source, destination)
          IO.puts " #{IO.ANSI.blue}copy#{IO.ANSI.reset} #{destination}"
      end
    end
  end

  def main(args) do
    [source, destination] = args
    unless File.dir?(source), do: exit("#{source} is not a directory.")
    IO.puts "Source: #{source}/"
    perform(source, destination)
  end
end
