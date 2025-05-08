load("@bazel_skylib//rules:common_settings.bzl", "bool_setting")

bool_setting(
    name ="cpython_bootstrap",
    build_setting_default = False,
)

config_setting(
    name = "bootstrap_disabled",
    flag_values = {":cpython_bootstrap": "False"},
)

config_setting(
    name = "bootstrap_enabled",
    flag_values = {":cpython_bootstrap": "True"},
)
