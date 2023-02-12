FROM ghcr.io/radiorabe/s2i-base:2.0.0-alpha.4

EXPOSE 8080

ENV \
    PYTHON_VERSION=3.9 \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    CNB_STACK_ID=ch.rabe.it.stacks.ubi9-python-39 \
    CNB_USER_ID=1001 \
    CNB_GROUP_ID=0 \
    PIP_NO_CACHE_DIR=off \
    PATH=$APP_ROOT/bin:$HOME/bin:$HOME/.local/bin:$PATH

COPY --from=registry.access.redhat.com/ubi9/python-39:1-90 \
     $STI_SCRIPTS_PATH/assemble \
     $STI_SCRIPTS_PATH/init-wrapper \
     $STI_SCRIPTS_PATH/run \
     $STI_SCRIPTS_PATH/usage \
     $STI_SCRIPTS_PATH/
COPY --from=registry.access.redhat.com/ubi9/python-39:1-90 \
     $APP_ROOT/etc/scl_enable \
     $APP_ROOT/etc/

ENV BASH_ENV=${APP_ROOT}/etc/scl_enable \
    ENV=${APP_ROOT}/etc/scl_enable \
    PROMPT_COMMAND=". ${APP_ROOT}/etc/scl_enable"

RUN    microdnf install -y \
         nss_wrapper \
         python3 \
         python3-pip-wheel \
         python3-wheel-wheel \
    && microdnf clean all \
    && python3.9 -mvenv ${APP_ROOT} \
    && python3.9 -mpip install /usr/share/python3-wheels/wheel-*.whl \
    && python3.9 -mpip install build \
    && chown -R 1001:0 ${APP_ROOT} \
    && fix-permissions ${APP_ROOT} -P \
    && rpm-file-permissions

USER 1001

CMD $STI_SCRIPTS_PATH/usage
