#include "parse_size_data_type.h"

#include <stdbool.h>
#include <erl_nif.h>

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
)
{
    int arity;
    const ERL_NIF_TERM *array;

    if(__builtin_expect(!enif_get_tuple(env, size_data_type, &arity, &array), false)) {
        return false;
    }

    if(__builtin_expect(arity != 3, false)) {
        return false;
    }
    ERL_NIF_TERM size_term = array[0];
    ERL_NIF_TERM data_term = array[1];
    ERL_NIF_TERM type_term = array[2];

    if(__builtin_expect(!enif_get_tuple(env, size_term, &arity, &array), false)) {
        return false;
    }
    if(__builtin_expect(arity != 2, false)) {
        return false;
    }
    ERL_NIF_TERM x_term = array[0];
    ERL_NIF_TERM y_term = array[1];

    if(__builtin_expect(!enif_get_uint64(env, x_term, x), false)) {
        return false;
    }
    if(__builtin_expect(!enif_get_uint64(env, y_term, y), false)) {
        return false;
    }

    if(__builtin_expect(!enif_inspect_binary(env, data_term, in_data), false)) {
        return false;
    }

    if(__builtin_expect(!enif_get_tuple(env, type_term, &arity, &array), false)) {
        return false;
    }
    if(__builtin_expect(arity != 2, false)) {
        return false;
    }
    type_term = array[0];
    ERL_NIF_TERM depth_term = array[1];

    if(__builtin_expect(!enif_get_tuple(env, type_term, &arity, &array), false)) {
        return false;
    }
    if(__builtin_expect(arity != 2, false)) {
        return false;
    }
    type_term = array[0];
    ERL_NIF_TERM bit_term = array[1];

    if(__builtin_expect(!enif_get_atom_length(env, type_term, type_size, ERL_NIF_LATIN1), false)) {
        return false;
    }

    (*type_size)++;
    *type = (char *)enif_alloc(sizeof(char) * *type_size);

    if(__builtin_expect(!enif_get_atom(env, type_term, *type, *type_size, ERL_NIF_LATIN1), false)) {
        return false;
    }
    if(__builtin_expect(!enif_get_uint(env, bit_term, bit), false)) {
        return false;
    }
    if(__builtin_expect(!enif_get_uint(env, depth_term, depth), false)) {
        return false;
    }
    return true;
}
