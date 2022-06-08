FROM amazonlinux:2

# home配下にコピー
COPY .netrc /root/
COPY .zshrc /root/

ENV LANG=ja_JP.UTF-8
ENV GOPATH=/root/gohome
ENV GOBIN=/usr/local/go/bin
ENV GOHOME=/root/gohome
ENV PATH=$PATH:/usr/local/go/bin
ENV LD_LIBRARY_PATH=./:/usr/local/gcc-10.1.0/lib64
ENV TZ='Asia/Tokyo'
ENV M2_HOME=/opt/maven
ENV PATH=${M2_HOME}/bin:${PATH}
ENV JAVA_HOME=/usr/lib/jvm/java
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig

ARG MAVEN_VERSION=3.8.5
ARG GIT_VERSION=2.32.0
ARG GOLANG_VERSION=1.18.1
ARG CMAKE_VERSION=3.23.1

RUN yum update -y \
	&& yum groupinstall -y 'Development tools' \
	&& yum install -y curl-devel expat-devel gettext-devel   openssl-devel zlib-devel perl-ExtUtils-MakeMaker wget java-1.8.0-openjdk.x86_64 ant libjpeg-devel zsh valgrind \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all \
 	&& mkdir /root/tmp \
 	&& cd /root/tmp \
	# maven
	&& wget https://ftp.jaist.ac.jp/pub/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
	&& tar zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
	&& mv apache-maven-${MAVEN_VERSION} /opt/maven \
	&& rm -rf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
	# git環境取得
 	&& wget https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz \
 	&& tar -zxvf v${GIT_VERSION}.tar.gz \
 	&& cd git-${GIT_VERSION} \
 	&& make prefix=/usr/local all \
 	&& make prefix=/usr/local install \
 	&& make clean \
	# gcc101
	&& cd /root/tmp \
	&& wget https://gcc-10-1-0.s3-ap-northeast-1.amazonaws.com/gcc_10_1_0_centos7.tar.gz \
	&& tar zxvf gcc_10_1_0_centos7.tar.gz -C /usr/local \
	&& ln -s /usr/local/gcc-10.1.0/bin/g++ /usr/local/bin/g++101 \
	&& ln -s /usr/local/gcc-10.1.0/bin/gcc /usr/local/bin/gcc101 \
	# cmake
	&& cd /root/tmp \
	&& wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz \
	&& tar zxvf cmake-${CMAKE_VERSION}.tar.gz \
	&& sed -i "s|cmake_toolchain_Clang_CC='clang'|cmake_toolchain_Clang_CC='clang101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_Clang_CXX='clang++'|cmake_toolchain_Clang_CXX='clang++101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_GNU_CC='gcc'|cmake_toolchain_GNU_CC='gcc101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_GNU_CXX='g++'|cmake_toolchain_GNU_CXX='g++101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_PGI_CC='pgcc'|cmake_toolchain_PGI_CC='pgcc101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_PGI_CXX='pgCC'|cmake_toolchain_PGI_CXX='pgCC101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_PathScale_CC='pathcc'|cmake_toolchain_PathScale_CC='pathcc101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_PathScale_CXX='pathCC'|cmake_toolchain_PathScale_CXX='pathCC101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_XL_CC='xlc'|cmake_toolchain_XL_CC='xlc101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& sed -i "s|cmake_toolchain_XL_CXX='xlC'|cmake_toolchain_XL_CXX='xlC101'|g" cmake-${CMAKE_VERSION}/bootstrap \
	&& cd cmake-${CMAKE_VERSION} \
	&& ./bootstrap && make && make install \
 	# go言語環境取得
	&& cd /root/tmp \
 	&& wget https://redirector.gvt1.com/edgedl/go/go${GOLANG_VERSION}.linux-amd64.tar.gz \
 	&& tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz \
 	&& cd /root \
 	&& mkdir gohome \
 	# テンポラリデータ削除
 	&& rm -rf /root/tmp
