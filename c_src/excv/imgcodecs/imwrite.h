#ifndef EXCV_IMWRITE_H
#define EXCV_IMWRITE_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

bool excv_imwrite_u8(
    size_t file_size,
    char *file,
    uint64_t x,
    uint64_t y,
    uint_fast16_t depth,
    uint8_t *data
);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // EXCV_IMWRITE_H