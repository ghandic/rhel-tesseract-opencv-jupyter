FROM registry.access.redhat.com/rhscl/python-36-rhel7

# Change user to root to make installs easy
USER root

ENV PKG_CONFIG_PATH='/usr/local/lib/pkgconfig/' CMAKE_VERSION='3.9.2' OPENCV_VERSION='4.1.1' LEPTONIA_VERSION='1.78.0' TESSERACT_VERSION='4.1.0'

# Install dependencies
RUN yum -y update && \
	yum -y install \
		libstdc++ \
		autoconf \
		automake \
		libtool \
		autoconf-archive \
		pkg-config \
		gcc \
		gcc-c++ \
		make \
		libjpeg-devel \
		libpng-devel \
		libtiff-devel \
		zlib-devel && \
	yum clean all

# Install cmake - needed for compiling opencv
RUN PACKAGE_NAME='cmake' && \
	wget http://files1.directadmin.com/services/custombuild/${PACKAGE_NAME}-${CMAKE_VERSION}.tar.gz -O /${PACKAGE_NAME}.tar.gz && \
	mkdir /${PACKAGE_NAME} && tar -zxvf /${PACKAGE_NAME}.tar.gz -C /${PACKAGE_NAME} --strip-components 1 && \
	cd /${PACKAGE_NAME} && \
	./configure && \
	make -j5 && \
	make install && \
	rm -rf /${PACKAGE_NAME} && \
	rm /${PACKAGE_NAME}.tar.gz

# Install leptonica - needed for compiling tesseract
RUN PACKAGE_NAME='leptonica' && \
	wget http://www.leptonica.org/source/${PACKAGE_NAME}-${LEPTONIA_VERSION}.tar.gz -O /${PACKAGE_NAME}.tar.gz && \
	mkdir /${PACKAGE_NAME} && tar -zxvf /${PACKAGE_NAME}.tar.gz -C /${PACKAGE_NAME} --strip-components 1 && \
	cd /${PACKAGE_NAME} && \
	./autogen.sh && \
	./configure && \
	make -j5 && \
	make install && \
	rm -rf /${PACKAGE_NAME} && \
	rm /${PACKAGE_NAME}.tar.gz

# Install tesseract
RUN PACKAGE_NAME='tesseract' && \
	wget https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.tar.gz -O /${PACKAGE_NAME}.tar.gz && \
	mkdir /${PACKAGE_NAME} && tar -zxvf /${PACKAGE_NAME}.tar.gz -C /${PACKAGE_NAME} --strip-components 1 && \
	cd /${PACKAGE_NAME} && \
	./autogen.sh &&\
	./configure &&\
	make -j5 && \
	make install && \
	ldconfig && \
	wget https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata -P /usr/local/share/tessdata && \
    wget https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/osd.traineddata -P /usr/local/share/tessdata && \
	rm -rf /${PACKAGE_NAME} && \
	rm /${PACKAGE_NAME}.tar.gz

# Install OpenCV + Contribs
RUN PACKAGE_NAME_EXTRA='opencv_contrib' && \
	PACKAGE_NAME='opencv' && \
    wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.tar.gz -O /${PACKAGE_NAME_EXTRA}.tar.gz && \
	mkdir /${PACKAGE_NAME_EXTRA} && tar -zxvf /${PACKAGE_NAME_EXTRA}.tar.gz -C /${PACKAGE_NAME_EXTRA} --strip-components 1 && \
	wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz -O /${PACKAGE_NAME}.tar.gz && \
	mkdir /${PACKAGE_NAME} && tar -zxvf /${PACKAGE_NAME}.tar.gz -C /${PACKAGE_NAME} --strip-components 1 && \
    mkdir /${PACKAGE_NAME}/cmake_binary && \
    cd /${PACKAGE_NAME}/cmake_binary && \
    cmake \
      -DOPENCV_EXTRA_MODULES_PATH=/${PACKAGE_NAME_EXTRA}/modules \
      -DBUILD_TIFF=ON \
      -DBUILD_opencv_java=OFF \
      -DWITH_CUDA=OFF \
      -DENABLE_AVX=ON \
      -DWITH_OPENGL=ON \
      -DWITH_OPENCL=ON \
      -DWITH_IPP=ON \
      -DWITH_TBB=ON \
      -DWITH_EIGEN=ON \
      -DWITH_V4L=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
      -DPYTHON_EXECUTABLE=$(which python) \
      -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
      -DPYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
    && make -j5 && \
	rm -rf /${PACKAGE_NAME} && \
	rm /${PACKAGE_NAME}.tar.gz && \
	rm -rf /${PACKAGE_NAME_EXTRA} && \
	rm /${PACKAGE_NAME_EXTRA}.tar.gz

# Installing Python packages from requirements.txt
ADD requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt && \
	rm -f requirements.txt

# Installing Jupyter and contribs for dev purposes
ADD jupyter-requirements.txt .
EXPOSE 8888
RUN pip3 install --no-cache-dir -r jupyter-requirements.txt && \
	rm -f jupyter-requirements.txt && \
	jupyter contrib nbextension install --system && \
	jupyter notebook --generate-config

# Add EAST text dertection model
RUN mkdir /opt/data && \
	wget https://github.com/oyyd/frozen_east_text_detection.pb/raw/master/frozen_east_text_detection.pb -O /opt/data/frozen_east_text_detection.pb

# Add nltk wordnet corpus
RUN python -c "import nltk; nltk.download('wordnet')"

# Change user back to default in prod
# USER default

WORKDIR "/opt/working"
