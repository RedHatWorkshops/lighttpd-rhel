
# lighttpd-rhel
FROM registry.access.redhat.com/rhel7-atomic

# TODO: Put the maintainer name in the image metadata
MAINTAINER Veer Muchandi<veer@redhat.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0
ENV \
LIGHTTPD_VERSION=1.4.35 \
STI_SCRIPTS_URL=image:///usr/libexec/s2i \
STI_SCRIPTS_PATH=/usr/libexec/s2i \
HOME=/opt/app-root/src \
PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for serving static HTML Pages" \
      io.k8s.display-name="Lighttpd 1.4.35" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,html,lighttpd" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y
RUN microdnf install -y --enablerepo=rhel-7-server-rpms --enablerepo=rhel-7-server-extras-rpms --enablerepo=rhel-7-server-optional-rpms \
automake gettext git lsof make tar unzip wget which && \
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
microdnf install -y --enablerepo=rhel-7-server-rpms --enablerepo=rhel-7-server-extras-rpms --enablerepo=rhel-7-server-optional-rpms lighttpd && \
microdnf clean all -y && \
mkdir -p /opt/app-root && \
useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
 -c "Default Application User" default && \
chown -R 1001:0 /opt/app-root

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path.
WORKDIR ${HOME}


# Copy the S2I scripts to /usr/libexec/s2i
COPY ./s2i/bin/ /usr/libexec/s2i

# Copy the lighttpd configuration file
COPY ./etc/ /opt/app-root/etc

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
