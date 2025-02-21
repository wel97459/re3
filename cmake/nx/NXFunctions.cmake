list(APPEND CMAKE_MODULE_PATH "$ENV{DEVKITPRO}/cmake/")
include(Switch)

set(CMAKE_EXECUTABLE_SUFFIX ".elf")
set(NX_ICON "${PROJECT_SOURCE_DIR}/res/images/logo_256.jpg")

function(nx_create_nacp TARGET NAME AUTHOR VERSION)
    set(NACP_PATH ${PROJECT_SOURCE_DIR}/src/${TARGET}.nacp)

    message(INFO " Running nx_create_nacp")

    execute_process(
        COMMAND ${NX_NACPTOOL_EXE} "--create" ${NAME} ${AUTHOR} ${VERSION} ${NACP_PATH}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/src
        OUTPUT_VARIABLE OUTPUT
        ERROR_VARIABLE ERROR
        RESULTS_VARIABLE RESULTS
        COMMAND_ECHO STDOUT
    )

endfunction()

function(nx_create_nro TARGET ICON)
    set(NRO_PATH ${PROJECT_SOURCE_DIR}/src/${TARGET}.nro)
    set(ELF_PATH ${PROJECT_SOURCE_DIR}/src/${TARGET}${CMAKE_EXECUTABLE_SUFFIX})
    set(NACP_PATH ${PROJECT_SOURCE_DIR}/src/${TARGET}.nacp)

    message(INFO " Running nx_create_nro")

    execute_process(
        COMMAND ${NX_ELF2NRO_EXE} ${ELF_PATH} ${NRO_PATH} --nacp=${NACP_PATH} --icon=${ICON}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/src
        OUTPUT_VARIABLE OUTPUT
        ERROR_VARIABLE ERROR
        RESULTS_VARIABLE RESULTS
        COMMAND_ECHO STDOUT
    )

endfunction()

function(re3_platform_target TARGET NAME VERSION ICON )
    cmake_parse_arguments(RPT "INSTALL" "" "" ${ARGN})

    get_target_property(TARGET_TYPE "${TARGET}" TYPE)
    if(TARGET_TYPE STREQUAL "EXECUTABLE")
        nx_create_nacp(
            ${TARGET}
            ${NAME}
            "${${PROJECT}_AUTHOR}"
            "${VERSION}"
        )

        nx_create_nro(
            ${TARGET}
            ${ICON}
        )

        if(${PROJECT}_INSTALL AND RPT_INSTALL)
            get_target_property(TARGET_OUTPUT_NAME ${TARGET} OUTPUT_NAME)
            if(NOT TARGET_OUTPUT_NAME)
                set(TARGET_OUTPUT_NAME "${TARGET}")
            endif()

            install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_OUTPUT_NAME}.nro"
                DESTINATION "."
            )
        endif()
    endif()
endfunction()