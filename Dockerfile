FROM makerdao/dapphub-tools

WORKDIR /home/maker/spells-kovan
COPY . .

RUN sudo chown -R maker:maker /home/maker/spells-kovan

CMD /bin/bash -c "export PATH=/home/maker/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && ./test-dssspell.sh"
