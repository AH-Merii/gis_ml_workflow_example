FROM nvidia/cuda:11.1-devel-ubuntu20.04
LABEL maintainer="nweir <nweir@iqt.org>"

# set env variables for configuring tzdata
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG solaris_branch='master'

# prep apt-get and cudnn
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils && \
    rm -rf /var/lib/apt/lists/*

# install requirements
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bc \
    bzip2 \
    ca-certificates \
    curl \
    git \
    libgdal-dev \
    libssl-dev \
    libffi-dev \
    libncurses-dev \
    libgl1 \
    jq \
    nfs-common \
    parallel \
    python-dev \
    python-setuptools \
    unzip \
    vim \
    wget \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]
ENV PATH /opt/conda/bin:$PATH

# install anaconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# prepend pytorch and conda-forge before default channel
RUN conda update conda && \
    conda config --prepend channels conda-forge && \
    conda config --prepend channels pytorch

# get dev version of solaris and create conda environment based on its env file
WORKDIR /tmp/
RUN git clone https://github.com/cosmiq/solaris.git && \
    cd solaris && \
    git checkout ${solaris_branch} && \
    conda env create -f environment.yml
ENV PATH /opt/conda/envs/solaris/bin:$PATH

RUN cd solaris && pip install .

# install various conda dependencies into the space_base environment
RUN conda install -n solaris \
    jupyter \
    jupyterlab \
    ipykernel \
    folium \
    plotly

# activate conda environment
SHELL ["conda", "run", "-n", "solaris", "/bin/bash", "-c"]

# pip install imagecodecs in conda environment
RUN pip install imagecodecs

# add a jupyter kernel for the conda environment in case it's wanted
RUN source activate solaris && python -m ipykernel.kernelspec \
    --name solaris --display-name solaris

# open ports for jupyterlab and tensorboard
EXPOSE 8888/tcp 6006/tcp

WORKDIR /home/solaris

RUN ["/bin/bash"]