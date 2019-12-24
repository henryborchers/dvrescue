add_executable(dvrescue
        CLI/CLI_Help.cpp
        CLI/CLI_Main.cpp
        CLI/CommandLine_Parser.cpp
        CLI/DVRescue.rc
        Common/Core.cpp
        Common/ProcessFile.cpp
        Common/XmlOutput.cpp
)
target_include_directories(dvrescue
        PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}
        )

target_link_libraries(dvrescue PRIVATE mediainfo)
set_target_properties(dvrescue PROPERTIES
        CXX_STANDARD 11
        INSTALL_RPATH_USE_LINK_PATH True
        )
install(TARGETS dvrescue RUNTIME DESTINATION bin)
if (WIN32)
    install(CODE [[
        include(InstallRequiredSystemLibraries)
        include(BundleUtilities)
        find_program(dvrescue_INSTALLED
            NAMES
                dvrescue
            PATHS
                "${CMAKE_INSTALL_PREFIX}/bin/"
        )

        fixup_bundle(
            "${dvrescue_INSTALLED}"
            ""
            ""
        )

    ]])

endif ()