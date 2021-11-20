defmodule Excv.Imgcodecs do
  require Logger

  @moduledoc """
  Imgcodecs correspond to "opencv2/imgcodecs.hpp".
  """

  @typep im_read_result ::
           {{pos_integer(), pos_integer(), pos_integer()}, {atom(), pos_integer()}, binary()}

  @on_load :load_nif

  @doc false
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

  * `img`(`Nx.Tensor` or list of `Nx.Tensor`): image or images to be saved.
  * `file`(String): Path of the file.
  * `options`(Keyword list): Format-specific parameters. (To be implemented)
  """
  @spec imwrite(Nx.Tensor.t() | list(), Path.t(), Keyword.t()) ::
          :ok | :error | {:error, String.t()}
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
      {{x, y}, Nx.to_binary(img), {type, d}},
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

  @doc false
  @spec im_write_nif(list() | tuple(), binary(), list()) :: :ok | :error
  def im_write_nif(_size_data_type, _path, _options) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
  Loads an image from a file.

  The function `imread` loads an image from the specified file and returns a tuple of `:ok` and it.
  If the image cannot be read (because of missing file, improper permissions, unsupported or invalid format),
  the function returns a tuple of `:error` and reason if available.

  Currently, the following file formats are supported:

  * Windows bitmaps - `*.bmp`, `*.dib` (always supported)
  * JPEG files - `*.jpeg`, `*.jpg`, `*.jpe` (see the *Note* section)
  * JPEG 2000 files - `*.jp2` (see the Note section)
  * Portable Network Graphics - `*.png` (see the *Note* section)
  * WebP - `*.webp` (see the *Note* section)
  * Portable image format - `*.pbm`, `*.pgm`, `*.ppm` `*.pxm`, `*.pnm` (always supported)
  * Sun rasters - `*.sr`, `*.ras` (always supported)
  * TIFF files - `*.tiff`, `*.tif` (see the *Note* section)
  * OpenEXR Image files - `*.exr` (see the *Note* section)
  * Radiance HDR - `*.hdr`, `*.pic` (always supported)
  * Raster and Vector geospatial data supported by GDAL (see the *Note* section)

  ## Note

  * The function determines the type of an image by the content, not by the file extension.
  * In the case of color images, the decoded images will have the channels stored in **R G B** order instead of **B G R** order in OpenCV.
  * When using `grayscale: true`, the codec's internal grayscale conversion will be used, if available. Results may differ to the output of `Excv.Imgproc.cvtColor/4`.
  * On Microsoft Windows\* OS and macOS\*, the codecs shipped with an OpenCV image (`libjpeg`, `libpng`, `libtiff`, and `libjasper`) are used by default.
    So, Excv can always read JPEGs, PNGs, and TIFFs.
    On macOS, there is also an option to use native macOS image readers.
    But beware that currently these native image loaders give images with different pixel values because of the color management embedded into macOS.
  * On Linux\*, BSD flavors and other Unix-like open-source operating systems, Excv looks for codecs supplied with an OS image.
    Install the relevant packages (do not forget the development files, for example, "libjpeg-dev", in Debian\* and Ubuntu\*)
    to get the codec support or turn on the `OPENCV_BUILD_3RDPARTY_LIBS` flag in CMake when building OpenCV.
  * In the case you set `WITH_GDAL` flag to true in CMake and `load_GDAL: true` to load the image,
    then the `GDAL` driver will be used in order to decode the image, supporting the following formats: `Raster`, `Vector`.
  * If EXIF information is embedded in the image file, the EXIF orientation will be taken into account and thus the image will be rotated
    accordingly except if the flags `ignore_orientation: true` or `unchanged: true` are passed.
  * By default number of pixels must be less than $2^30$. Limit can be set using system variable `OPENCV_IO_MAX_IMAGE_PIXELS`

  ## Parameters

  * `file`: Path of the file to be loaded.
  * `options`: (To be implemented)
  """
  @spec imread(Path.t(), Keyword.t()) ::
          {:ok, Nx.Tensor.t() | list()} | {:error, String.t()}
  def imread(file, options \\ []) do
    case im_read_nif(Path.absname(file), options) do
      {:ok, result} -> {:ok, parse_result_im_read(result)}
      :error -> {:error, :no_reason}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  @spec im_read_nif(Path.t(), Keyword.t()) ::
          {:ok, im_read_result() | list(im_read_result())} | :error | {:error, String.t()}
  def im_read_nif(_path, _options) do
    :erlang.nif_error(:nif_not_loaded)
  end

  defp parse_result_im_read({shape, type, data}) do
    Nx.from_binary(data, type) |> Nx.reshape(shape)
  end
end
