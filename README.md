rhel-tesseract-opencv-jupyter
-----------------------------

#### Development

To get a development environment up and running:

1. Create Red Hat account [link](https://www.redhat.com/wapps/ugc/register.html?_flowId=register-flow&_flowExecutionKey=e1s1)
2. Login to Red Hat docker registry with your credentials: `docker login registry.redhat.io`
3. Run:

```bash
docker-compose up
# Or run it in the background with:
docker-compose up -d
# and to stop the service:
docker-compose down
```

This will spin up a development enviornment that you can open up in Jupyter by navigating to http://localhost:8888 or connect to the container using VSCode or by running the following:

```bash
docker exec -it rhel-tesseract-opencv-jupyter bash
```

This will essentially be like SSH'ing into a server with the enviornment set up