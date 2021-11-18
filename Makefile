.phony: all clean

PRIV_DIR = $(MIX_APP_PATH)/priv
BUILD_DIR = $(MIX_APP_PATH)/obj
EXCV_SO = $(PRIV_DIR)/libexcv.so

SRC_DIR = c_src/excv
SUB_DIRS = $(SRC_DIR)/imgcodecs

EXCV_C_SRC = $(SRC_DIR)/libexcv.c $(SRC_DIR)/parse_size_data_type.c $(SRC_DIR)/error.c
EXCV_CXX_SRC = $(SRC_DIR)/imgcodecs/imwrite.cpp $(SRC_DIR)/imgcodecs/imread.cpp
EXCV_C_OBJ = $(EXCV_C_SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
EXCV_CXX_OBJ = $(EXCV_CXX_SRC:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)
EXCV_C_DEPS = $(EXCV_C_SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.d)
EXCV_CXX_DEPS = $(EXCV_CXX_SRC:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.d)

BUILD_SUB_DIRS = $(SUB_DIRS:$(SRC_DIR)/%=$(BUILD_DIR)/%)

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

ifeq ($(shell pkg-config opencv4 --exists || echo $$?),)
	CV_CFLAGS ?= $(shell pkg-config opencv4 --cflags)
	CV_LDFLAGS ?= $(shell pkg-config opencv4 --libs)
else ifeq ($(shell pkg-config opencv --exists || echo $$?),)
	CV_CFLAGS ?= $(shell pkg-config opencv --cflags)
	CV_LDFLAGS ?= $(shell pkg-config opencv --libs)
else
	$(error OpenCV doesn't exist.)
endif

ifeq ($(shell uname -s),Linux)
	ifeq ($(shell which opencv_read_cuda),)
		ifeq ($(shell opencv_read_cuda),YES)
			CXXFLAGS += -D EXIST_CUDA
		endif
	endif
endif

LDFLAGS += -lstdc++ -lopencv_core -lm
CFLAGS += -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers
CXXFLAGS ?= -std=c++11 -Ofast -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers

all: $(PRIV_DIR) $(BUILD_DIR) $(BUILD_SUB_DIRS) $(EXCV_SO) $(EXCV_C_DEPS) $(EXCV_CXX_DEPS)

$(PRIV_DIR) $(BUILD_DIR) $(BUILD_SUB_DIRS):
	mkdir -p $@

$(EXCV_SO): $(EXCV_C_OBJ) $(EXCV_CXX_OBJ)
	@echo "LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $(CV_LDFLAGS) $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(BUILD_DIR)/%.d
	@echo "CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp $(BUILD_DIR)/%.d
	@echo "CC $(notdir $@)"
	$(CXX) -c $(ERL_CFLAGS) $(CXXFLAGS) $(CV_CFLAGS) -o $@ $<

$(BUILD_DIR)/%.d: $(SRC_DIR)/%.c
	$(CC) $(ERL_CFLAGS) $(CFLAGS) $< -MM -MP -MF $@

$(BUILD_DIR)/%.d: $(SRC_DIR)/%.cpp
	$(CC) $(ERL_CFLAGS) $(CXXFLAGS) $(CV_CFLAGS) $< -MM -MP -MF $@

include $(shell ls $(EXCV_C_DEPS) 2>/dev/null)
include $(shell ls $(EXCV_CXX_DEPS) 2>/dev/null)

clean:
	$(RM) -rf $(PRIV_DIR) $(BUILD_DIR)

