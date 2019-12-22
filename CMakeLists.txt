cmake_minimum_required(VERSION 3.6)
project(dvrescue
            DESCRIPTION
                "Data migration from DV tapes into digital files suitable for long-term preservation. Archivist-made software that supports data migration from DV tapes into digital files suitable for long-term preservation"
        VERSION "0.19.11"
        LANGUAGES CXX
        )
set(CMAKE_PROJECT_HOMEPAGE_URL "https://MediaArea.net/DVRescue")
find_package(ZenLib REQUIRED)
find_package(MediaInfoLib REQUIRED)

add_subdirectory(Source)
add_subdirectory(tools)

# Creates an exact copy of the license file in the build directory to help WIX TOOLSET
# convert the license in to it's expected .rtf format when creating MSI installers
configure_file(LICENSE ${PROJECT_BINARY_DIR}/LICENSE.txt)

# Set the packaging variables in Project/CMake/CPackConfig.cmake. Anything
# not set here will be derived from the project metadata or use a default template,
include(Project/CMake/CPackConfig.cmake)
include(CPack)