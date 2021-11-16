#include "imwrite.h"
#include <opencv2/core/mat.hpp>
#include <opencv2/core/hal/interface.h>
#include <opencv2/core/cvstd.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

extern "C" bool excv_imwrite_u8(
    size_t file_size,
    char *file,
    uint64_t x,
    uint64_t y,
    uint_fast16_t depth,
    uint8_t *data
)
{
    std::string file_name = file;
    cv::Mat inMat = cv::Mat(y, x, CV_8UC(depth), data);
    cv::Mat outMat;
    switch(depth) {
        case 3:
        cv::cvtColor(inMat, outMat, cv::COLOR_RGB2BGR);
        break;
        case 4:
        cv::cvtColor(inMat, outMat, cv::COLOR_RGBA2BGRA);
        break;
        default:
        return false;
    }
    cv::imwrite(file_name, outMat);
    return true;
}