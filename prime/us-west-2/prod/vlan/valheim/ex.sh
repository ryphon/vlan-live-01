docker run -i \
    -p 2456-2458:2456-2458/udp \
    -p 2456-2458:2456-2458/tcp \
    -v $HOME/gp3/valheim/config:/config \
    -e SERVER_NAME="VLANSATURDAYS" \
    -e WORLD_NAME="asdfasdf" \
    -e SERVER_PASS="no" \
    lloesche/valheim-server

