.phony: all clean

PRIV_DIR = $(MIX_APP_PATH)/priv
BUILD_DIR = $(MIX_APP_PATH)/obj
EXCV_SO = $(PRIV_DIR)/libexcv.so

SRC_DIR = c_src/excv
EXCV_C_SRC = $(SRC_DIR)/libexcv.c
EXCV_C_OBJ = $(EXCV_C_SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

ifeq ($(CROSSCOMPILE),)
	ifneq ($(shell uname -s),Linux)
		LDFLAGS += -undefined dynamic_lookup -dynamiclib
	else
		LDFLAGS += -fPIC -shared
		CFLAGS += -fPIC
	endif
else
		LDFLAGS += -fPIC -shared
		CFLAGS += -fPIC
endif

ifeq ($(ERL_EI_INCLUDE_DIR),)
	ERLANG_PATH = $(shell elixir --eval ':code.root_dir |> to_string() |> IO.puts')
	ifeq ($(ERLANG_PATH),)
		$(error Could not find the Elixir installation. Check to see that 'elixir')
	endif
	ERL_EI_INCLUDE_DIR = $(ERLANG_PATH)/usr/include
	ERL_EI_LIB_DIR = $(ERLANG_PATH)/usr/lib
endif

ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

CFLAGS += -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers

all: $(PRIV_DIR) $(BUILD_DIR) $(EXCV_SO)

$(PRIV_DIR) $(BUILD_DIR):
	mkdir -p $@

$(EXCV_SO): $(EXCV_C_OBJ)
	@echo "LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

clean:
	$(RM) -rf $(PRIV_DIR) $(BUILD_DIR)

