FROM registry.access.redhat.com/ubi9/python-312:9.6 as base
FROM ghcr.io/radiorabe/s2i-base:2.4.1

EXPOSE 8080

ENV \
    PYTHON_VERSION=3.12 \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    CNB_STACK_ID=ch.rabe.it.stacks.ubi9-python-312 \
    CNB_USER_ID=1001 \
    CNB_GROUP_ID=0 \
    PIP_NO_CACHE_DIR=off \
    PATH=$APP_ROOT/bin:$HOME/bin:$HOME/.local/bin:$PATH

COPY --from=base \
     $STI_SCRIPTS_PATH/assemble \
     $STI_SCRIPTS_PATH/init-wrapper \
     $STI_SCRIPTS_PATH/run \
     $STI_SCRIPTS_PATH/usage \
     $STI_SCRIPTS_PATH/
COPY --from=base \
     $APP_ROOT/etc/scl_enable \
     $APP_ROOT/etc/

ENV BASH_ENV=${APP_ROOT}/etc/scl_enable \
    ENV=${APP_ROOT}/etc/scl_enable \
    PROMPT_COMMAND=". ${APP_ROOT}/etc/scl_enable"

RUN    microdnf install -y \
         nss_wrapper \
         python3.12 \
         python3.12-pip-wheel \
    && microdnf clean all \
    && python3.12 -mvenv ${APP_ROOT} \
    && python3.12 -mpip install /usr/share/python3.12-wheels/*.whl \
    && python3.12 -mpip install build \
    && chown -R 1001:0 ${APP_ROOT} \
    && fix-permissions ${APP_ROOT} -P \
    && rpm-file-permissions

USER 1001

CMD $STI_SCRIPTS_PATH/usage
