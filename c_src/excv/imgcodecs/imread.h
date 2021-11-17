#ifndef EXCV_IMREAD_H
#define EXCV_IMREAD_H

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

enum return_type {
    INT,
    UINT,
    FLOAT,
};

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
);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // EXCV_IMREAD_H