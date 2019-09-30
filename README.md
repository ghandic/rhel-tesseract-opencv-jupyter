rhel-tesseract-opencv-jupyter
-----------------------------

To get a development environment up and running, simply run:

```bash
docker-compose up
# Or run it in the background with:
docker-compose up -d
# and to stop the service:
docker-compose down
```

This will spin up a development enviornment that you can open up in Jupyter by navigating to http://localhost:8888 or connect to the container using VSCode or by running the following:

```bash
docker exec -it tesseract-opencv-jupyter bash
```

This will essentially be like SSH'ing into a server with the enviornment set up
