load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def url_for_python(version):
    return "https://www.python.org/ftp/python/{version}/Python-{version}.tgz".format(version=version)

def repository_name_for_python_version(version):
    components = version.split(".")
    if len(components) < 3:
        fail("Invalid python version: {}".format(version))

    major = components[0]
    minor = components[1]

    return "cpython{}_{}".format(major, minor)


def _toolchain_shim_impl(ctx):
    build_file_content = """ # toolchain shim for @{cpython_build_name}
toolchain(
    name = "toolchain",
    toolchain = "@{cpython_build_name}//:py_runtime_pair",
    toolchain_type = "@rules_python//python:toolchain_type",
    target_settings = ["@rules_cpython//:bootstrap_disabled"],
)

toolchain(
    name = "cc_toolchain",
    toolchain = "@{cpython_build_name}//:py_cc_toolchain",
    toolchain_type = "@rules_python//python/cc:toolchain_type",
    target_settings = ["@rules_cpython//:bootstrap_disabled"],
)
""".format(cpython_build_name=ctx.attr.cpython_build_name)

    ctx.file(
        "BUILD.bazel",
        content = build_file_content,
    )


_toolchain_shim = repository_rule(
    implementation = _toolchain_shim_impl,
    attrs = {
        "cpython_build_name": attr.string(),
    },
)


def _cpython_toolchain(ctx):
    for module in ctx.modules:
        for toolchain in module.tags.declare:
            cpython_name = repository_name_for_python_version(toolchain.version)
            build_file = "BUILD." + cpython_name

            http_archive(
                name = cpython_name + "_build",
                urls = [url_for_python(toolchain.version)],
                build_file = build_file,
                strip_prefix = "Python-" + toolchain.version,
            )

            _toolchain_shim(
                name = cpython_name,
                cpython_build_name = cpython_name + "_build",
            )



_declare = tag_class(
    attrs = {
        "version": attr.string(),
        "integrity": attr.string(),
    },
)

cpython_toolchain = module_extension(
    implementation = _cpython_toolchain,
    tag_classes = {"declare": _declare},
)
