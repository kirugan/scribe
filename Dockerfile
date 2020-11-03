#
# Dockerfile - Facebook Scribe
#
FROM     ubuntu:12.04

# Last Package Update & Install
RUN apt-get update && apt-get install -y curl supervisor openssh-server net-tools iputils-ping vim \
 make autoconf automake flex bison libtool libevent-dev pkg-config libssl-dev libboost-all-dev libbz2-dev build-essential g++ python-dev git

# Facebook Scribe
# Thrift
ENV thrift_src /usr/local/src/thrift
RUN git clone https://github.com/apache/thrift.git $thrift_src \
 && cd $thrift_src && git checkout 0.8.0 \
 && ./bootstrap.sh && ./configure && make && make install

# fb303
RUN cd $thrift_src/contrib/fb303 \
 && ./bootstrap.sh \
 && ./configure CPPFLAGS="-DHAVE_INTTYPES_H -DHAVE_NETINET_IN_H" \
 && make && make install

# fb303 python module
RUN cd $thrift_src/lib/py \
 && python setup.py install \
 && cd $thrift_src/contrib/fb303/py \
 && python setup.py install

# Scribe
ENV scribe_src /usr/local/src/scribe
COPY ./ ${scribe_src}
RUN cd $scribe_src && ./bootstrap.sh \
 && ./configure CPPFLAGS="-DHAVE_INTTYPES_H -DHAVE_NETINET_IN_H -DBOOST_FILESYSTEM_VERSION=2" LIBS="-lboost_system -lboost_filesystem" \
 && make && make install

# ENV
ENV LD_LIBRARY_PATH /usr/local/lib
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib" >> /etc/profile

# Scribe python module
RUN cd $scribe_src/lib/py && python setup.py install

# Copy conf
RUN mkdir /usr/local/scribe
RUN cp $scribe_src/examples/example2client.conf /usr/local/scribe/scribe.conf

RUN apt-get install -y php5

RUN cd $scribe_src/if/ && thrift -r --gen php scribe.thrift \
                       && thrift -r --gen php bucketupdater.thrift

# Tests
RUN mkdir /tmp/scribetest
RUN ln -s /usr/local/src/scribe/if/gen-php/ /usr/local/src/thrift/lib/php/src/packages

WORKDIR /usr/local/src/scribe

RUN make -C /usr/local/src/scribe/test/resultChecker/