
# Install

> helm install --name survey-moviesanywhere -f values . 

# Update
- Find version # of latest release: https://www.limesurvey.org/stable-release
> ./update_limesurvey.sh
> docker-compose build
> docker-compose push
> helm upgrade -f values.yaml survey-moviesanywhere .