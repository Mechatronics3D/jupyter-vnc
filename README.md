# jupyter-vnc
This container provides a Jupyter Notebook and a VNC server. The VNC setup is taken from [vnc](https://hub.docker.com/r/kaixhin/vnc/).

## Usage
You can run the container like this:

`docker run -p 8888:8888 5900:5900 mechatronics3d/jupyter-vnc`

Then go to this address on your browser:

`http://localhost:8888/`
