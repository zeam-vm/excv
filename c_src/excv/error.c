#include "error.h"
#include <stdbool.h>
#include <string.h>
#include <erl_nif.h>

ERL_NIF_TERM make_error(ErlNifEnv *env, const char *message)
{
    ErlNifBinary reason;
    if(__builtin_expect(!enif_alloc_binary(strnlen(message, 256), &reason), false)) {
        return enif_make_atom(env, "error");
    } else {
        memcpy(reason.data, message, reason.size);
        return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_binary(env, &reason));
    }
}
