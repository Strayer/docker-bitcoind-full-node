FROM local-debian-base

ARG BITCOIN_CORE_VERSION=0.15.1
ARG RELEASE_GPG_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964

ARG BITCOIN_CORE_TGZ=bitcoin-${BITCOIN_CORE_VERSION}-x86_64-linux-gnu.tar.gz
ARG BITCOIN_CORE=https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/${BITCOIN_CORE_TGZ}
ARG BITCOIN_CORE_SIGS=https://bitcoin.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/SHA256SUMS.asc
ARG APP_ROOT=/app

RUN create-user bitcoind $APP_ROOT

WORKDIR $APP_ROOT
VOLUME /data

COPY $BITCOIN_CORE_TGZ .
COPY bitcoin.conf .bitcoin/

RUN echo "Downloading Bitcoin Core…" && \
    aria2c ${BITCOIN_CORE_SIGS} && \
    gpg-recv-key $RELEASE_GPG_KEY && \
    echo "$RELEASE_GPG_KEY:6:" | gpg --import-ownertrust && \
    gpg --verify SHA256SUMS.asc && \ 
    tar xf ${BITCOIN_CORE_TGZ} --strip 1 && \
    rm ${BITCOIN_CORE_TGZ} SHA256SUMS.asc && \
    rm -rf /root/.gnupg

USER bitcoind

CMD ["./bin/bitcoind"]
