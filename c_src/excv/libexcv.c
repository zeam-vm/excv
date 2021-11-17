#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <erl_nif.h>
#include "parse_size_data_type.h"
#include "imgcodecs/imwrite.h"
#include "imgcodecs/imread.h"
#include "error.h"

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
            const char *error_message = "";
            if(__builtin_expect(excv_imwrite_u8(path_binary.size, (char *)path_binary.data, (uint64_t) x, (uint64_t) y, (uint_fast16_t) depth, (uint8_t *)in_data.data, &error_message), true)) {
                result = enif_make_atom(env, "ok");
            } else {
                ErlNifBinary reason;
                if(__builtin_expect(!(enif_alloc_binary(strnlen(error_message, 256), &reason) && reason.size > 0), false)) {
                    result = enif_make_atom(env, "error");
                } else {
                    memcpy(reason.data, error_message, reason.size);
                    result = enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_binary(env, &reason));
                }
            }
        } else {
            result = enif_make_atom(env, "error");
        }
    }
    return result;
}

static ERL_NIF_TERM im_read_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 2, false)) {
        return enif_make_badarg(env);
    }

    ErlNifBinary path_binary_tmp;
    if(__builtin_expect(!enif_inspect_binary(env, argv[0], &path_binary_tmp), false)) {
        return enif_make_badarg(env);
    }

    ErlNifBinary path_binary;
    if(__builtin_expect(!enif_alloc_binary(path_binary_tmp.size + 1, &path_binary), false)) {
        return enif_make_badarg(env);
    }
    memcpy(path_binary.data, path_binary_tmp.data, path_binary_tmp.size);
    path_binary.data[path_binary_tmp.size] = 0;

    ERL_NIF_TERM result;

    uint64_t x;
    uint64_t y;
    uint_fast16_t depth;
    uint_fast16_t element_size;
    enum return_type type;
    void *data;
    const char *error_message;

    if(__builtin_expect(excv_imread(path_binary.size, (char *)path_binary.data, &x, &y, &depth, &element_size, &type, &data, &error_message), true)) {
        ErlNifBinary bdata;
        if(__builtin_expect(!(enif_alloc_binary(x * y * depth * element_size, &bdata) && bdata.size > 0), false)) {
            const char *message = "imread: wrong size of image";
            size_t size = strlen(message) + 256;
            char *buf = (char *)enif_alloc(size);
            if(__builtin_expect(buf == NULL, false)) {
                return make_error(env, message);
            }
            snprintf(buf, size, "%s (x = %llu, y = %llu, depth = %u, element_size = %u", message, x, y, depth, element_size);
            return make_error(env, buf);
        } else {
            memcpy(bdata.data, data, bdata.size);
            enif_free(data);
            ERL_NIF_TERM shape = enif_make_tuple3(env, enif_make_uint64(env, y), enif_make_uint64(env, x), enif_make_uint(env, depth));
            ERL_NIF_TERM atom;
            switch(type) {
                case INT:
                    atom = enif_make_atom(env, "s");
                    break;
                case UINT:
                    atom = enif_make_atom(env, "u");
                    break;
                case FLOAT:
                    atom = enif_make_atom(env, "f");
                    break;
                default:
                    return make_error(env, "imread: wrong type of image");
            }
            uint_fast16_t type_len;
            switch(element_size) {
                case 1:
                    type_len = 8;
                    break;
                case 2:
                    type_len = 16;
                    break;
                case 4:
                    type_len = 32;
                    break;
                case 8:
                    type_len = 64;
                    break;
                default:
                    return make_error(env, "imread: wrong type size of image");
            }
            ERL_NIF_TERM type = enif_make_tuple2(env, atom, enif_make_uint(env, type_len));
            return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_tuple3(env, shape, type, enif_make_binary(env, &bdata)));
        } 
    } else {
        return make_error(env, error_message);
    }

    return result;
}

static ErlNifFunc nif_funcs[] =
{
    {"im_write_nif", 3, im_write_nif},
    {"im_read_nif", 2, im_read_nif},
};

ERL_NIF_INIT(Elixir.Excv.Imgcodecs, nif_funcs, NULL, NULL, NULL, NULL)