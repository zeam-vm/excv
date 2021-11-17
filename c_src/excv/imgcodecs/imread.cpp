#include "imread.h"
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

#include <erl_nif.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

bool excv_imread(
    size_t file_size,
    char *file,
    uint64_t *x,
    uint64_t *y,
    uint_fast16_t *depth,
    uint_fast16_t *element_size,
    enum return_type *type,
    void **data,
    const char **error_message
)
{
    try {
        std::string file_name = file;
        cv::Mat mat = cv::imread(file_name);
        *x = mat.cols;
        *y = mat.rows;
        *depth = mat.elemSize();

        int t = mat.type();
        if(t == CV_8S || t == CV_8SC1 || t == CV_8SC2 || t == CV_8SC3 || t == CV_8SC4) {
            *element_size = 1;
            *type = INT;
        } else if(t == CV_8U || t == CV_8UC1 || t == CV_8UC2 || t == CV_8UC3 || t == CV_8UC4) {
            *element_size = 1;
            *type = UINT;
        } else if(t == CV_16S || t == CV_16SC1 || t == CV_16SC2 || t == CV_16SC3 || t == CV_16SC4) {
            *element_size = 2;
            *type = INT;
        } else if(t == CV_16U || t == CV_16UC1 || t == CV_16UC2 || t == CV_16UC3 || t == CV_16UC4) {
            *element_size = 2;
            *type = UINT;
        } else if(t == CV_32S || t == CV_32SC1 || t == CV_32SC2 || t == CV_32SC3 || t == CV_32SC4) {
            *element_size = 4;
            *type = INT;
        } else if(t == CV_32F || t == CV_32FC1 || t == CV_32FC2 || t == CV_32FC3 || t == CV_32FC4) {
            *element_size = 4;
            *type = FLOAT;
        } else if(t == CV_64F || t == CV_64FC1 || t == CV_64FC2 || t == CV_64FC3 || t == CV_64FC4) {
            *element_size = 8;
            *type = FLOAT;
        } else {
            *error_message = "imread: unknown type";
            return false;
        }

        cv::Mat outMat;
        switch(*depth) {
            case 3:
            cv::cvtColor(mat, outMat, cv::COLOR_BGR2RGB);
            break;
            case 4:
            cv::cvtColor(mat, outMat, cv::COLOR_BGRA2RGBA);
            break;
            default:
            return false;
        }

        mat.release();

        size_t size = *x * *y * *depth * *element_size;

        *data = enif_alloc(size);
        if(__builtin_expect(*data == NULL, false)) {
            *error_message = "imread: memory allocation error";
            return false;
        }
        memcpy(*data, outMat.ptr(), size);
        return true;
    } catch(const cv::Exception& ex) {
        *error_message = ex.what();
        return false;
    }
}
