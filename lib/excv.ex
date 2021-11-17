defmodule Excv do
  @moduledoc """
  Excv (Elixir Computer Vision) is a bridge between OpenCV and Nx.
  """

  @spec imwrite(Nx.Tensor.t() | list(), Path.t(), Keyword.t()) ::
          :ok | :error | {:error, String.t()}
  defdelegate imwrite(img, file, options \\ []), to: Excv.Imgcodecs

  @spec imread(Path.t(), Keyword.t()) ::
          {:ok, Nx.Tensor.t() | list()} | {:error, String.t()}
  defdelegate imread(file, options \\ []), to: Excv.Imgcodecs
end
