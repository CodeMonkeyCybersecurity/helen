## How to use this:

	Build the Docker image correctly:
When you build the image, the build context should be set to the DEV/ directory (where the Dockerfile is located). Run the following from the parent directory of DEV/:

docker build -t helen_DEV:latest ./DEV


	Test the image:

docker run -d -p 9080:80 helen_DEV:latest

Visit http://localhost:9080 to confirm the site is being served.
