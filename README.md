# sunsetpage
This will build the sunset html page with the image assets

# Docker build command
If you are building with ARM architecture, include the platform with the command below:
```
docker build --no-cache --platform linux/amd64 -t ccnmtl/sunset .
```

# Run docker image
```
docker run -d -p 9998:80 ccnmtl/sunset
```