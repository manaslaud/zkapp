# zkapp

To build the image

`
docker build -t zkapp .
`

Then run

`
docker run -it --name zkapp-container \
  -v $HOME/zkdata:/data \
  zkapp
`
