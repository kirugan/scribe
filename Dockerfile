#
# Dockerfile - Facebook Scribe
#
FROM     ubuntu:16.04

# Last Package Update & Install
RUN apt-get update && apt-get install -y curl python-pip cmake supervisor openssh-server net-tools iputils-ping vim \
 make autoconf automake flex bison libtool libevent-dev pkg-config libssl-dev libboost-all-dev libbz2-dev build-essential g++ python-dev git

# Facebook Scribe
# Thrift
ENV thrift_src /usr/local/src/thrift
RUN git clone https://github.com/apache/thrift.git $thrift_src \
 && cd $thrift_src && git checkout v0.12.0 \
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

RUN pip install six

# Scribe
ENV scribe_src /usr/local/src/scribe
COPY ./ ${scribe_src}
RUN cd $scribe_src && \
       thrift --gen cpp:pure_enums -o src/  ./if/scribe.thrift && \
       thrift --gen cpp:pure_enums -o src/ ./if/bucketupdater.thrift && \
       cmake . && make

# Scribe python module
RUN cd $scribe_src/lib/py && python setup.py install

# Copy conf
RUN mkdir /usr/local/scribe
RUN cp $scribe_src/examples/example2client.conf /usr/local/scribe/scribe.conf

RUN apt-get install -y php

RUN cd $scribe_src/if/ && thrift -r --gen php scribe.thrift \
                       && thrift -r --gen php bucketupdater.thrift

# Tests
RUN mkdir /tmp/scribetest
RUN ln -s /usr/local/src/scribe/if/gen-php/ /usr/local/src/thrift/lib/php/src/packages

WORKDIR /usr/local/src/scribe

RUN make -C /usr/local/src/scribe/test/resultChecker/