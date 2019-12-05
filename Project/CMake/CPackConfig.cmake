set(CPACK_PACKAGE_CONTACT "Jerome Martinez <Info@MediaArea.net>")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libzen0v5")
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Supplies technical and tag information about a video or audio file")
set(CPACK_DEBIAN_PACKAGE_SECTION "utils")
set(CPACK_RPM_PACKAGE_LICENSE "BSD-3-Clause")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://MediaArea.net/DVRescue")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/README.md")
set(CPACK_PACKAGE_VENDOR "MediaArea")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_SOURCE_IGNORE_FILES "/CVS/;/\\\\.svn/;/\\\\.bzr/;/\\\\.hg/;/\\\\.git/;\\\\.swp\\$;\\\\.#;/#")
list(APPEND CPACK_SOURCE_IGNORE_FILES /build)
list(APPEND CPACK_SOURCE_IGNORE_FILES /cmake-build-*)
list(APPEND CPACK_SOURCE_IGNORE_FILES \\\\.idea)
list(APPEND CPACK_SOURCE_IGNORE_FILES \\\\.gitignore)
