# training-docker-files
### Files for making a Docker image for model training using Python3.6, xgboost, fastText and other data science tools

1. If needed update the [Dockerfile](Dockerfile) with required software.

2. If needed update [pip-req-frozen](pip_req_frozen.txt) with required python packages.

3. Build local docker image from Dockerfile in ~/training-docker-files directory, this code tags the image as as `danielpnewman/training-tools`:

	- `cd training-docker-files`  
	- `docker build -t danielpnewman/training-tools .`

4. Put training data, scripts etc. into local `/to-mount` directory and then mount it into the docker container when you build it using this command:

	- `docker run --interactive --tty  --volume $(pwd)/to-mount:/training/to-mount danielpnewman/training-tools`

	- Note you can mount multiple directories:

		- `docker run --interactive --tty  --volume $(pwd)/to-mount:/training/to-mount --volume $(pwd)/scripts:/training/scrips danielpnewman/training-tools`

5. Push updated docker image to docker hub:

	- `docker push danielpnewman/training-tools`