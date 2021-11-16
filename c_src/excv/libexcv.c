#include <stdbool.h>
#include <string.h>
#include <erl_nif.h>
#include "parse_size_data_type.h"
#include "imgcodecs/imwrite.h"

static ERL_NIF_TERM im_write_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 3, false)) {
        return enif_make_badarg(env);
    }

    ErlNifBinary path_binary_tmp;
    if(__builtin_expect(!enif_inspect_binary(env, argv[1], &path_binary_tmp), false)) {
        return enif_make_badarg(env);
    }

    ErlNifBinary path_binary;
    if(__builtin_expect(!enif_alloc_binary(path_binary_tmp.size + 1, &path_binary), false)) {
        return enif_make_badarg(env);
    }
    memcpy(path_binary.data, path_binary_tmp.data, path_binary_tmp.size);
    path_binary.data[path_binary_tmp.size] = 0;

    ERL_NIF_TERM result;

    if(enif_is_list(env, argv[0])) {
        // argv[0] is a list
        result = enif_make_atom(env, "ok");
    } else {
        // argv[0] is a tuple
        ErlNifUInt64 x, y;
        ErlNifBinary in_data;
        char *type;
        unsigned int type_size;
        unsigned int bit;
        unsigned int depth;
        if(__builtin_expect(!parse_size_data_type(env, argv[0], &x, &y, &in_data, &type, &type_size, &bit, &depth), false)) {
            return enif_make_badarg(env);
        }

        if(__builtin_expect(strncmp(type, "u", type_size) == 0 && bit == 8, true)) {
            if(__builtin_expect(excv_imwrite_u8(path_binary.size, (char *)path_binary.data, (uint64_t) x, (uint64_t) y, (uint_fast16_t) depth, (uint8_t *)in_data.data), true)) {
                result = enif_make_atom(env, "ok");
            } else {
                result = enif_make_atom(env, "error");
            }
        } else {
            result = enif_make_atom(env, "error");
        }
    }
    return result;
}

static ErlNifFunc nif_funcs[] =
{
    {"im_write_nif", 3, im_write_nif},
};

ERL_NIF_INIT(Elixir.Excv.Imgcodecs, nif_funcs, NULL, NULL, NULL, NULL)