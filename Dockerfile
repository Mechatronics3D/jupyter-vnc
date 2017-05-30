FROM mechatronics3d/cvxpy-notebook
MAINTAINER Behzad Samadi <behzad@mechatronics3d.com>

# CasADi version
ENV CASADIVERSION=3.1.0-rc1

# Folders
ENV WS=$HOME/work
ENV DL=$HOME/Downloads
ENV ST=$HOME/.ipython/default_profile/startup

# Packages
ENV PKGS="wget unzip gcc g++ gfortran git cmake liblapack-dev pkg-config swig spyder time"

USER root

# Update and install required packages
RUN apt-get update && \
    apt-get install -y --install-recommends $PKGS

# Update pip2
RUN pip2 install --upgrade pip

# Update pip3
RUN pip3 install --upgrade pip

# Update conda
RUN conda update conda

# Install LXDE, VNC server, XRDP and Firefox
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  firefox \
  lxde-core \
  lxterminal \
  tightvncserver \
  xrdp

# Install Ipopt
RUN mkdir $DL
RUN wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.6.tgz -O $DL/Ipopt-3.12.6.tgz
RUN cd $DL && \
    tar -xvf Ipopt-3.12.6.tgz
RUN cd $DL/Ipopt-3.12.6/ThirdParty/ASL && ./get.ASL
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Blas && ./get.Blas
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Lapack && ./get.Lapack
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Mumps && ./get.Mumps
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Metis && ./get.Metis
RUN mkdir $DL/Ipopt-3.12.6/build
RUN cd $DL/Ipopt-3.12.6/build && \
    ../configure --prefix=$WS/Ipopt-3.12.6
RUN cd $DL/Ipopt-3.12.6/build && make install

# Install CasADi for Python 2.7
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/linux/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz/download \
    -O $DL/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz && \
    mkdir $WS/casadi-py27-np1.9.1-v$CASADIVERSION && \
    tar -zxvf $DL/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz \
    -C $WS/casadi-py27-np1.9.1-v$CASADIVERSION

# Install CasADi for Python 3.5
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/linux/casadi-py35-np1.9.1-v$CASADIVERSION.tar.gz/download \
    -O $DL/casadi-py35-np1.9.1-v$CASADIVERSION.tar.gz && \
    mkdir $WS/casadi-py35-np1.9.1-v$CASADIVERSION && \
    tar -zxvf $DL/casadi-py35-np1.9.1-v$CASADIVERSION.tar.gz \
    -C $WS/casadi-py35-np1.9.1-v$CASADIVERSION
    
# Defining CasADi path for each version
ENV CASADIPATH2=$WS/casadi-py27-np1.9.1-v$CASADIVERSION
ENV CASADIPATH3=$WS/casadi-py35-np1.9.1-v$CASADIVERSION

# Install CasADi examples
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/casadi-example_pack-v$CASADIVERSION.zip \
    -O $DL/casadi-example_pack-v$CASADIVERSION.zip && \
    mkdir $WS/casadi_examples && \
    unzip $DL/casadi-example_pack-v$CASADIVERSION.zip \
    -d $WS/casadi_examples

# Giving the ownership of the folders to the NB_USER
RUN chown -R $NB_USER $WS
RUN chown -R $NB_USER $DL

# Open port 5901
EXPOSE 5901

# Set default password
COPY password.txt .
RUN cat password.txt password.txt | vncpasswd && \
  rm password.txt
  
# Set XDRP to use TightVNC port
RUN sed -i '0,/port=-1/{s/port=-1/port=5901/}' /etc/xrdp/xrdp.ini

# Copy VNC script that handles restarts
COPY vnc.sh /opt/
CMD ["/opt/vnc.sh"]

USER $NB_USER
