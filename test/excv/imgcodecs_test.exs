defmodule Excv.ImgcodecsTest do
  use ExUnit.Case
  doctest Excv.Imgcodecs

  describe "imwrite bmp" do
    test "size = {1, 1}, light purple" do
      img = Nx.tensor([[[0x9F, 0x5A, 0xAE]]], type: {:u, 8})
      file = "/tmp/test_1_1.bmp"
      result = Excv.Imgcodecs.imwrite(img, file)

      assert result == :ok
      assert File.exists?(file) == true

      {file_str, file_exit} = System.cmd("file", [file])

      assert file_exit == 0
      assert String.match?(file_str, ~r/PC bitmap/) == true

      {ok_error, binary} = File.read(file)

      assert ok_error == :ok

      assert binary ==
               <<66, 77, 58, 0, 0, 0, 0, 0, 0, 0, 54, 0, 0, 0, 40, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0,
                 0, 1, 0, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 174, 90, 159, 0>>

      case File.rm(file) do
        :ok -> :ok
        _ -> :ok
      end
    end

    test "size = {3, 2}" do
      img =
        Nx.tensor(
          [
            [
              [0x9F, 0x5A, 0xAE],
              [0x00, 0x00, 0x00],
              [0x00, 0x00, 0x00]
            ],
            [
              [0xFF, 0xFF, 0xFF],
              [0xFF, 0xFF, 0xFF],
              [0x9F, 0x5A, 0xAE]
            ]
          ],
          type: {:u, 8}
        )

      file = "/tmp/test_3_2.bmp"
      result = Excv.Imgcodecs.imwrite(img, file)

      assert result == :ok
      assert File.exists?(file) == true

      {file_str, file_exit} = System.cmd("file", [file])

      assert file_exit == 0
      assert String.match?(file_str, ~r/PC bitmap/) == true

      {ok_error, binary} = File.read(file)

      assert ok_error == :ok

      assert binary ==
               <<66, 77, 78, 0, 0, 0, 0, 0, 0, 0, 54, 0, 0, 0, 40, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0,
                 0, 1, 0, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 255, 255, 255, 255, 255, 255, 174, 90, 159, 0, 0, 0, 174, 90, 159, 0, 0, 0,
                 0, 0, 0, 0, 0, 0>>

      case File.rm(file) do
        :ok -> :ok
        _ -> :ok
      end
    end
  end

  describe "imread and imwrite" do
    test "png random image" do
      img_expected = Nx.random_uniform({256, 256, 3}, 0, 256, type: {:u, 8})
      file = "/tmp/test_random_256_256.png"
      result = Excv.Imgcodecs.imwrite(img_expected, file)

      assert result == :ok
      assert File.exists?(file) == true

      {file_str, file_exit} = System.cmd("file", [file])

      assert file_exit == 0
      assert String.match?(file_str, ~r/PNG image data/) == true

      img_actual =
        case Excv.Imgcodecs.imread(file) do
          {:ok, img} -> img
          _ -> :error
        end

      assert img_expected == img_actual

      case File.rm(file) do
        :ok -> :ok
        _ -> :ok
      end
    end
  end
end
