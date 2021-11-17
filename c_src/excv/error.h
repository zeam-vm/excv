#ifndef EXCV_ERROR_H
#define EXCV_ERROR_H

#include <erl_nif.h>

ERL_NIF_TERM make_error(ErlNifEnv *env, const char *message);

#endif // EXCV_ERROR_H
