FROM ibmcom/mq:latest

ENV MQ_SERVER_NAME=MQLOCALVIRT 
ENV MQ_CHANNEL_NAME=DEV.APP.SVRCONN
ENV MQ_QUEUE_NAME=DEV.QUEUE.1
ENV LICENSE accept
ENV MQ_QMGR_NAME=MQLOCALVIRT 
VOLUME /var/mqm
ENV ICC_SHIFT=3 
ENV MQSNOAUT=true
ENV MQSI_FORCE_QM_CONFIG=true

ENV MQ_APP_PASSWORD=passw0rd
ENV MQ_ADMIN_PASSWORD=passw0rd

#COPY config.mqsc /etc/mqm/

# Exponer puertos
EXPOSE 1450:1414 
EXPOSE 9450:9443

USER 1001
RUN mkdir -p /var/mqm/exits64/RTVS/
RUN mkdir -p /var/mqm/exits/RTVS/

# Agregar archivos de configuración
COPY IBMWebSphereMQdist/bin/intercept_linux_x86 /var/mqm/exits/RTVS/
COPY IBMWebSphereMQdist/bin/intercept_linux_x86_r /var/mqm/exits/RTVS/
COPY IBMWebSphereMQdist/bin/intercept_linux_x86_64 /var/mqm/exits64/RTVS/
COPY IBMWebSphereMQdist/bin/intercept_linux_x86_64_r /var/mqm/exits64/RTVS/

# Enlaces Simblicos
USER root

RUN mv /var/mqm/exits/RTVS/intercept_linux_x86 /var/mqm/exits/RTVS/intercept 
RUN mv /var/mqm/exits/RTVS/intercept_linux_x86_r /var/mqm/exits/RTVS/intercept_r 

# Asignar permisos para ejecutar globalmente
RUN chown adm /var/mqm/exits/RTVS/intercept*
RUN chgrp adm /var/mqm/exits/RTVS/intercept*
RUN chmod a+x /var/mqm/exits/RTVS/intercept*

RUN mv /var/mqm/exits64/RTVS/intercept_linux_x86_64 /var/mqm/exits64/RTVS/intercept 
RUN mv /var/mqm/exits64/RTVS/intercept_linux_x86_64_r /var/mqm/exits64/RTVS/intercept_r 

# Asignar permisos para ejecutar globalmente
RUN chown adm /var/mqm/exits64/RTVS/intercept*
RUN chgrp adm /var/mqm/exits64/RTVS/intercept*
RUN chmod a+x /var/mqm/exits64/RTVS/intercept*


RUN groupadd mqadmgr -g 1002  && \
    useradd mqadm -u 1006 -G mqadmgr  && \
    echo mqadm:default | chpasswd 


USER root
COPY /qm.ini /etc/mqm


USER 1001
# Iniciar MQ y consola
CMD ["mq.sh" start , "-d" , "-c","runmqserver"]
