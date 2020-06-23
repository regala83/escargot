CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

SET (ESCARGOT_INCDIRS
    ${ESCARGOT_INCDIRS}
    ${ESCARGOT_ROOT}/src/
    ${GCUTIL_ROOT}/
    ${GCUTIL_ROOT}/bdwgc/include/
    ${ESCARGOT_THIRD_PARTY_ROOT}/checked_arithmetic/
    ${ESCARGOT_THIRD_PARTY_ROOT}/double_conversion/
    ${ESCARGOT_THIRD_PARTY_ROOT}/lz4/
    ${ESCARGOT_THIRD_PARTY_ROOT}/rapidjson/include/
    ${ESCARGOT_THIRD_PARTY_ROOT}/yarr/
    ${ESCARGOT_THIRD_PARTY_ROOT}/runtime_icu_binder/
)

IF (${ESCARGOT_MODE} STREQUAL "debug")
    SET (ESCARGOT_CXXFLAGS ${ESCARGOT_CXXFLAGS_DEBUG} ${ESCARGOT_CXXFLAGS})
    SET (ESCARGOT_LDFLAGS ${ESCARGOT_LDFLAGS_DEBUG} ${ESCARGOT_LDFLAGS})
    SET (ESCARGOT_DEFINITIONS ${ESCARGOT_DEFINITIONS} ${ESCARGOT_DEFINITIONS_DEBUG})
ELSEIF (${ESCARGOT_MODE} STREQUAL "release")
    SET (ESCARGOT_CXXFLAGS ${ESCARGOT_CXXFLAGS_RELEASE} ${ESCARGOT_CXXFLAGS})
    SET (ESCARGOT_LDFLAGS ${ESCARGOT_LDFLAGS_RELEASE} ${ESCARGOT_LDFLAGS})
    SET (ESCARGOT_DEFINITIONS ${ESCARGOT_DEFINITIONS} ${ESCARGOT_DEFINITIONS_RELEASE})
ENDIF()

IF (${ESCARGOT_OUTPUT} STREQUAL "shell")
    SET (ESCARGOT_CXXFLAGS ${ESCARGOT_CXXFLAGS} ${ESCARGOT_CXXFLAGS_SHELL})
    SET (ESCARGOT_LDFLAGS ${ESCARGOT_LDFLAGS} ${ESCARGOT_LDFLAGS_SHELL})
    SET (ESCARGOT_DEFINITIONS ${ESCARGOT_DEFINITIONS} ${ESCARGOT_DEFINITIONS_SHELL})
ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "shell_test")
    SET (ESCARGOT_CXXFLAGS ${ESCARGOT_CXXFLAGS} ${ESCARGOT_CXXFLAGS_SHELL} ${ESCARGOT_DEFINITIONS_TEST})
    SET (ESCARGOT_LDFLAGS ${ESCARGOT_LDFLAGS} ${ESCARGOT_LDFLAGS_SHELL})
    SET (ESCARGOT_DEFINITIONS ${ESCARGOT_DEFINITIONS} ${ESCARGOT_DEFINITIONS_SHELL})
ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "shared_lib")
    SET (ESCARGOT_CXXFLAGS ${ESCARGOT_CXXFLAGS} ${ESCARGOT_CXXFLAGS_SHAREDLIB})
    SET (ESCARGOT_LDFLAGS ${ESCARGOT_LDFLAGS} ${ESCARGOT_LDFLAGS_SHAREDLIB})
    SET (ESCARGOT_DEFINITIONS ${ESCARGOT_DEFINITIONS} ${ESCARGOT_DEFINITIONS_SHAREDLIB})
ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "static_lib")
    SET (ESCARGOT_CXXFLAGS ${ESCARGOT_CXXFLAGS} ${ESCARGOT_CXXFLAGS_STATICLIB})
    SET (ESCARGOT_LDFLAGS ${ESCARGOT_LDFLAGS} ${ESCARGOT_LDFLAGS_STATICLIB})
    SET (ESCARGOT_DEFINITIONS ${ESCARGOT_DEFINITIONS} ${ESCARGOT_DEFINITIONS_STATICLIB})
ENDIF()

IF (${ESCARGOT_ASAN} STREQUAL "1")
    SET (ESCARGOT_CXXFLAGS ${ESCARGOT_CXXFLAGS} -fsanitize=address)
    SET (ESCARGOT_LDFLAGS ${ESCARGOT_LDFLAGS} -lasan)
ENDIF()


