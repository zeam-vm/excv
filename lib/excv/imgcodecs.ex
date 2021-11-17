defmodule Excv.Imgcodecs do
  require Logger

  @moduledoc """
  Imgcodecs correspond to "opencv2/imgcodecs.hpp".
  """

  @on_load :load_nif

  def load_nif do
    nif_file = '#{Application.app_dir(:excv, "priv/libexcv")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @doc """
  Saves an image to a specified file.

  The function `imwrite` saves the image to the specified file. The image format is chosen based on the filename extension.
  In general, only 8-bit single-channel or 3-channel (with 'RGB' channel order) images can be saved using this function,
  with these exceptions:

  * 16-bit unsigned (`CV_16U`) images can be saved in the case of PNG, JPEG 2000, and TIFF formats
  * 32-bit float (`CV_32F`) images can be saved in PFM, TIFF, OpenEXR, and Radiance HDR formats;
    3-channel (`CV_32FC3`) TIFF images will be saved using the LogLuv high dynamic range encoding (4 bytes per pixel)
  * PNG images with an alpha channel can be saved using this function.
    To do this, create 8-bit (or 16-bit) 4-channel image RGBA, where the alpha channel goes last.
    Fully transparent pixels should have alpha set to 0,
    fully opaque pixels should have alpha set to 255/65535.
  * Multiple images (list of `Nx.t()`) can be saved in TIFF format.

  If the image format is not supported, the image will be converted to 8-bit unsigned (`CV_8U`) and saved that way.

  Note that the order of colors in a pixel is different from OpenCV, that is, 'RGB' instead of 'BRG',
  and the order of arguments is also different, that is, `img`, `file`, and `options` instead of `file`, `img` and `options`.

  If the format, depth or channel order is different, use `Excv.Nx.convertTo/4` and `Excv.Imgproc.cvtColor/4` to convert it
  before saving.
  Or, use the universal `File` functions to save the image to XML or YAML format.

  ## Parameters

  `img`: (Nx.Tensor or list of Nx.Tensor) image or images to be saved.
  `file`: Path of the file.
  `options`: (Keyword list) Format-specific parameters. (To be implemented)
  """
  @spec imwrite(Nx.Tensor.t() | list(), Path.t(), list()) :: :ok | :error | {:error, String.t()}
  def imwrite(img, file, options \\ [])

  def imwrite(img, file, options) when is_struct(img, Nx.Tensor) do
    im_write_sub(img, Nx.type(img), Path.absname(file), options)
  end

  def imwrite(imgs, file, options) when is_list(imgs) do
    imgs
    |> Enum.map(&if is_number(&1), do: Nx.tensor([&1]), else: &1)
    |> Enum.map(
      &unless is_struct(&1, Nx.Tensor),
        do:
          raise(FunctionClauseError,
            message: "no function clause matching in Excv.Imgcodecs.imwrite/3"
          )
    )

    im_write_sub_list(imgs, Enum.map(imgs, &Nx.type(&1)), Path.absname(file), options)
  end

  defp im_write_sub(img, type, path, options) do
    {y, x, d} = Nx.shape(img)

    im_write_nif(
      {{x, y}, img.data.state, {type, d}},
      path,
      options
    )
  end

  defp im_write_sub_list(imgs, types, path, options) do
    shapes = Enum.map(imgs, fn img -> Nx.shape(img) end)
    sizes = Enum.map(shapes, fn {y, x, _} -> {x, y} end)
    data = Enum.map(imgs, fn img -> img.data.state end)
    ds = Enum.map(shapes, fn {_, _, d} -> d end)

    im_write_nif(
      Enum.zip([sizes, data, Enum.zip(types, ds)]),
      path,
      options
    )
  end

  @spec im_write_nif(list() | tuple(), binary(), list()) :: :ok | :error
  def im_write_nif(size_data_type, _path, _options) do
    IO.inspect(size_data_type)
    :erlang.nif_error(:nif_not_loaded)
  end
end
