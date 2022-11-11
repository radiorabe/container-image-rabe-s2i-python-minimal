FROM ghcr.io/radiorabe/s2i-base:0.5.0

EXPOSE 8080

ENV \
    PYTHON_VERSION=3.9 \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PIP_NO_CACHE_DIR=off \
    PATH=$APP_ROOT/bin:$HOME/bin:$HOME/.local/bin:$PATH

COPY --from=registry.access.redhat.com/ubi8/python-39:1-35.1648121362 \
     $STI_SCRIPTS_PATH/assemble \
     $STI_SCRIPTS_PATH/init-wrapper \
     $STI_SCRIPTS_PATH/run \
     $STI_SCRIPTS_PATH/usage \
     $STI_SCRIPTS_PATH/
COPY --from=registry.access.redhat.com/ubi8/python-39:1-35.1648121362 \
     $APP_ROOT/etc/scl_enable \
     $APP_ROOT/etc/

ENV BASH_ENV=${APP_ROOT}/etc/scl_enable \
    ENV=${APP_ROOT}/etc/scl_enable \
    PROMPT_COMMAND=". ${APP_ROOT}/etc/scl_enable"

RUN    microdnf install -y \
         nss_wrapper \
         python39 \
         python39-pip-wheel \
         python39-wheel \
         python39-wheel-wheel \
    && microdnf clean all \
    && python3.9 -mvenv ${APP_ROOT} \
    && python3.9 -mpip install /usr/share/python39-wheels/wheel-*.whl \
    && chown -R 1001:0 ${APP_ROOT} \
    && fix-permissions ${APP_ROOT} -P \
    && rpm-file-permissions

USER 1001

CMD $STI_SCRIPTS_PATH/usage