# SOURCE FILES
FILE (GLOB_RECURSE ESCARGOT_SRC ${ESCARGOT_ROOT}/src/*.cpp)
FILE (GLOB YARR_SRC ${ESCARGOT_THIRD_PARTY_ROOT}/yarr/*.cpp)
FILE (GLOB DOUBLE_CONVERSION_SRC ${ESCARGOT_THIRD_PARTY_ROOT}/double_conversion/*.cc)
FILE (GLOB LZ4_SRC ${ESCARGOT_THIRD_PARTY_ROOT}/lz4/*.cpp)

IF (NOT ${ESCARGOT_OUTPUT} MATCHES "shell")
    LIST (REMOVE_ITEM ESCARGOT_SRC ${ESCARGOT_ROOT}/src/shell/Shell.cpp)
ENDIF()

IF (${ESCARGOT_OUTPUT} STREQUAL "cctest")
	ADD_SUBDIRECTORY (third_party/googletest/googletest)
	FILE (GLOB CCTEST_SRC ${ESCARGOT_ROOT}/test/cctest/testapi.cpp)
ENDIF()

SET (ESCARGOT_SRC_LIST
    ${ESCARGOT_SRC}
    ${YARR_SRC}
    ${DOUBLE_CONVERSION_SRC}
    ${LZ4_SRC}
    ${CCTEST_SRC}
)

# GCUTIL
SET (GCUTIL_CFLAGS ${ESCARGOT_GCUTIL_CFLAGS})

IF (${ESCARGOT_OUTPUT} STREQUAL "shared_lib")
    SET (GCUTIL_CFLAGS ${GCUTIL_CFLAGS} ${ESCARGOT_CXXFLAGS_SHAREDLIB})
ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "static_lib")
    SET (GCUTIL_CFLAGS ${GCUTIL_CFLAGS} ${ESCARGOT_CXXFLAGS_STATICLIB})
ENDIF()

SET (GCUTIL_MODE ${ESCARGOT_MODE})

ADD_SUBDIRECTORY (third_party/GCutil)

SET (ESCARGOT_LIBRARIES ${ESCARGOT_LIBRARIES} gc-lib)

# RUNTIME ICU BINDER
SET (RIB_CFLAGS ${ESCARGOT_CXXFLAGS})

IF (${ESCARGOT_OUTPUT} STREQUAL "shared_lib")
    SET (RIB_CFLAGS ${RIB_CFLAGS} ${ESCARGOT_CXXFLAGS_SHAREDLIB})
ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "static_lib")
    SET (RIB_CFLAGS ${RIB_CFLAGS} ${ESCARGOT_CXXFLAGS_STATICLIB})
ENDIF()

SET (RIB_MODE ${ESCARGOT_MODE})

ADD_SUBDIRECTORY (third_party/runtime_icu_binder)

SET (ESCARGOT_LIBRARIES ${ESCARGOT_LIBRARIES} runtime-icu-binder-static)

# BUILD
IF (${ESCARGOT_OUTPUT} MATCHES "shell")
    ADD_EXECUTABLE (${ESCARGOT_TARGET} ${ESCARGOT_SRC_LIST})

    TARGET_LINK_LIBRARIES (${ESCARGOT_TARGET} ${ESCARGOT_LIBRARIES} ${ESCARGOT_LDFLAGS} ${LDFLAGS_FROM_ENV})
    TARGET_INCLUDE_DIRECTORIES (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_INCDIRS})
    TARGET_COMPILE_DEFINITIONS (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_DEFINITIONS})
    TARGET_COMPILE_OPTIONS (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_CXXFLAGS} ${CXXFLAGS_FROM_ENV} ${PROFILER_FLAGS} ${DEBUGGER_FLAGS})

ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "shared_lib")
    ADD_LIBRARY (${ESCARGOT_TARGET} SHARED ${ESCARGOT_SRC_LIST})

    TARGET_LINK_LIBRARIES (${ESCARGOT_TARGET} ${ESCARGOT_LIBRARIES} ${ESCARGOT_LDFLAGS} ${LDFLAGS_FROM_ENV})
    TARGET_INCLUDE_DIRECTORIES (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_INCDIRS})
    TARGET_COMPILE_DEFINITIONS (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_DEFINITIONS})
    TARGET_COMPILE_OPTIONS (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_CXXFLAGS} ${CXXFLAGS_FROM_ENV})

ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "static_lib")
    ADD_LIBRARY (${ESCARGOT_TARGET} STATIC ${ESCARGOT_SRC_LIST})

    TARGET_LINK_LIBRARIES (${ESCARGOT_TARGET} ${ESCARGOT_LIBRARIES} ${ESCARGOT_LDFLAGS} ${LDFLAGS_FROM_ENV})
    TARGET_INCLUDE_DIRECTORIES (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_INCDIRS})
    TARGET_COMPILE_DEFINITIONS (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_DEFINITIONS})
    TARGET_COMPILE_OPTIONS (${ESCARGOT_TARGET} PUBLIC ${ESCARGOT_CXXFLAGS} ${CXXFLAGS_FROM_ENV})

ELSEIF (${ESCARGOT_OUTPUT} STREQUAL "cctest")
    ADD_EXECUTABLE (${ESCARGOT_CCTEST_TARGET} ${ESCARGOT_SRC_LIST})

    TARGET_LINK_LIBRARIES (${ESCARGOT_CCTEST_TARGET} ${ESCARGOT_LIBRARIES} ${ESCARGOT_LDFLAGS} ${LDFLAGS_FROM_ENV} gtest)
    TARGET_INCLUDE_DIRECTORIES (${ESCARGOT_CCTEST_TARGET} PUBLIC ${ESCARGOT_INCDIRS})
    TARGET_COMPILE_DEFINITIONS (${ESCARGOT_CCTEST_TARGET} PUBLIC ${ESCARGOT_DEFINITIONS})
    TARGET_COMPILE_OPTIONS (${ESCARGOT_CCTEST_TARGET} PUBLIC ${ESCARGOT_CXXFLAGS} -I${ESCARGOT_ROOT}/third_party/googletest/googletest/include/ ${CXXFLAGS_FROM_ENV})
ENDIF()
