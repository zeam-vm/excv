#ifndef PARSE_SIZE_DATA_TYPE_H
#define PARSE_SIZE_DATA_TYPE_H

#include <stdbool.h>
#include <erl_nif.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

bool parse_size_data_type(
    ErlNifEnv *env, 
    ERL_NIF_TERM size_data_type, 
    ErlNifUInt64 *x, 
    ErlNifUInt64 *y,
    ErlNifBinary *in_data,
    char **type,
    unsigned int *type_size,
    unsigned int *bit,
    unsigned int *depth
);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // PARSE_SIZE_DATA_TYPE_H
