@echo off

:exit_with_err
    echo ERROR: %~1
    exit /b 1

:run_orca_container_scan
    cd "%GITHUB_WORKSPACE%" || call :exit_with_err "could not find GITHUB_WORKSPACE: %GITHUB_WORKSPACE%"
    echo Running Orca Container Image scan:
    echo orca-cli %GLOBAL_FLAGS% image scan %SCAN_FLAGS%
    orca-cli %GLOBAL_FLAGS% image scan %SCAN_FLAGS%
    set ORCA_EXIT_CODE=%errorlevel%

    echo exit_code=%ORCA_EXIT_CODE% >>"%GITHUB_OUTPUT%"

:set_global_flags
    set "GLOBAL_FLAGS="
    if "%INPUT_EXIT_CODE%" NEQ "" (
        set "GLOBAL_FLAGS=--exit-code %INPUT_EXIT_CODE%"
    )
    if "%INPUT_NO_COLOR%"=="true" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --no-color"
    )
    if "%INPUT_PROJECT_KEY%" NEQ "" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --project-key %INPUT_PROJECT_KEY%"
    )
    if "%INPUT_SILENT%"=="true" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --silent"
    )
    if "%INPUT_CONFIG%" NEQ "" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --config %INPUT_CONFIG%"
    )
    if "%INPUT_BASELINE_CONTEXT_KEY%" NEQ "" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --baseline-context-key %INPUT_BASELINE_CONTEXT_KEY%"
    )
    if "%INPUT_DISABLE_BASELINE%"=="true" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --disable-baseline"
    )
    if "%INPUT_DISABLE_ERR_REPORT%"=="true" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --disable-err-report"
    )
    if "%INPUT_SYNC_BASELINE%" NEQ "" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --sync-baseline %INPUT_SYNC_BASELINE%"
    )
    if "%INPUT_DISPLAY_NAME%" NEQ "" (
        set "GLOBAL_FLAGS=%GLOBAL_FLAGS% --display-name %INPUT_DISPLAY_NAME%"
    )

REM Json format must be reported and be stored in a file for github annotations
:prepare_json_to_file_flags
    REM Output directory must be provided to store the json results
    set "OUTPUT_FOR_JSON=%INPUT_OUTPUT%"
    set "CONSOLE_OUTPUT_FOR_JSON=%INPUT_CONSOLE_OUTPUT%"
    if "%INPUT_OUTPUT%"=="" (
        REM Results should be printed to console in the selected format
        set "CONSOLE_OUTPUT_FOR_JSON=%INPUT_FORMAT:table=%"
        REM Results should also be stored in a directory
        set "OUTPUT_FOR_JSON=orca_results/"
    )

    if "%INPUT_FORMAT%"=="" (
        REM The default format should be provided together with the one we are adding
        set "FORMATS_FOR_JSON=table,json"
    ) else (
        if "%INPUT_FORMAT:json=%"=="%INPUT_FORMAT%" (
            set "FORMATS_FOR_JSON=%INPUT_FORMAT%,json"
        ) else (
            set "FORMATS_FOR_JSON=%INPUT_FORMAT%"
        )
    )

    REM Used during the annotation process
    set "OUTPUT_FOR_JSON=%OUTPUT_FOR_JSON%"
    set "CONSOLE_OUTPUT_FOR_JSON=%CONSOLE_OUTPUT_FOR_JSON%"
    set "FORMATS_FOR_JSON=%FORMATS_FOR_JSON%"

:set_container_scan_flags
    set "SCAN_FLAGS="
    if "%INPUT_IMAGE%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% %INPUT_IMAGE%"
    )
    if "%INPUT_TAR_ARCHIVE%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --tar-archive %INPUT_TAR_ARCHIVE%"
    )
    if "%INPUT_TIMEOUT%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --timeout %INPUT_TIMEOUT%"
    )
    if "%INPUT_IGNORE_FAILED_EXEC_CONTROLS%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --ignore-failed-exec-controls"
    )
    if "%INPUT_OCI%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --oci"
    )
    if "%INPUT_DISABLE_SECRET%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --disable-secret"
    )
    if "%INPUT_EXCEPTIONS_FILEPATH%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --exceptions-filepath %INPUT_EXCEPTIONS_FILEPATH%"
    )
    if "%INPUT_HIDE_VULNERABILITIES%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --hide-vulnerabilities"
    )
    if "%INPUT_NUM_CPU%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --num-cpu %INPUT_NUM_CPU%"
    )
    if "%INPUT_SHOW_FAILED_ISSUES_ONLY%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --show-failed-issues-only"
    )
    if "%FORMATS_FOR_JSON%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --format %FORMATS_FOR_JSON%"
    )
    if "%OUTPUT_FOR_JSON%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --output %OUTPUT_FOR_JSON%"
    )
    if "%CONSOLE_OUTPUT_FOR_JSON%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --console-output=%CONSOLE_OUTPUT_FOR_JSON%"
    )
    if "%INPUT_SKIP_REMOTE_LOOKUP%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --skip-remote-lookup"
    )
    if "%INPUT_CUSTOM_SECRET_CONTROLS%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --custom-secret-controls=%INPUT_CUSTOM_SECRET_CONTROLS%"
    )
    if "%INPUT_HIDE_SKIPPED_VULNERABILITIES%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --hide-skipped-vulnerabilities"
    )
    if "%INPUT_MAX_SECRET%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --max-secret %INPUT_MAX_SECRET%"
    )
    if "%INPUT_EXCLUDE_PATHS%" NEQ "" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --exclude-paths %INPUT_EXCLUDE_PATHS%"
    )
    if "%INPUT_DEPENDENCY_TREE%"=="true" (
        set "SCAN_FLAGS=%SCAN_FLAGS% --dependency-tree"
    )

:set_env_vars
    if "%INPUT_API_TOKEN%" NEQ "" (
        set "ORCA_SECURITY_API_TOKEN=%INPUT_API_TOKEN%"
    )

:validate_flags
if "%INPUT_API_TOKEN%"=="" (
    exit_with_err "api_token must be provided"
)
if "%INPUT_PROJECT_KEY%"=="" (
    exit_with_err "project_key must be provided"
)
if "%INPUT_OUTPUT%" NEQ "" (
    if not "%INPUT_OUTPUT:~-1%"=="\" (
        if not exist "%INPUT_OUTPUT%\" (
            exit_with_err "output must be a folder (end with \)"
        )
    )
)

:main
    call validate_flags
    call set_env_vars
    call set_global_flags
    call prepare_json_to_file_flags
    call set_container_scan_flags
    call run_orca_container_scan
    exit %ORCA_EXIT_CODE%

call main "%*"
